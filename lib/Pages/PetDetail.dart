// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paw_prints/Models/UserModel.dart';
import 'package:paw_prints/Models/chatroomModel.dart';
import 'package:paw_prints/Models/firebaseHelper.dart';
import 'package:paw_prints/Models/petModel.dart';
import 'package:uuid/uuid.dart';

import 'Chatroom.dart';

class PetDetail extends StatefulWidget {
  PetModel petModel;
  PetDetail({required this.petModel, Key? key}) : super(key: key);

  @override
  State<PetDetail> createState() => _BuyPageState();
}

class _BuyPageState extends State<PetDetail> {
  var ChatRoomId = Uuid().v1();
  var currentUser = FirebaseAuth.instance.currentUser!.uid.toString();
  //
  void Chatroompage(targetuser, chatroommodel) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ChatRoom(
        TargetUser: targetuser,
        exitingChatModel: chatroommodel,
      );
    }));
  }

//
  Future<Chatroommodel?> getchatRoombyId(targetUser) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("ChatRoom")
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .where("participants.${currentUser}", isEqualTo: true)
        .get();
    print(snapshot.docs.length);
    if (snapshot.docs.length > 0) {
      //chat room Already Exits

// fetching the chatroomodel
      var Docdata = snapshot.docs[0].data();
      Chatroommodel ExistingChatModel =
          Chatroommodel.fromMap(Docdata as Map<String, dynamic>);

      //navigator to chatrrom page

      Chatroompage(targetUser, ExistingChatModel);
      log("ChatRoom Exits");
    } else {
      //Make NEw Chatroom
      Chatroommodel newchatroom = Chatroommodel(
          participants: {targetUser.uid: true, currentUser: true},
          chatroomuid: ChatRoomId,
          lastmessage: "");

      log("Create a new chatroom");

      await FirebaseFirestore.instance
          .collection("ChatRoom")
          .doc(ChatRoomId)
          .set(newchatroom.toMap())
          .then((value) => log("ChatRoom Created"))
          .onError((error, stackTrace) => print(error));
      Chatroompage(targetUser, newchatroom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    Container(
                        margin: EdgeInsets.only(top: 30),
                        width: 200,
                        child: Card(
                            child:
                                Image.network(widget.petModel.pic.toString()))),
                    Text(widget.petModel.description.toString(),
                        style: TextStyle(color: Colors.grey)),
                    Text(widget.petModel.dob.toString(),
                        style: TextStyle(color: Colors.grey)),
                    Text(widget.petModel.likedBy!.length.toString(),
                        style: TextStyle(color: Colors.grey)),
                    Text(widget.petModel.sellingBy.toString(),
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            widget.petModel.sellingBy.toString() !=
                    FirebaseAuth.instance.currentUser!.uid
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () async {
                              UserModel? targetUserModel =
                                  await FirebaseHelper.getUserModelByID(
                                      widget.petModel.sellingBy.toString());
                              await getchatRoombyId(targetUserModel);
                            },
                            child: Container(
                              child: Center(
                                  child: Text("Message",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                          color: Colors.white))),
                              width: MediaQuery.of(context).size.width / 2,
                              color: Colors.green,
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 2,
                            color: Colors.blue,
                            child: Center(
                                child: Text("Adopt",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25,
                                        color: Colors.white))),
                          )
                        ],
                      ),
                      // color: Colors.red,
                    ),
                  )
                : SizedBox()
          ],
        ));
  }
}
