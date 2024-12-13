class AssignmentModel{
  final String id;
  final String title;
  final String description;
  final String deadline;
  final String createdAt;
  
  AssignmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.createdAt
  });

  // Factory constructor to create a UserModel object from a JSON map
  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'], // Extracts 'id' from the JSON map
      title: json['title'], // Extracts 'email' from the JSON map
      description: json['description'], // Extracts 'name' from the JSON map
      deadline: json['deadline'], // Extracts 'role' from the JSON map
      createdAt: json['created_at']
    );
  }
}