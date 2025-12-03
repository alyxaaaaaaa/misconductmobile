class Incident {
  final int? incidentId;

  final String studentId;
  final String fullName;
  final String program;
  final String yearLevel;
  final String section;

  final String dateOfIncident;
  final String timeOfIncident;
  final String location;
  final String offenseCategory;
  final String specificOffense;
  final String description;

  final String status;
  
  final String? recommendation; 
  final String? actionTaken;    
  
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
    
    this.recommendation, 
    this.actionTaken,
    
    this.createdAt,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    
    final String studentIdData = 
        json['student_id'] ??           
        json['student_id_number'] ??    
        json['studentId'] ??            
        '';

    return Incident(
      incidentId: json['id'] ?? json['incident_id'], 
      
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
      
      status: json['status'] ?? 'Pending',

      recommendation: json['recommendation'] as String?,
      actionTaken: json['action_taken'] as String?,
      
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
      'actionTaken': actionTaken, 
    };
  }
}