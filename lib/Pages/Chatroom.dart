// ignore_for_file: prefer_typing_uninitialized_variables, non_constant_identifier_names, prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_local_variable, unnecessary_null_comparison, unused_element, prefer_is_empty, avoid_unnecessary_containers, unnecessary_import, await_only_futures

import 'dart:async';
import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:paw_prints/Models/UserModel.dart';
import 'package:paw_prints/Models/chatroomModel.dart';
import 'package:paw_prints/Models/chattingModel.dart';
import 'package:uuid/uuid.dart';

class ChatRoom extends StatefulWidget {
  final UserModel TargetUser;

  final Chatroommodel exitingChatModel;

  ChatRoom({Key? key, required this.TargetUser, required this.exitingChatModel})
      : super(key: key);

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  @override
  Widget build(BuildContext context) {
    //
    var uuid = Uuid().v4();
    TextEditingController msgcontroller = TextEditingController();
    String currentUser = FirebaseAuth.instance.currentUser!.uid.toString();
    String TargetUserImage = widget.TargetUser.avatar.toString();
    String TargetUserName = widget.TargetUser.username.toString();
    //

    //
    void SendMessage() async {
      String msg = msgcontroller.text.trim().toString();
      if (msg != null) {
        Chattingmodel chattingModel = await Chattingmodel(
            seen: false,
            sendOn: DateTime.now().toLocal().microsecondsSinceEpoch.toString(),
            sendtime: DateFormat('kk:mm').format(DateTime.now()),
            messageId:
                DateTime.now().toLocal().microsecondsSinceEpoch.toString(),
            lastmessage: msg,
            sender: currentUser);
        //
        //
        FirebaseFirestore.instance
            .collection("ChatRoom")
            .doc(widget.exitingChatModel.chatroomuid.toString())
            .collection("Messages")
            .doc(chattingModel.messageId)
            .set(chattingModel.toMap())
            .then((value) => log("message sent"))
            .onError((error, stackTrace) => log(error.toString()));
        msgcontroller.clear();
      }
    }

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 88,
        leading: Row(
          children: [
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.navigate_before_outlined)),
            CircleAvatar(
                radius: 20,
                backgroundColor: Colors.black,
                child: CircleAvatar(
                    radius: 19,
                    backgroundImage: NetworkImage(TargetUserImage))),
          ],
        ),
        title: Text(
          TargetUserName,
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("ChatRoom")
                  .doc(widget.exitingChatModel.chatroomuid)
                  .collection("Messages")
                  .orderBy("sendOn", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                //
                //
                if (snapshot.connectionState == ConnectionState.active) {
                  QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
                  if (!snapshot.hasData) {
                    return Text("data loading");
                  }
                  if (snapshot.hasData) {
                    //
                    //
                    return ListView.builder(
                      reverse: true,
                      itemCount: querySnapshot.docs.length,
                      itemBuilder: (context, index) {
                        log("message1");
                        Chattingmodel ChattingModel = Chattingmodel.fromMap(
                            querySnapshot.docs[index].data()
                                as Map<String, dynamic>);
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment:
                                (ChattingModel.sender == currentUser)
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                      color: (ChattingModel.sender == currentUser)
                                          ? Colors.blue
                                          : Colors.grey.shade700,
                                      borderRadius: (ChattingModel.sender ==
                                              currentUser)
                                          ? BorderRadius.only(
                                              topLeft: BorderRadius.circular(20)
                                                  .topLeft,
                                              bottomLeft: BorderRadius.circular(20)
                                                  .bottomLeft,
                                              bottomRight: BorderRadius.circular(20)
                                                  .bottomRight)
                                          : BorderRadius.only(
                                              topRight: BorderRadius.circular(20)
                                                  .topRight,
                                              bottomLeft: BorderRadius.circular(20)
                                                  .bottomLeft,
                                              bottomRight:
                                                  BorderRadius.circular(20)
                                                      .bottomRight)),
                                  child: Row(
                                    children: [
                                      TextButton(
                                        onPressed: () {},
                                        child: Text(
                                            ChattingModel.lastmessage
                                                .toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                            )),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 16.0, right: 4),
                                        child: Text(
                                          ChattingModel.sendtime.toString(),
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 181, 189, 194)),
                                        ),
                                      )
                                    ],
                                  )),
                            ],
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                          "An error occured! Please check your internet connection."),
                    );
                  } else {
                    return Container();
                  }
                } else {
                  return Container();
                }
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 80,
              child: Center(
                child: ListTile(
                  title: TextField(
                    controller: msgcontroller,
                    maxLines: null,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40))),
                  ),
                  trailing: IconButton(
                      onPressed: () {
                        if (msgcontroller.text.isNotEmpty) SendMessage();
                      },
                      icon: Icon(
                        Icons.send,
                        color: Colors.blue,
                        size: 30,
                      )),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
