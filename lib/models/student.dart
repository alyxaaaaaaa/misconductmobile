class Student {
  final String studentId;
  final String fullName;
  final String program_code;
  final String year_level;
  final String section;

  final int? id; 

  Student({
    this.id,
    required this.studentId,
    required this.fullName,
    required this.program_code,
    required this.year_level,
    required this.section,
  });
  
  factory Student.empty() {
    return Student(
      studentId: '',
      fullName: '',
      program_code: '',
      year_level: '',
      section: '',
    );
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    final String uniqueStudentNumber = 
        (json['student_id'] ?? json['student_number'] ?? json['id'])?.toString() ?? '';
    
    final int? databaseId = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');

    return Student(
      id: databaseId,
      studentId: uniqueStudentNumber, 
      
      fullName: json['full_name'] ?? json['fullName'] ?? '',

      program_code: json['program_code'] ?? json['programCode'] ?? '',
      year_level: json['year_level'] ?? json['yearLevel'] ?? '',
      section: json['section'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Student && other.studentId == studentId;
  }

  @override
  int get hashCode => studentId.hashCode;
}