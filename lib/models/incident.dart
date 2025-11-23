class Incident {
  final int? incidentId;

  // Student Information
  final String studentId;
  final String fullName;
  final String program;
  final String yearLevel;
  final String section;

  // Incident Information
  final String dateOfIncident;
  final String timeOfIncident;
  final String location;
  final String offenseCategory; // Minor / Major
  final String specificOffense;     // Specific offense
  final String description;

  // System Information
  // final int reporterId; // This field is commented out in your model now.
  final String status;
  final String? createdAt;

  Incident({
    this.incidentId,
    required this.studentId,
    required this.fullName,
    required this.program,
    required this.yearLevel,
    required this.section,
    required this.dateOfIncident,
    required this.timeOfIncident,
    required this.location,
    required this.offenseCategory,
    required this.specificOffense,
    required this.description,
    // required this.reporterId,
    required this.status,
    this.createdAt,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    // Keep snake_case for receiving data (or adjust if your API returns camelCase)
    return Incident(
      incidentId: json['incident_id'],
      studentId: json['student_id_number'],
      fullName: json['full_name'],
      program: json['program'],
      yearLevel: json['year_level'],
      section: json['section'],
      dateOfIncident: json['date_of_incident'],
      timeOfIncident: json['time_of_incident'],
      location: json['location'],
      offenseCategory: json['offense_category'], 
      specificOffense: json['specific_offense'], 
      description: json['description'],
      // reporterId: json['reporter_id'],
      status: json['status'] ?? 'Pending',
      createdAt: json['created_at'],
    );
  }

  // CRITICAL CHANGE: Sending camelCase keys to satisfy backend validation
  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,           // Changed 'student_id_number' to 'studentId'
      'fullName': fullName,             // Changed 'full_name' to 'fullName'
      'program': program,
      'yearLevel': yearLevel,           // Changed 'year_level' to 'yearLevel'
      'section': section,
      'dateOfIncident': dateOfIncident, // Changed 'date_of_incident' to 'dateOfIncident'
      'timeOfIncident': timeOfIncident, // Changed 'time_of_incident' to 'timeOfIncident'
      'location': location,
      'offenseCategory': offenseCategory,
      'specificOffense': specificOffense, // Changed 'specific_offense' to 'specificOffense'
      'description': description,
      // 'reporterId': reporterId,         // Commented out to match your model changes
      'status': status,
      // 'incident_id': incidentId,      // Usually not sent on creation
      // 'created_at': createdAt,        // Usually not sent on creation
    };
  }
}