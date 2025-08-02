class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;

  // Constructor to initialize the fields
  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  }); 

  // Factory constructor to create a UserModel object from a JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['uid'], // Extracts 'id' from the JSON map
      email: json['email'], // Extracts 'email' from the JSON map
      name: json['name'], // Extracts 'name' from the JSON map
      role: json['role'], // Extracts 'role' from the JSON map
    );
  }

  // Method to convert a UserModel object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Returns the value of 'id'
      'email': email, // Returns the value of 'email'
      'name': name, // Returns the value of 'name'
      'role': role, // Returns the value of 'role'
    };
  }

}
