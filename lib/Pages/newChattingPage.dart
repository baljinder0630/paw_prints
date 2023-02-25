import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:paw_prints/Models/UserModel.dart';
import 'package:uuid/uuid.dart';

import 'Chatroom.dart';

class NewChattingPage extends StatefulWidget {
  var targetUserUid;
  NewChattingPage({required this.targetUserUid, Key? key}) : super(key: key);

  @override
  State<NewChattingPage> createState() => _NewChattingPageState();
}

class _NewChattingPageState extends State<NewChattingPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("User")
          .where("uid", isEqualTo: widget.targetUserUid)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
            UserModel targetUserModel = UserModel.fromMap(
                querySnapshot.docs[0].data() as Map<String, dynamic>);
            return Scaffold(
              appBar: AppBar(
                title: Text(targetUserModel.username.toString()),
              ),
              body: Column(
                children: [Text("data")],
              ),
            );
          }
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
