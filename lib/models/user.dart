class User {
  final String fullName;
  final String email;
  final String profilePicturePath; 

  User({
    required this.fullName,
    required this.email,
    this.profilePicturePath = '', 
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final name = json['fullName'] as String? ?? 
                 json['full_name'] as String? ?? 
                 json['name'] as String?;

    final email = json['email'] as String? ?? 
                  json['emailAddress'] as String?;

    final picturePath = json['profile_picture_url'] as String? ??
                        json['profile_picture_path'] as String? ??
                        json['profile_image_url'] as String? ??
                        ''; 

    return User(
      fullName: name ?? 'N/A', 
      email: email ?? 'N/A',
      profilePicturePath: picturePath,
    );
  }
}