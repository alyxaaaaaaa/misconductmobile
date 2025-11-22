class Incident {
  final int? incidentId;

  // Student Information
  final String studentIdNumber;
  final String fullName;
  final String program;
  final String yearLevel;
  final String section;

  // Incident Information
  final String dateOfIncident;
  final String timeOfIncident;
  final String location;
  final String offenseCategory; // Minor / Major
  final String offenseType;     // Specific offense
  final String description;

  // System Information
  final int reporterId;
  final String status;
  final String? createdAt;

  Incident({
    this.incidentId,
    required this.studentIdNumber,
    required this.fullName,
    required this.program,
    required this.yearLevel,
    required this.section,
    required this.dateOfIncident,
    required this.timeOfIncident,
    required this.location,
    required this.offenseCategory,
    required this.offenseType,
    required this.description,
    required this.reporterId,
    required this.status,
    this.createdAt,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      incidentId: json['incident_id'],
      studentIdNumber: json['student_id_number'],
      fullName: json['full_name'],
      program: json['program'],
      yearLevel: json['year_level'],
      section: json['section'],
      dateOfIncident: json['date_of_incident'],
      timeOfIncident: json['time_of_incident'],
      location: json['location'],
      offenseCategory: json['offense_category'], 
      offenseType: json['offense_type'], 
      description: json['description'],
      reporterId: json['reporter_id'],
      status: json['status'] ?? 'Pending',
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'incident_id': incidentId,
      'student_id_number': studentIdNumber,
      'full_name': fullName,
      'program': program,
      'year_level': yearLevel,
      'section': section,
      'date_of_incident': dateOfIncident,
      'time_of_incident': timeOfIncident,
      'location': location,
      'offense_category': offenseCategory,
      'offense_type': offenseType,
      'description': description,
      'reporter_id': reporterId,
      'status': status,
      'created_at': createdAt,
    };
  }
}
