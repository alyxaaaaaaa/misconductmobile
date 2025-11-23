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
  final String offenseCategory;
  final String specificOffense;
  final String description;

  // System Information
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
    required this.status,
    this.createdAt,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {

    final String studentIdData = 
        json['student_id'] ??           // 1. Check for Laravel's database column name
        json['student_id_number'] ??    // 2. Check for your old mapping/API name
        json['studentId'] ??            // 3. Check for camelCase key
        '';

    return Incident(
      incidentId: json['incident_id'],
      
      // FIX: Use ?? '' fallback for ALL non-nullable String fields
      studentId: studentIdData.toString(),
      fullName: json['full_name'] ?? '',
      program: json['program'] ?? '',
      yearLevel: json['year_level'] ?? '',
      section: json['section'] ?? '',
      
      dateOfIncident: json['date_of_incident'] ?? '',
      timeOfIncident: json['time_of_incident'] ?? '',
      location: json['location'] ?? '',
      offenseCategory: json['offense_category'] ?? '',
      specificOffense: json['specific_offense'] ?? '',
      description: json['description'] ?? '',
      
      // Status can default to 'Pending' if null
      status: json['status'] ?? 'Pending',
      
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'fullName': fullName,
      'program': program,
      'yearLevel': yearLevel,
      'section': section,
      'dateOfIncident': dateOfIncident,
      'timeOfIncident': timeOfIncident,
      'location': location,
      'offenseCategory': offenseCategory,
      'specificOffense': specificOffense,
      'description': description,
      'status': status,
    };
  }
}