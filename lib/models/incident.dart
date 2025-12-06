class Incident {
  final int? incidentId;
  final String studentId;
  final String fullName;
  final String program;
  final String yearLevel;
  final String section;
  final String dateOfIncident; // yyyy-mm-dd
  final String timeOfIncident; // HH:mm
  final String location;
  final String offenseCategory;
  final String specificOffense;
  final String description;
  final String status;
  final String? recommendation;
  final String? actionTaken;

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
    this.recommendation,
    this.actionTaken,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      incidentId: json['incidentId'] ?? json['id'],
      studentId: json['studentId'] ?? json['student_id'] ?? '',
      fullName: json['fullName'] ?? json['full_name'] ?? '',
      program: json['program'] ?? '',
      yearLevel: json['yearLevel'] ?? json['year_level'] ?? '',
      section: json['section'] ?? '',
      dateOfIncident: json['dateOfIncident'] ?? json['date_of_incident'] ?? '',
      timeOfIncident: json['timeOfIncident'] ?? json['time_of_incident'] ?? '',
      location: json['location'] ?? '',
      offenseCategory: json['offenseCategory'] ?? json['offense_category'] ?? '',
      specificOffense: json['specificOffense'] ?? json['specific_offense'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      recommendation: json['recommendation'],
      actionTaken: json['actionTaken'] ?? json['action_taken'],
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
      'recommendation': recommendation,
      'actionTaken': actionTaken,
    };
  }
}
