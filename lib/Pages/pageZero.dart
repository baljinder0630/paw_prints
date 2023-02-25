// ignore_for_file: curly_braces_in_flow_control_structures, prefer_const_constructors

import 'dart:developer';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paw_prints/Models/Post.dart';
import 'package:paw_prints/Models/UserModel.dart';
import 'package:paw_prints/Models/firebaseHelper.dart';
import 'package:paw_prints/Pages/postDetailPage.dart';

class PageNoZero extends StatefulWidget {
  UserModel userModel;

  PageNoZero({required this.userModel, Key? key}) : super(key: key);
  @override
  State<PageNoZero> createState() => _PageOneState();
}

class _PageOneState extends State<PageNoZero> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                  margin: EdgeInsets.only(top: 10.0),
                  width: double.infinity,
                  child: CarouselSlider(
                    items: [
                      Card(
                        margin: EdgeInsets.all(0.0),
                        child: Image.asset("assets/Pet1.jpg", fit: BoxFit.cover),
                      ),
                      Card(
                        margin: EdgeInsets.all(0.0),
                        child: Image.asset("assets/Pet2.png", fit: BoxFit.cover),
                      ),
                      Card(
                        margin: EdgeInsets.all(0.0),
                        child: Image.asset("assets/Pet3.jpg", fit: BoxFit.cover),
                      ),
                      Card(
                        margin: EdgeInsets.all(0.0),
                        child: Image.asset("assets/Pet4.jpg", fit: BoxFit.cover),
                      ),
                      Card(
                        margin: EdgeInsets.all(0.0),
                        child: Image.asset("assets/Pet5.jpg", fit: BoxFit.cover),
                      ),
                    ],
                    options: CarouselOptions(
                      autoPlay: true,
                      enlargeCenterPage: true,
                    ),
                  ),
                ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .orderBy('timeStamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }
                  if (snapshot.hasData) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        log((querySnapshot.docs[index].data() as Map<String, dynamic>)
                            .toString());
                        PostModel postModel = PostModel.fromMap(
                            querySnapshot.docs[index].data() as Map<String, dynamic>);
                        return postWidget(context, postModel, widget.userModel);
                      },
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget postWidget(context, PostModel postModel, UserModel usermodel) {
  return Card(
    margin: EdgeInsets.all(5),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundImage: postModel.createdByAvatar.toString() != ""
                ? NetworkImage(postModel.createdByAvatar.toString())
                : null,
            foregroundImage: usermodel.avatar == ""
                ? AssetImage('assets/userImage.jpg')
                : null,
          ),
          title: Text(postModel.username.toString() == ""
              ? "<No Title>"
              : postModel.username.toString()),
          subtitle: DateTime.now()
                      .difference(
                          DateTime.tryParse(postModel.createdTime.toString())!)
                      .inDays >
                  0
              ? Text(DateTime.now()
                      .difference(
                          DateTime.tryParse(postModel.createdTime.toString())!)
                      .inDays
                      .toString() +
                  "days ago")
              : DateTime.now().difference(DateTime.tryParse(postModel.createdTime.toString())!).inHours >
                      0
                  ? Text(DateTime.now()
                          .difference(DateTime.tryParse(
                              postModel.createdTime.toString())!)
                          .inHours
                          .toString() +
                      "hrs ago")
                  : DateTime.now()
                              .difference(
                                  DateTime.tryParse(postModel.createdTime.toString())!)
                              .inMinutes >
                          0
                      ? Text(DateTime.now().difference(DateTime.tryParse(postModel.createdTime.toString())!).inMinutes.toString() + "mins ago")
                      : Text(DateTime.now().difference(DateTime.tryParse(postModel.createdTime.toString())!).inSeconds.toString() + "sec ago"),
        ),
        InkWell(
            onTap: (() =>
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return PostDetail(postModel: postModel);
                }))),
            child: Image.network(postModel.imgUrl.toString())),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(postModel.caption.toString()),
        ),
        Row(
          children: [
            IconButton(
              icon: postModel.likes!.contains(usermodel.uid)
                  ? Icon(Icons.thumb_up, color: Colors.red)
                  : Icon(Icons.thumb_up_alt_outlined, color: Colors.grey),
              iconSize: 20,
              onPressed: () async {
                if (postModel.likes!.contains(usermodel.uid)) {
                  log("Empty");
                  postModel.likes!.remove(usermodel.uid);
                } else {
                  log("non Empty");
                  postModel.likes!.add(usermodel.uid);
                }
                await FirebaseFirestore.instance
                    .collection("posts")
                    .doc(postModel.id)
                    .set(postModel.toMap())
                    .whenComplete(() {
                  log("like/unlike");
                });
              },
            ),
            Text(
              postModel.likes!.length == 0
                  ? ""
                  : postModel.likes!.length.toString(),
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return PostDetail(postModel: postModel);
                }));
              },
              icon: Icon(Icons.insert_comment_rounded),
              color: Colors.grey,
              highlightColor: Colors.transparent,
              splashColor: Colors.cyan,
            )
          ],
        ),
      ],
    ),
  );
}
