class TeacherModel {
  final String id;
  final String name;
  final String profilePicture;

  const TeacherModel({
    required this.id,
    required this.name,
    required this.profilePicture,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      profilePicture: json['profile_picture'] as String? ?? '',
    );
  }
}