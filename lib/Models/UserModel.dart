import 'dart:ffi';

class UserModel {
  String? uid;
  String? email;
  late String username;
  String? avatar;

  UserModel({this.uid, this.email, required this.username, this.avatar});

  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map['uid'];
    email = map['email'];
    username = map['username'];
    avatar = map['avatar'];
  }
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "email": email,
      "username": username,
      "avatar": avatar,
    };
  }
}
