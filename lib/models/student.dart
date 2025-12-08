class Student {
  // studentId holds the unique student number/school ID (e.g., '24-5572')
  final String studentId;
  final String fullName;
  final String program_code; // Holds the Program Code/Short Name (e.g., 'BSIT')
  final String year_level;
  final String section;

  final int? id; // Database ID (optional)

  Student({
    this.id,
    required this.studentId,
    required this.fullName,
    required this.program_code,
    required this.year_level,
    required this.section,
  });
  
  // Empty constructor for initialization checks (optional but useful)
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
    // CRITICAL FIX: The backend uses 'student_id' (string) for the student number
    final String uniqueStudentNumber = 
        (json['student_id'] ?? json['student_number'] ?? json['id'])?.toString() ?? '';
    
    // Attempt to parse the primary database ID if available
    final int? databaseId = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');

    return Student(
      id: databaseId,
      studentId: uniqueStudentNumber, // Used for lookup and submission
      
      // Map display name (backend sends 'full_name')
      fullName: json['full_name'] ?? json['fullName'] ?? '',

      // Map remaining fields
      program_code: json['program_code'] ?? json['programCode'] ?? '',
      year_level: json['year_level'] ?? json['yearLevel'] ?? '',
      section: json['section'] ?? '',
    );
  }

  // Required for DropdownButtonFormField<Student> to compare and recognize items
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    // Compare two Student objects only by their unique studentId (student number).
    return other is Student && other.studentId == studentId;
  }

  // Required whenever operator == is overridden.
  @override
  int get hashCode => studentId.hashCode;
}