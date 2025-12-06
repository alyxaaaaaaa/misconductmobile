// lib/models/student.dart

class Student {
  // studentId holds the unique student number/school ID
  final String studentId;
  final String fullName;
  final String program;
  final String yearLevel;
  final String section;

  final int? id; // Database ID

  Student({
    this.id,
    required this.studentId,
    required this.fullName,
    required this.program,
    required this.yearLevel,
    required this.section,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    // Map the API's unique 'id' field to the model's studentId, ensuring string type.
    final apiUniqueId = (json['id'] ?? json['student_number'])?.toString() ?? '';

    return Student(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      studentId: apiUniqueId,

      // Map display name
      fullName: json['fullName'] ?? json['full_name'] ?? '',

      // Map remaining fields
      program: json['program'] ?? '',
      yearLevel: json['yearLevel'] ?? json['year_level'] ?? '',
      section: json['section'] ?? '',
    );
  }

  // 🚀 FIX 1: Implement the equality operator (==)
  // Essential for DropdownButtonFormField<Student> to recognize list items.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    // Compare two Student objects only by their unique studentId.
    return other is Student && other.studentId == studentId;
  }

  // 🚀 FIX 2: Implement the hashCode getter
  // Required whenever operator == is overridden.
  @override
  int get hashCode => studentId.hashCode;
}