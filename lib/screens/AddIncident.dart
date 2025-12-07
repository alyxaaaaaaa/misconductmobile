import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
// Assuming these paths are correct relative to this file
import '../providers/student_provider.dart';
import '../providers/incident_provider.dart';
import '../providers/dashboard_stats_provider.dart'; // REQUIRED FOR REFRESH
import '../models/student.dart';
import '../models/incident.dart';
import 'IncidentsDetails.dart'; // Ensure this file and class exists

// This widget is assumed to be in screens/AddIncident.dart
class AddIncident extends StatefulWidget {
  const AddIncident({super.key});

  @override
  State<AddIncident> createState() => _AddIncidentState();
}

class _AddIncidentState extends State<AddIncident> {
  final _studentId = TextEditingController();
  final _fullName = TextEditingController();
  final _section = TextEditingController();
  final _location = TextEditingController();
  final _description = TextEditingController();

  String? _yearLevel;
  String? _offenseType;
  String? _specificOffense;
  String? _program;

  DateTime? _incidentDate;
  TimeOfDay? _incidentTime;

  bool _loadingLocal = false;

  static const primaryColor = Color(0xFF2E7D32); // Dark green
  // === MODIFICATION 1: DEFINING THE lightGreenBackground COLOR ===
  static const Color lightGreenBackground = Color(0xFFE8F5E9); // Light green background
  // =============================================================
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');

  // Offense lists
  static const Map<String, List<String>> _offenseList = {
    "Minor Offense": [
      "Failure to wear uniform",
      "Pornographic materials",
      "Littering",
      "Loitering",
      "Eating in restricted areas",
      "Unauthorized use of school facilities",
      "Lending/borrowing ID",
      "Driving violations",
    ],
    "Major Offense": [
      "Alcohol/drugs/weapons",
      "Smoking",
      "Disrespect",
      "Vandalism",
      "Cheating/forgery",
      "Barricades/obstructions",
      "Physical/verbal assault",
      "Hazing",
      "Harassment/sexual abuse",
      "Unauthorized software/gadgets",
      "Unrecognized fraternity/sorority",
      "Gambling",
      "Public indecency",
      "Offensive/subversive materials",
      "Grave threats",
      "Inciting fight/sedition",
      "Unauthorized activity",
      "Bullying",
    ],
  };

  Student? _selectedStudent;

  @override
  void initState() {
    super.initState();
    // Ensures the context is available to fetch initial data for the dropdown
    Future.microtask(() {
      Provider.of<StudentProvider>(context, listen: false).fetchStudentsForDropdown();
    });
  }

  @override
  void dispose() {
    _studentId.dispose();
    _fullName.dispose();
    _section.dispose();
    _location.dispose();
    _description.dispose();
    super.dispose();
  }

  void _onStudentSelected(Student? s) {
    setState(() {
      _selectedStudent = s;
      if (s != null) {
        _studentId.text = s.studentId;
        _fullName.text = s.fullName;
        _program = s.program;
        _yearLevel = s.yearLevel;
        _section.text = s.section;
      } else {
        _studentId.clear();
        _fullName.clear();
        _program = null;
        _yearLevel = null;
        _section.clear();
      }
    });
  }

