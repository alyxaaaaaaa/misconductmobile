import 'package:flutter/material.dart';
import 'package:misconductmobile/models/incident.dart';
import 'package:intl/intl.dart';
import 'package:misconductmobile/providers/incident_provider.dart';
import 'package:misconductmobile/providers/dashboard_stats_provider.dart'; 
import 'package:provider/provider.dart';
import 'package:misconductmobile/providers/user_provider.dart'; 

class EditIncidentScreen extends StatefulWidget {
  final Incident incidentToEdit;

  const EditIncidentScreen({super.key, required this.incidentToEdit});

  static const primaryColor = Color(0xFF84BE78);
  static const Color lightGreenBackground = Color(0xFFE8F5E9);

  @override
  State<EditIncidentScreen> createState() => _EditIncidentScreenState();
}

class _EditIncidentScreenState extends State<EditIncidentScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _studentIdController;
  late TextEditingController _fullNameController;
  late TextEditingController _sectionController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _recommendationController;
  late TextEditingController _actionTakenController;

  bool _isSaving = false;

  late String? _yearLevel;
  late String? _program;
  late String? _offenseType;
  late String? _specificOffense;
  late String? _status;
  
  late String _userRole = 'user'; 
  bool get _isAdmin => _userRole == 'admin';

  late DateTime? _incidentDate;
  late TimeOfDay? _incidentTime;

  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');

  static const Map<String, List<String>> _offenseList = {
    "Minor Offense": [
      "Failure to wear uniform", "Pornographic materials", "Littering", "Loitering",
      "Eating in restricted areas", "Unauthorized use of school facilities", 
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

  static const List<String> _statusOptions = ['Pending', 'Approved', 'Resolved', 'Rejected', 'Under Review', 'Closed'];


  String _getRecommendationPlaceholder(String? offenseType) {
    if (offenseType == "Minor Offense") {
      return "Issuance of a formal warning letter to the student and notification to the parent/guardian. Consider mandatory counseling or a brief disciplinary action (e.g., community service) for repeat offenses.";
    } else if (offenseType == "Major Offense") {
      return "Immediate suspension (3-5 days) and mandatory disciplinary hearing with school administration and parent/guardian. Legal action may be required depending on the nature of the offense.";
    } else {
      return "Please select an offense category to receive a system recommendation.";
    }
  }

  @override
  void initState() {
    super.initState();
    final incident = widget.incidentToEdit;

    _studentIdController = TextEditingController(text: incident.studentId);
    _fullNameController = TextEditingController(text: incident.fullName);
    _sectionController = TextEditingController(text: incident.section);
    _locationController = TextEditingController(text: incident.location);
    _descriptionController = TextEditingController(text: incident.description);
    
    _recommendationController = TextEditingController(
      text: incident.recommendation ?? '', 
    );
    _actionTakenController = TextEditingController(text: incident.actionTaken);

    _program = incident.program.isNotEmpty ? incident.program : null;
    _yearLevel = incident.yearLevel.isNotEmpty ? incident.yearLevel : null;
    _offenseType = incident.offenseCategory.isNotEmpty ? incident.offenseCategory : null;
    _specificOffense = incident.specificOffense.isNotEmpty ? incident.specificOffense : null;
    _status = incident.status.isNotEmpty ? incident.status : 'Pending';

    _incidentDate = DateTime.tryParse(incident.dateOfIncident) ?? DateTime.now();

    if (incident.timeOfIncident.isNotEmpty) {
      try {
        final parts = incident.timeOfIncident.split(':');
        _incidentTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      } catch (e) {
        _incidentTime = null;
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      _userRole = userProvider.role ?? 'user';
    } catch (e) {
      debugPrint('Warning: Could not access UserProvider for RBAC. Defaulting to user role.');
      _userRole = 'user';
    }
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _fullNameController.dispose();
    _sectionController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _recommendationController.dispose();
    _actionTakenController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the errors in the form.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (_incidentDate == null || _incidentTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Date and Time of incident are required.'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_incidentDate!.weekday == DateTime.sunday) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The date of incident cannot be a Sunday.'), backgroundColor: Colors.red),
      );
      return;
    }

    final hour = _incidentTime!.hour;
    if (hour < 7 || hour > 17) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The time of incident must be between 7:00 AM and 5:00 PM.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final updatedIncident = Incident(
      studentId: _studentIdController.text,
      fullName: _fullNameController.text,
      incidentId: widget.incidentToEdit.incidentId,
      program: _program ?? '',
      yearLevel: _yearLevel ?? '',
      section: _sectionController.text,
      dateOfIncident: _incidentDate?.toIso8601String().split('T').first ?? '',
      timeOfIncident: _incidentTime != null
          ? '${_incidentTime!.hour.toString().padLeft(2, '0')}:${_incidentTime!.minute.toString().padLeft(2, '0')}'
          : '',
      location: _locationController.text,
      offenseCategory: _offenseType ?? '',
      specificOffense: _specificOffense ?? '',
      description: _descriptionController.text,
      status: _status ?? 'Pending',
      recommendation: _recommendationController.text,
      actionTaken: _actionTakenController.text,
    );

    try {
      await Provider.of<IncidentProvider>(context, listen: false)
          .updateIncident(updatedIncident);
          
      await Provider.of<DashboardStatsProvider>(context, listen: false)
          .fetchAllStats();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incident updated successfully!'),
          backgroundColor: EditIncidentScreen.primaryColor,
        ),
      );

      Navigator.pop(context, updatedIncident); 
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update incident: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteIncident() async {
    if (!_isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission Denied. Only Admins can delete.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final incidentProvider = Provider.of<IncidentProvider>(context, listen: false);
      final dashboardStatsProvider = Provider.of<DashboardStatsProvider>(context, listen: false);

      await incidentProvider.deleteIncident(widget.incidentToEdit);

      await dashboardStatsProvider.fetchAllStats();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incident soft-deleted successfully!'),
          backgroundColor: Colors.red, 
        ),
      );

      Navigator.popUntil(context, (route) => route.isFirst); 
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete incident: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion ⚠️'),
        content: Text(
          'Are you sure you want to soft-delete Incident #${widget.incidentToEdit.incidentId}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteIncident();
    }
  }

  Widget _input(String label, TextEditingController controller, IconData icon,
      {bool enabled = true, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        style: TextStyle(color: enabled ? Colors.black : Colors.grey[700]),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: EditIncidentScreen.primaryColor),
          filled: true,
          fillColor: enabled ? Colors.green[50] : Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (!enabled) return null;
          if ((label.contains('ID') || label.contains('Description') || label.contains('Location')) &&
              (value == null || value.isEmpty)) {
            return '$label is required.';
          }
          return null;
        },
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChangedCallback,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: enabled ? Colors.green[50] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          onChanged: enabled ? onChangedCallback : null,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
            prefixIcon: Icon(
                label.contains('Status') ? Icons.check_circle : Icons.list,
                color: EditIncidentScreen.primaryColor),
            prefixIconConstraints: const BoxConstraints(minWidth: 40),
          ),
          items: items.toSet().toList()
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          validator: (val) {
            if (val == null || val.isEmpty) {
              return '$label is required.';
            }
            return null;
          },
        ),
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
    Color labelColor = EditIncidentScreen.primaryColor;

    if (icon == Icons.date_range && selectedDate != null) {
      displayLabel = 'Date: ${_dateFormatter.format(selectedDate)}';
      labelColor = Colors.black;
    } else if (icon == Icons.access_time && selectedTime != null) {
      displayLabel = 'Time: ${selectedTime.format(context)}';
      labelColor = Colors.black;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ElevatedButton(
        onPressed: _isSaving ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[50],
          foregroundColor: EditIncidentScreen.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          children: [
            Icon(icon, color: EditIncidentScreen.primaryColor),
            const SizedBox(width: 12),
            Text(displayLabel, style: TextStyle(color: labelColor)),
          ],
        ),
      ),
    );
  }

  List<String> _getProgramList() => ['BSIT', 'BSCS', 'BSDSA', 'BLIS', 'BSIS'];
  List<String> _getYearLevelList() => ['1st Year', '2nd Year', '3rd Year', '4th Year'];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final specificOffenses =
        _offenseType != null ? _offenseList[_offenseType] ?? [] : <String>[];

    return Scaffold(
      backgroundColor: EditIncidentScreen.lightGreenBackground,
      appBar: AppBar(
        title: const Text('Edit Incident Details'),
        backgroundColor: EditIncidentScreen.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: _isSaving ? null : () => _confirmDelete(context),
              tooltip: 'Soft Delete Incident (Admin Only)',
            ),
        ],
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Center(
                    child: Text(
                      "Update Incident Report",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: EditIncidentScreen.primaryColor),
                    ),
                  ),
                  const Divider(height: 30),

                  const Text('Student Details (Read-Only)',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  _input("Student ID Number", _studentIdController, Icons.badge, enabled: false),
                  _input("Full Name", _fullNameController, Icons.person, enabled: false),
                  _dropdown(
                    label: "Program",
                    value: _program,
                    items: _getProgramList(),
                    onChangedCallback: (val) {},
                    enabled: false,
                  ),

                  _dropdown(
                    label: "Year Level",
                    value: _yearLevel,
                    items: _getYearLevelList(),
                    onChangedCallback: (val) {},
                    enabled: false,
                  ),

                  _input("Section", _sectionController, Icons.group, enabled: false),

                  const Divider(height: 30),

                  const Text('Incident Details',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: EditIncidentScreen.primaryColor)),
                  _pickerButton(
                    label: "Select Date of Incident",
                    icon: Icons.date_range,
                    selectedDate: _incidentDate,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        initialDate: _incidentDate ?? DateTime.now(),
                      );
                      if (date != null) setState(() => _incidentDate = date);
                    },
                  ),
                  _pickerButton(
                    label: "Select Time of Incident",
                    icon: Icons.access_time,
                    selectedTime: _incidentTime,
                    onTap: () async {
                      final time = await showTimePicker(
                          context: context,
                          initialTime: _incidentTime ?? TimeOfDay.now());
                      if (time != null) setState(() => _incidentTime = time);
                    },
                  ),
                  _input("Location of Incident", _locationController, Icons.place),
                  _dropdown(
                    label: "Offense Type (Category)",
                    value: _offenseType,
                    items: const ["Minor Offense", "Major Offense"],
                    onChangedCallback: (val) {
                      setState(() {
                        _offenseType = val;
                        if (_offenseList[val] != null && !_offenseList[val]!.contains(_specificOffense)) {
                          _specificOffense = null;
                        }
                        _recommendationController.text = _getRecommendationPlaceholder(val); 
                      });
                    },
                  ),
                  if (_offenseType != null)
                    _dropdown(
                      label: "Specific Offense",
                      value: _specificOffense,
                      items: specificOffenses,
                      onChangedCallback: (val) => setState(() => _specificOffense = val),
                    ),
                  _input("Description", _descriptionController, Icons.description, maxLines: 4),

                  const Divider(height: 30),
                  const Text('Administrative Notes (Admin Only)', 
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  _dropdown(
                    label: "Current Status",
                    value: _status,
                    items: _statusOptions,
                    onChangedCallback: (val) => setState(() => _status = val),
                    enabled: _isAdmin, 
                  ),
                  _input("Recommendation/Sanction", _recommendationController, Icons.computer,
                      maxLines: 3, enabled: _isAdmin), 
                  _input("Final Action Taken", _actionTakenController, Icons.gavel,
                      maxLines: 3, enabled: _isAdmin),

                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: EditIncidentScreen.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
}