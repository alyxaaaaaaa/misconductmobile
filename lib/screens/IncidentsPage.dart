import 'package:flutter/material.dart';
import 'package:misconductmobile/models/incident.dart';
import 'package:misconductmobile/services/api_service.dart';
import 'package:misconductmobile/screens/DashboardScreen.dart';
import 'package:intl/intl.dart'; 

class AddIncidentScreen extends StatefulWidget {
  const AddIncidentScreen({super.key});

  @override
  State<AddIncidentScreen> createState() => _AddIncidentScreenState();
}

class _AddIncidentScreenState extends State<AddIncidentScreen> {
  // Text Controllers
  final _studentId = TextEditingController();
  final _fullName = TextEditingController();
  final _program = TextEditingController();
  final _section = TextEditingController();
  final _location = TextEditingController();
  final _description = TextEditingController();

  // State variables for dropdowns
  String? _yearLevel;
  String? _offenseType; 
  String? _specificOffense; 

  DateTime? _incidentDate;
  TimeOfDay? _incidentTime;

  bool _loading = false;

  // Colors
  static const primaryColor = Color(0xFF2E7D32);

  // Define offense categories and their specific offenses
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

  Future<void> _submit() async {
    // Check if required fields are selected/filled
    if (_incidentDate == null ||
        _incidentTime == null ||
        _offenseType == null ||
        _specificOffense == null ||
        _studentId.text.isEmpty ||
        _fullName.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Please fill out all required fields (including date, time, and offenses).")),
      );
      return;
    }

    setState(() => _loading = true);

    // 1. Combine Date and Time into a single DateTime object
    final incidentDateTime = DateTime(
      _incidentDate!.year,
      _incidentDate!.month,
      _incidentDate!.day,
      _incidentTime!.hour,
      _incidentTime!.minute,
    );

    // 2. Format the time to 24-hour format (H:i) required by the backend
    final formattedTime = DateFormat('HH:mm').format(incidentDateTime); 

    // 3. Construct the Incident object
    final incident = Incident(
      studentId: _studentId.text,
      fullName: _fullName.text,
      program: _program.text,
      yearLevel: _yearLevel ?? "",
      section: _section.text,
      dateOfIncident: _incidentDate!.toIso8601String(),
      timeOfIncident: formattedTime, // 24-hour format
      location: _location.text,
      offenseCategory: _offenseType ?? "", // Minor/Major
      specificOffense: _specificOffense ?? "", // The specific offense
      description: _description.text,
      status: 'Pending', // Default status for a new submission
    );

    final success = await ApiService.submitIncident(incident);

    setState(() => _loading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incident submitted successfully!")),
      );
      
      // 🎯 FIX: Use pushAndRemoveUntil for clean routing back to Dashboard
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (Route<dynamic> route) => false, // Remove all previous routes
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to submit incident.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Get the list of specific offenses for the currently selected offense type
    final specificOffenses = _offenseType != null
        ? _offenseList[_offenseType] ?? []
        : <String>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Incident Form"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
             // 🎯 FIX: Use pushAndRemoveUntil for back button as well
             Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
                (Route<dynamic> route) => false, 
             );
          },
        ),
      ),

      // Background Gradient
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4CAF50), primaryColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),

            child: Container(
              width: width * 0.92,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Center(
                    child: Text(
                      "Incident Report",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  _input("Student ID Number", _studentId, Icons.badge),
                  _gap(),

                  _input("Full Name", _fullName, Icons.person),
                  _gap(),

                  _input("Program", _program, Icons.account_tree),
                  _gap(),

                  // Year Level Dropdown
                  _dropdown(
                    label: "Year Level",
                    value: _yearLevel,
                    items: const ["1st Year", "2nd Year", "3rd Year", "4th Year"],
                    onChangedCallback: (val) => setState(() => _yearLevel = val),
                  ),
                  _gap(),

                  _input("Section", _section, Icons.group),
                  _gap(),

                  // Date Picker
                  _pickerButton(
                    label: _incidentDate == null
                        ? "Select Date of Incident"
                        : "Date: ${_incidentDate!.toLocal()}".split(' ')[0],
                    icon: Icons.date_range,
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
                  _gap(),

                  // Time Picker
                  _pickerButton(
                    label: _incidentTime == null
                        ? "Select Time of Incident"
                        // Display 12-hour format for user clarity
                        : "Time: ${_incidentTime!.format(context)}", 
                    icon: Icons.access_time,
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) setState(() => _incidentTime = time);
                    },
                  ),
                  _gap(),

                  _input("Location of Incident", _location, Icons.place),
                  _gap(),

                  // Offense Type dropdown (Category)
                  _dropdown(
                    label: "Offense Type (Category)",
                    value: _offenseType,
                    items: const ["Minor Offense", "Major Offense"],
                    onChangedCallback: (val) {
                      setState(() {
                        _offenseType = val;
                        // Reset specific offense when the category changes
                        _specificOffense = null; 
                      });
                    },
                  ),
                  _gap(),

                  // Specific Offense dropdown, conditionally displayed
                  if (_offenseType != null) ...[
                    _dropdown(
                      label: "Specific Offense",
                      value: _specificOffense,
                      items: specificOffenses,
                      onChangedCallback: (val) =>
                          setState(() => _specificOffense = val),
                    ),
                    _gap(),
                  ],

                  // Description
                  TextField(
                    controller: _description,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: "Description",
                      filled: true,
                      fillColor: Colors.green[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                            ),
                            child: const Text(
                              "Submit Incident",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Reusable Widgets
  Widget _input(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: Colors.green[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChangedCallback,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true, 
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis,)))
            .toList(),
        onChanged: onChangedCallback,
      ),
    );
  }

  Widget _pickerButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[50],
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);
}