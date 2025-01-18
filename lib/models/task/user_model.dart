import 'package:classmate/entity/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    super.id,
    super.name,
    super.profilePicture,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      profilePicture: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {

    return {
      'id': id,
      'name': name,
      'profilePicture': profilePicture,
    };
  }

}
