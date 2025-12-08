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
  
  final int? categoryId; 
  final int? specificOffenseId;
  final int? programId; 

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
    this.categoryId,
    this.specificOffenseId,
    this.programId, 
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
      
      offenseCategory: json['offenseCategory'] ?? json['offense_category'] ?? json['category_name'] ?? '',
      specificOffense: json['specificOffense'] ?? json['specific_offense'] ?? json['offense_name'] ?? '',
      
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      recommendation: json['recommendation'],
      actionTaken: json['actionTaken'] ?? json['action_taken'],
      
      categoryId: json['category_id'],
      specificOffenseId: json['specific_offense_id'],
      programId: json['program_id'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'dateOfIncident': dateOfIncident,
      'timeOfIncident': timeOfIncident,
      'location': location,
      'description': description,
      'status': status,
      
      'offenseCategory': offenseCategory,
      'specificOffense': specificOffense,
      'program': program,
      
      'fullName': fullName,
      'yearLevel': yearLevel,
      'section': section.isEmpty ? null : section,
      'recommendation': recommendation == null || recommendation!.isEmpty ? null : recommendation,
      'actionTaken': actionTaken == null || actionTaken!.isEmpty ? null : actionTaken,
    };
  }
  
  Incident copyWith({
    int? incidentId,
    String? studentId,
    String? fullName,
    String? program,
    String? yearLevel,
    String? section,
    String? dateOfIncident,
    String? timeOfIncident,
    String? location,
    int? categoryId,
    int? specificOffenseId,
    int? programId,
    String? offenseCategory,
    String? specificOffense,
    String? description,
    String? status,
    String? recommendation,
    String? actionTaken,
  }) {
    return Incident(
      incidentId: incidentId ?? this.incidentId,
      studentId: studentId ?? this.studentId,
      fullName: fullName ?? this.fullName,
      program: program ?? this.program,
      yearLevel: yearLevel ?? this.yearLevel,
      section: section ?? this.section,
      dateOfIncident: dateOfIncident ?? this.dateOfIncident,
      timeOfIncident: timeOfIncident ?? this.timeOfIncident,
      location: location ?? this.location,
      categoryId: categoryId ?? this.categoryId,
      specificOffenseId: specificOffenseId ?? this.specificOffenseId,
      programId: programId ?? this.programId,
      offenseCategory: offenseCategory ?? this.offenseCategory,
      specificOffense: specificOffense ?? this.specificOffense,
      description: description ?? this.description,
      status: status ?? this.status,
      recommendation: recommendation ?? this.recommendation,
      actionTaken: actionTaken ?? this.actionTaken,
    );
  }
}