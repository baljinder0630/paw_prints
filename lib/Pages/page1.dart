// ignore_for_file: curly_braces_in_flow_control_structures, prefer_const_constructors

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paw_prints/Models/Post.dart';
import 'package:paw_prints/Models/UserModel.dart';
import 'package:paw_prints/Models/firebaseHelper.dart';
import 'package:paw_prints/Pages/AddPost.dart';
import 'package:paw_prints/Pages/postDetailPage.dart';

class PageOne extends StatefulWidget {
  UserModel userModel;

  PageOne({required this.userModel, Key? key}) : super(key: key);
  @override
  State<PageOne> createState() => _PageOneState();
}

class _PageOneState extends State<PageOne> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<QuerySnapshot>(
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
        floatingActionButton: FloatingActionButton(
          tooltip: "Add Post",
          child: Icon(Icons.add_a_photo_outlined),
          backgroundColor: Color(0xFF21899C),
          onPressed: (() {
            Navigator.push(context, MaterialPageRoute(builder: ((context) {
              return AddPost();
            })));
          }),
        ));
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
            backgroundImage: NetworkImage(postModel.imgUrl.toString()),
          ),
          title: Text(postModel.username.toString() == "" ? "No Title": postModel.username.toString()),
          subtitle: Text((postModel.timeStamp).toString()),
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
              icon: postModel.likes!.contains(usermodel)
                  ? Icon(Icons.thumb_up, color: Colors.red)
                  : Icon(Icons.thumb_up_alt_outlined, color: Colors.grey),
              iconSize: 20,
              onPressed: () async {
                if (postModel.likes!.contains(usermodel)) {
                  log("Empty");
                  postModel.likes!.remove(usermodel);
                } else {
                  log("non Empty");
                  postModel.likes!.add(usermodel);
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
              onPressed: () {},
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
