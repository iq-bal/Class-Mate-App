class UserEntity {
  final String? id; // Optional MongoDB or database-specific unique identifier
  final String? uid; // Optional user's unique identifier
  final String? name; // Optional user's name
  final String? email; // Optional user's email address
  final String? role; // Optional user's role (e.g., admin, user, etc.)

  // Constructor with optional named parameters
  UserEntity({
    this.id,
    this.uid,
    this.name,
    this.email,
    this.role,
  });

  // Factory method to create a UserEntity from a JSON object
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String?,
      uid: json['uid'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
    );
  }
}
