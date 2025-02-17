class TeacherEntity {
  final String? id;
  final String? userId;
  final String? name;  // Added name field for teacher's name
  final String? department;
  final String? designation;
  final DateTime? joiningDate;
  final DateTime? createdAt;

  final String? profilePicture;


  const TeacherEntity({
    this.id,
    this.userId,
    this.name,
    this.department,
    this.designation,
    this.joiningDate,
    this.createdAt,
    this.profilePicture,

  });

  // Factory method to create a TeacherEntity from JSON
  factory TeacherEntity.fromJson(Map<String, dynamic> json) {
    return TeacherEntity(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      name: json['name'] as String?,  // Extract the teacher's name from the JSON
      department: json['department'] as String?,
      designation: json['designation'] as String?,
      joiningDate: json['joining_date'] != null
          ? DateTime.parse(json['joining_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      profilePicture: json['profile_picture'] as String?,
    );
  }
}
