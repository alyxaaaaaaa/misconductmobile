// lib/models/user.dart
class User {
  final String fullName;
  final String email;
  final String profilePicturePath; // Path or URL to the existing image

  User({
    required this.fullName,
    required this.email,
    this.profilePicturePath = '', // Default to an empty string
  });

  /// Factory constructor for creating a User from a JSON map.
  factory User.fromJson(Map<String, dynamic> json) {
    final name = json['fullName'] as String? ?? 
                 json['full_name'] as String? ?? 
                 json['name'] as String?;

    final email = json['email'] as String? ?? 
                  json['emailAddress'] as String?;

    final picturePath = json['profile_picture_url'] as String? ??
                        json['profile_picture_path'] as String? ??
                        json['profile_image_url'] as String? ??
                        ''; // Default to empty string

    return User(
      fullName: name ?? 'N/A', 
      email: email ?? 'N/A',
      profilePicturePath: picturePath,
    );
  }
}