import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import '../provider/incident_provider.dart'; 
import 'package:misconductmobile/models/incident.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'IncidentsDetails.dart'; 

class IncidentsPage extends StatefulWidget {
  const IncidentsPage({super.key});

  @override
  State<IncidentsPage> createState() => _IncidentsPageState();
}

class _IncidentsPageState extends State<IncidentsPage> {

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

  bool _loading = false; 

  static const primaryColor = Color(0xFF2E7D32);

  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy'); 

  static const List<String> _programList = [
    'BSIT', 'BSCS', 'BSDSA', 'BLIS', 'BSIS',
  ];

  static const Map<String, List<String>> _offenseList = {
    "Minor Offense": [
      "Failure to wear uniform", "Pornographic materials", "Littering", 
      "Loitering", "Eating in restricted areas", "Unauthorized use of school facilities",
      "Lending/borrowing ID", "Driving violations",
    ],
    "Major Offense": [
      "Alcohol/drugs/weapons", "Smoking", "Disrespect", "Vandalism", 
      "Cheating/forgery", "Barricades/obstructions", "Physical/verbal assault", 
      "Hazing", "Harassment/sexual abuse", "Unauthorized software/gadgets", 
      "Unrecognized fraternity/sorority", "Gambling", "Public indecency", 
      "Offensive/subversive materials", "Grave threats", "Inciting fight/sedition", 
      "Unauthorized activity", "Bullying",
    ],
  };

  String _formatBackendErrors(Map<String, dynamic> errors) {
    String errorMessage = 'Please correct the following issues:\n';
    
    if (errors.containsKey('studentId') && errors['studentId'] is List && errors['studentId'].isNotEmpty) {
      if (errors['studentId'].first.toString().contains('invalid')) {
           errorMessage += '• **Student Record Not Found:** The Student ID Number is not registered in the system.\n';
      } else {
           errorMessage += '• ${errors['studentId'].first}\n';
      }
      errors.remove('studentId'); 
    }

    errors.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        final formattedKey = key.replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}').replaceAll('Id', ' ID').trim();
        errorMessage += '• $formattedKey: ${value.first}\n';
      }
    });
    
    return errorMessage.trim();
  }
  
  Future<void> _submit() async {
    if (_incidentDate == null || _incidentTime == null || _offenseType == null || 
        _specificOffense == null || _studentId.text.isEmpty || _fullName.text.isEmpty || 
        _program == null || _yearLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please fill out all."),
            backgroundColor: Colors.orange,
          ),
      );
      return;
    }

    final incidentProvider = Provider.of<IncidentProvider>(context, listen: false);

    setState(() => _loading = true);

    final incidentDateTime = DateTime(
      _incidentDate!.year, _incidentDate!.month, _incidentDate!.day,
      _incidentTime!.hour, _incidentTime!.minute,
    );

    final formattedTime = DateFormat('HH:mm').format(incidentDateTime); 

    final incident = Incident(
      studentId: _studentId.text,
      fullName: _fullName.text,
      program: _program ?? "", 
      yearLevel: _yearLevel ?? "",
      section: _section.text,
      dateOfIncident: _incidentDate!.toIso8601String().split('T').first, 
      timeOfIncident: formattedTime,
      location: _location.text,
      offenseCategory: _offenseType ?? "",
      specificOffense: _specificOffense ?? "",
      description: _description.text,
      status: 'Pending',
      recommendation: null,
      actionTaken: null,
    );

    try {
      final response = await incidentProvider.createIncident(incident);
      
      setState(() => _loading = false);

      if (mounted) {
        final Incident filedIncident = response['incident'];
        final String recommendation = response['recommendation'];

        _showRecommendationDialog(context, recommendation, filedIncident); 
      }
    } catch (e) {
      setState(() => _loading = false);
      
      if (mounted) {
        if (e.toString().startsWith('Exception: {')) {
          try {
            final errorData = e.toString().substring('Exception: '.length);
            final Map<String, dynamic> response = jsonDecode(errorData);
            
            if (response.containsKey('errors')) {
              final errorMessages = _formatBackendErrors(response['errors']);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: SelectableText(errorMessages, style: const TextStyle(color: Colors.white)), 
                  backgroundColor: Colors.red.shade700, 
                  duration: const Duration(seconds: 7), 
                ),
              );
            }
          } catch (jsonE) {
            _showGeneralErrorSnackBar(context, "An unknown validation error occurred.", e.toString());
          }
        } else {
          _showGeneralErrorSnackBar(context, "Failed to submit incident.", e.toString());
        }
      }
    }
  }

  void _showGeneralErrorSnackBar(BuildContext context, String message, String details) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$message: $details"),
        backgroundColor: Colors.red,
      ),
    );
  }


  void _showRecommendationDialog(BuildContext context, String recommendation, Incident filedIncident) {
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
    });
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
          actions: <Widget>[
            TextButton(
              child: const Text('New Report'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            if (filedIncident.incidentId != null) 
              TextButton(
                child: const Text('View Report Details', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.of(context).pop(); 

                  Navigator.pushReplacement( 
                    context,
                    MaterialPageRoute(
                      builder: (_) => IncidentDetailScreen(incident: filedIncident), 
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

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
            Navigator.pop(context); 
          },
        ),
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

                _dropdown(
                  label: "Program",
                  value: _program,
                  items: _programList,
                  onChangedCallback: (val) => setState(() => _program = val),
                ),
                _gap(),

                _dropdown(
                  label: "Year Level",
                  value: _yearLevel,
                  items: const ["1st Year", "2nd Year", "3rd Year", "4th Year"],
                  onChangedCallback: (val) => setState(() => _yearLevel = val),
                ),
                _gap(),

                _input("Section", _section, Icons.group),
                _gap(),

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
                _gap(),

                _pickerButton(
                  label: "Select Time of Incident",
                  icon: Icons.access_time,
                  selectedTime: _incidentTime,
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
                _gap(),

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
    );
  }


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
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
  }) {
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor), 
          const SizedBox(width: 12),
          Text(
            displayLabel,
            style: TextStyle(color: labelColor), 
          ),
        ],
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);
}