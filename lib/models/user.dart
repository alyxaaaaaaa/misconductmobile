class User {
  final String fullName;
  final String email;
  // studentId field has been removed

  User({
    required this.fullName,
    required this.email,
  });

  // Helper function to safely extract and convert a value to String
  static String? _safelyExtractString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) {
        if (value is String) {
          return value;
        } else if (value is int) {
          return value.toString(); // <--- Handles integer conversion
        }
      }
    }
    return null;
  }

  // Factory constructor for creating a User from a JSON map (e.g., from an API response)
  factory User.fromJson(Map<String, dynamic> json) {
    
    // Attempting to match the exact keys used by your server
    
    final name = _safelyExtractString(json, ['fullName', 'full_name', 'name']);
    
    // Student ID extraction logic removed
    
    return User(
      // Final fallback to 'N/A' if all key attempts fail
      fullName: name ?? 'N/A', 
      
      // Email check remains simple as it was mostly working
      email: json['email'] as String? ?? json['emailAddress'] as String? ?? 'N/A',
      
      // studentId field assignment removed
    );
  }
}