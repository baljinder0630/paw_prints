// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, prefer_const_literals_to_create_immutables, curly_braces_in_flow_control_structures, dead_code, prefer_is_empty

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:paw_prints/Models/UserModel.dart';
import 'package:paw_prints/Models/chatroomModel.dart';
import 'package:paw_prints/Models/firebaseHelper.dart';
import 'package:paw_prints/Pages/Chatroom.dart';

class AllChats extends StatefulWidget {
  AllChats({Key? key}) : super(key: key);

  @override
  State<AllChats> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<AllChats> {
  String currentUser = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return

        //
        //
        //
        Container(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: StreamBuilder(
            //stream will return snapshot
            stream: FirebaseFirestore.instance
                .collection("ChatRoom")
                .where(
                  "participants.${currentUser}",
                  isEqualTo: true,
                )
                .snapshots(),
            //
            //
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                log("Active Connection State");
                QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
                if (snapshot.hasData) {
                  log("Sanpshot contain data");
                  log(querySnapshot.docs.length.toString());

                  return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: querySnapshot.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        Chatroommodel chatroommodel = Chatroommodel.fromMap(
                            querySnapshot.docs[index].data()
                                as Map<String, dynamic>);
                        Map<String, dynamic>? participants =
                            chatroommodel.participants;
                        List<String> participantsKey =
                            participants!.keys.toList();
                        participantsKey.remove(currentUser);
                        //
                        //
                        //
                        //
                        return FutureBuilder<UserModel?>(
                            future: FirebaseHelper.getUserModelByID(
                                participantsKey[0]),
                            builder: (context, userdata) {
                              if (userdata.connectionState ==
                                  ConnectionState.done) {
                                if (userdata.data != null) {
                                  UserModel targetUser =
                                      userdata.data as UserModel;
                                  log("message");
                                  return Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100)),
                                    borderOnForeground: true,
                                    elevation: 8,
                                    child: Flexible(
                                      child: ListTile(
                                        tileColor:
                                        Theme.of(context).secondaryHeaderColor,
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return ChatRoom(
                                                TargetUser: targetUser,
                                                exitingChatModel:
                                                    chatroommodel);
                                          }));
                                        },
                                        leading: TextButton(
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    content: Card(
                                                      child: Image.network(
                                                          targetUser.avatar
                                                              .toString(),
                                                          fit: BoxFit.contain),
                                                    ),
                                                  );
                                                });
                                          },
                                          child: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                targetUser.avatar.toString()),
                                          ),
                                        ),
                                        title: Text(
                                            targetUser.username.toString()),
                                      ),
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              } else {
                                return Container();
                              }
                            });
                        return CircularProgressIndicator();
                      });
                  //
                  //
                  //
                  //

                } else {
                  return Text("No Data");
                }
              } else {
                return Text("No Data");
              }
              return CircularProgressIndicator();
            }),
      ),
    );
  }
}
