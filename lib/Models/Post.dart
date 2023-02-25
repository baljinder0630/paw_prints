import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  String? id;
  String? caption;
  String? imgUrl;
  String? userId;
  String? username;
  var timeStamp;
  List<dynamic>? likes = [];
  PostModel(
      {this.id,
      this.caption,
      this.imgUrl,
      this.timeStamp,
      this.userId,
      this.username,
      this.likes});

  PostModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    caption = map['caption'];
    imgUrl = map['imgUrl'];
    userId = map['userId'];
    username = map['username'];
    timeStamp = map['timeStamp'];
    likes = map['likes'];
  }
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "caption": caption,
      "imgUrl": imgUrl,
      "userId": userId,
      "username": username,
      "timeStamp": timeStamp,
      "likes": likes
    };
  }
}
