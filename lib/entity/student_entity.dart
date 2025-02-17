class StudentEntity {
  final String? id;
  final String? name;
  final String? email;
  final String? roll;
  final String? section;
  final String? profilePicture;

  const StudentEntity({
    this.id,
    this.name,
    this.email,
    this.roll,
    this.section,
    this.profilePicture,
  });

  factory StudentEntity.fromJson(Map<String, dynamic> json) {
    return StudentEntity(
      id: json['id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      roll: json['roll'] as String?,
      section: json['section'] as String?,
      profilePicture: json['profile_picture'] as String?,
    );
  }
}
