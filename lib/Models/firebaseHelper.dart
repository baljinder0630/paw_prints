// ignore_for_file: unnecessary_null_comparison, unnecessary_brace_in_string_interps, prefer_is_empty, non_constant_identifier_names

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paw_prints/Models/UserModel.dart';

import 'chatroomModel.dart';

class FirebaseHelper {
  // Storing current user when entering app
  static late UserModel currentAppUser;

  // getting user Model from uid
  static Future<UserModel> getUserModelByID(String Uid) async {
    UserModel? usermodel;
    DocumentSnapshot docSnap =
        await FirebaseFirestore.instance.collection("User").doc(Uid).get();
    if (docSnap != null) {
      usermodel = UserModel.fromMap(docSnap.data() as Map<String, dynamic>);
    }
    return usermodel!;
  }

  // static void Chatroompage(targetuser, chatroommodel, context) {
  //   Navigator.pop(context);
  //   Navigator.push(context, MaterialPageRoute(builder: (context) {
  //     return chatroom (
  //       TargetUser: targetuser,
  //       exitingChatModel: chatroommodel,
  //     );
  //   }));
  // }

  // Creating chatroom
  static Future<Chatroommodel?> getchatRoombyId(targetUser, context) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("ChatRoom")
        .where("particpants.${targetUser.uid}", isEqualTo: true)
        .where("particpants.${currentAppUser}", isEqualTo: true)
        .get();
    print(snapshot.docs.length);
    if (snapshot.docs.length > 0) {
      //chat room Already Exits

// fetching the chatroomodel
      var Docdata = snapshot.docs[0].data();
      Chatroommodel ExistingChatModel =
          Chatroommodel.fromMap(Docdata as Map<String, dynamic>);

      //navigator to chatrrom page

      // Chatroompage(targetUser, ExistingChatModel);
      log("ChatRoom Exits");
    } else {
      //Make NEw Chatroom
      Chatroommodel newchatroom = Chatroommodel(
          participants: {targetUser.uid: true, currentAppUser.uid!: true},
          chatroomuid: "qwerty",
          lastmessage: "");

      log("Create a new chatroom");

      await FirebaseFirestore.instance
          .collection("ChatRoom")
          .doc("qwerty")
          .set(newchatroom.toMap())
          .then((value) => log("ChatRoom Created"))
          .onError((error, stackTrace) => print(error));
      // Chatroompage (targetUser, newchatroom, context);
    }
  }
}
