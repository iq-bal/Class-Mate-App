class StudentModel {
  final String id;
  final String email;
  final String name;
  final String roll;
  final String section;

  StudentModel({
    required this.id,
    required this.email,
    required this.name,
    required this.roll,
    required this.section,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id']?.toString() ?? '',
      roll: json['roll']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Returns the value of 'id'
      'email': email, // Returns the value of 'email'
      'name': name, // Returns the value of 'name'
      'roll': roll, // Returns the value of 'role'
      'section':section
    };
  }
}
