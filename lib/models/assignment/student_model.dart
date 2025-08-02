class StudentModel {
  final String id;
  final String name;
  final String roll;
  final String email;

  const StudentModel({
    required this.id,
    required this.name,
    required this.roll,
    required this.email,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      roll: json['roll'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}