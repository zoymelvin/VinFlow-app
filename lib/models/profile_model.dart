class ProfileModel {
  final String name;
  final String email;
  final String phone;
  final String country;
  final String bio;
  final String profileImageUrl;

  ProfileModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.country,
    required this.bio,
    required this.profileImageUrl,
  });

  factory ProfileModel.fromFirestore(Map<String, dynamic> data) {
    return ProfileModel(
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      country: data['country'] ?? '',
      bio: data['bio'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
    );
  }
}