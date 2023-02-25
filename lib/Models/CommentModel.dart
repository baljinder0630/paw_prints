import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  String? comment;
  Timestamp? time;
  String? createdByUid;
  String? createdByUsername;
  String? createdByPic;
  String? postId;

  CommentModel(
      {required this.comment,
      required this.createdByUid,
      required this.createdByUsername,
      required this.createdByPic,
      required this.time,
      required this.postId});

  CommentModel.fromMap(Map<String, dynamic> map) {
    comment = map["comment"];
    time = map["time"];
    createdByUid = map["createdByUid"];
    createdByPic = map["createdByPic"];
    createdByUsername = map["createdByUsername"];
    postId = map["postId"];
  }
  Map<String, dynamic> toMap() {
    return {
      "comment": comment,
      "time": time,
      "createdByUid": createdByUid,
      "createdByPic": createdByPic,
      "createdByUsername": createdByUsername,
      "postId": postId
    };
  }
}