  String _formatBackendErrors(Map<String, dynamic> errors) {
    String errorMessage = 'Please correct the following issues:\n';
    if (errors.containsKey('studentId') && errors['studentId'] is List && errors['studentId'].isNotEmpty) {
      if (errors['studentId'][0].toString().contains('invalid')) {
        errorMessage += '• Student Record Not Found: The Student ID Number is not registered.\n';
      } else {
        errorMessage += '• ${errors['studentId'][0]}\n';
      }
      errors.remove('studentId');
    }
    errors.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        final formattedKey = key.replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
            .replaceAll('Id', ' ID')
            .trim();
        errorMessage += '• $formattedKey: ${value.first}\n';
      }
    });
    return errorMessage.trim();
  }

  Future<void> _submit() async {
    if (_incidentDate == null ||
        _incidentTime == null ||
        _offenseType == null ||
        _specificOffense == null ||
        _studentId.text.isEmpty ||
        _fullName.text.isEmpty ||
        _program == null ||
        _yearLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill out all required fields."), backgroundColor: Colors.orange),
      );
      return;
    }

    // Get providers using listen: false
    final incidentProvider = Provider.of<IncidentProvider>(context, listen: false);  
    final dashboardProvider = Provider.of<DashboardStatsProvider>(context, listen: false); // GET DASHBOARD PROVIDER

    setState(() => _loadingLocal = true);

    final incidentDateTime = DateTime(_incidentDate!.year, _incidentDate!.month, _incidentDate!.day,
        _incidentTime!.hour, _incidentTime!.minute);

    final formattedTime = DateFormat('HH:mm').format(incidentDateTime);

    final incident = Incident(
      studentId: _studentId.text,
      fullName: _fullName.text,
      program: _program ?? '',
      yearLevel: _yearLevel ?? '',
      section: _section.text,
      dateOfIncident: _incidentDate!.toIso8601String().split('T').first,
      timeOfIncident: formattedTime,
      location: _location.text,
      offenseCategory: _offenseType ?? '',
      specificOffense: _specificOffense ?? '',
      description: _description.text,
      status: 'Pending',
      recommendation: null,
      actionTaken: null,
    );

    try {
      final response = await incidentProvider.createIncident(incident);
      
      // *** FIX: CALL DASHBOARD REFRESH ***
      await dashboardProvider.fetchAllStats(); 

      setState(() => _loadingLocal = false);

      if (mounted) {
        final Incident filedIncident = response['incident'];
        final String recommendation = response['recommendation'];
        _showRecommendationDialog(context, recommendation, filedIncident);
      }
    } catch (e) {
      setState(() => _loadingLocal = false);

      if (e.toString().startsWith('Exception: {') || e.toString().startsWith('{')) {
        try {
          final errorData = e.toString().replaceFirst('Exception: ', '').trim();
          final Map<String, dynamic> response = errorData.isNotEmpty ? Map<String, dynamic>.from(
              (jsonDecode(errorData) as Map).map((k, v) => MapEntry(k.toString(), v))
          ) : {};
          if (response.containsKey('errors')) {
            final errorMessages = _formatBackendErrors(Map<String, dynamic>.from(response['errors']));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: SelectableText(errorMessages, style: const TextStyle(color: Colors.white)),
                backgroundColor: Colors.red.shade700,
                duration: const Duration(seconds: 7),
              ),
            );
            return;
          }
        } catch (_) {
          // fall through to general error
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit incident: ${e.toString()}"), backgroundColor: Colors.red),
      );
    }
  }

  void _showRecommendationDialog(BuildContext context, String recommendation, Incident filedIncident) {
    // clear fields upon successful submission
    _studentId.clear();
    _fullName.clear();
    _section.clear();
    _location.clear();
    _description.clear();
    setState(() {
      _incidentDate = null;
      _incidentTime = null;
      _offenseType = null;
      _specificOffense = null;
      _program = null;
      _yearLevel = null;
      _selectedStudent = null;
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Incident Filed!', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('The report has been filed. For next steps, the system recommends:'),
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('System Recommendation:', style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                    const SizedBox(height: 4),
                    Text(
                      recommendation,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('New Report'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            if (filedIncident.incidentId != null)
              TextButton(
                child: const Text('View Report Details', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.of(context).pop();
                  // Pushes to the details screen
                  Navigator.push( 
                    context,
                    MaterialPageRoute(builder: (_) => IncidentDetailScreen(incident: filedIncident)),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  // Helper function to create a TextField input
  Widget _input(String label, TextEditingController controller, IconData icon, {bool enabled = true}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: Colors.green[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  // Helper function to create a Dropdown form field
  Widget _dropdown({required String label, required String? value, required List<String> items, required void Function(String?) onChangedCallback}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label, border: InputBorder.none),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
        onChanged: onChangedCallback,
      ),
    );
  }

  // Helper function for Date and Time pickers
  Widget _pickerButton({required String label, required IconData icon, required VoidCallback onTap, DateTime? selectedDate, TimeOfDay? selectedTime}) {
    String displayLabel = label;
    Color labelColor = primaryColor;

    if (icon == Icons.date_range && selectedDate != null) {
      displayLabel = 'Date: ${_dateFormatter.format(selectedDate)}';
      labelColor = Colors.black;
    } else if (icon == Icons.access_time) {
      if (selectedTime != null) {
        displayLabel = 'Time: ${selectedTime.format(context)}';
        labelColor = Colors.black;
      } else {
        displayLabel = label;
        labelColor = primaryColor;
      }
    }

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[50],
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor),
          const SizedBox(width: 12),
          Text(displayLabel, style: TextStyle(color: labelColor)),
        ],
      ),
    );
  }

  // Helper function to extract unique program names from the student list
  List<String> _getProgramListFromStudents(List<Student> students) {
    final set = <String>{};
    for (var s in students) {
      if (s.program.isNotEmpty) set.add(s.program);
    }
    // return in predictable order
    final list = set.toList()..sort();
    return list;
  }
  
  // The main build method
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // listen: true is used here since we need the UI to rebuild when loading/students change
    final studentProv = Provider.of<StudentProvider>(context);
    final incidentProv = Provider.of<IncidentProvider>(context);

    final specificOffenses = _offenseType != null ? _offenseList[_offenseType] ?? [] : <String>[];

    return Scaffold(
      // === MODIFICATION 2: APPLYING lightGreenBackground TO THE SCAFFOLD BODY ===
      backgroundColor: lightGreenBackground,
      // ========================================================================
      appBar: AppBar(
        title: const Text("Add Incident"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            width: width * 0.92,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    " File Incident Report",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primaryColor),
                  ),
                ),
                const SizedBox(height: 24),

                // STUDENT DROPDOWN (Conditional based on studentProv.loading)
                studentProv.loading
                    ? const Center(child: CircularProgressIndicator())
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12)),
                        child: DropdownButtonFormField<Student>(
                          value: _selectedStudent,
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: 'Select Student', border: InputBorder.none),
                          items: studentProv.students
                              .map((s) => DropdownMenuItem<Student>(
                                          value: s,
                                          child: Text('${s.fullName} — ${s.studentId}', overflow: TextOverflow.ellipsis),
                                        ))
                              .toList(),
                          onChanged: _onStudentSelected,
                        ),
                      ),

                const SizedBox(height: 16),

                // Student details (auto-filled fields)
                _input("Student ID Number", _studentId, Icons.badge, enabled: false),
                const SizedBox(height: 16),
                _input("Full Name", _fullName, Icons.person, enabled: false),
                const SizedBox(height: 16),

                // Program (dropdown)
                _dropdown(
                  label: "Program",
                  value: _program,
                  items: _getProgramListFromStudents(studentProv.students),
                  onChangedCallback: (val) => setState(() => _program = val),
                ),
                const SizedBox(height: 16),

                // Year Level (dropdown)
                _dropdown(
                  label: "Year Level",
                  value: _yearLevel,
                  items: const ["1st Year", "2nd Year", "3rd Year", "4th Year"],
                  onChangedCallback: (val) => setState(() => _yearLevel = val),
                ),
                const SizedBox(height: 16),

                _input("Section", _section, Icons.group),
                const SizedBox(height: 16),

                // Date Picker
                _pickerButton(
                  label: "Select Date of Incident",
                  icon: Icons.date_range,
                  selectedDate: _incidentDate,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      initialDate: DateTime.now(),
                    );
                    if (date != null) setState(() => _incidentDate = date);
                  },
                ),
                const SizedBox(height: 16),
                
                // Time Picker
                _pickerButton(
                  label: "Select Time of Incident",
                  icon: Icons.access_time,
                  selectedTime: _incidentTime,
                  onTap: () async {
                    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (time != null) setState(() => _incidentTime = time);
                  },
                ),
                const SizedBox(height: 16),

                _input("Location of Incident", _location, Icons.place),
                const SizedBox(height: 16),

                // Offense Type Dropdown
                _dropdown(
                  label: "Offense Type (Category)",
                  value: _offenseType,
                  items: const ["Minor Offense", "Major Offense"],
                  onChangedCallback: (val) {
                    setState(() {
                      _offenseType = val;
                      _specificOffense = null;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Specific Offense Dropdown (Conditional)
                if (_offenseType != null) ...[
                  _dropdown(
                    label: "Specific Offense",
                    value: _specificOffense,
                    items: specificOffenses,
                    onChangedCallback: (val) => setState(() => _specificOffense = val),
                  ),
                  const SizedBox(height: 16),
                ],

                // Description Text Field
                TextField(
                  controller: _description,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: "Description",
                    filled: true,
                    fillColor: Colors.green[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),

                const SizedBox(height: 30),

                // Submit Button / Loading Indicator
                (_loadingLocal || incidentProv.loading)
                    ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)))
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 5,
                          ),
                          child: const Text("Submit Incident", style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          // This navigation logic assumes the other screens are available in the navigator stack
          if (index != 2) Navigator.pop(context);  
        },
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Incidents List'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 40), label: 'Add Incident'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}