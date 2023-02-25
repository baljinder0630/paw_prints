// ignore_for_file: prefer_is_empty, prefer_const_constructors

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:paw_prints/Models/CommentModel.dart';
import 'package:paw_prints/Models/Post.dart';

class PostDetail extends StatefulWidget {
  PostModel postModel;
  PostDetail({required this.postModel, Key? key}) : super(key: key);

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  final _focusNode = FocusNode();
  final _commentController = TextEditingController();
  final focusScopeNode = FocusScopeNode();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
             title: const Text('Comments'),
           ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {
            focusScopeNode.unfocus();
          },
          child: FocusScope(
            node: focusScopeNode,
            child: Form(
              key: _formKey,
              child: SafeArea(
                child: Column(children: [
                  // Scaffold(
                  //   appBar: AppBar(
                  //     title: const Text('Comments'),
                  //   ),
                  // ),
                  Container(
                    child: Image.network(widget.postModel.imgUrl.toString()),
                  ),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Colors.amber.shade800,
                          Colors.amber.shade700,
                          Colors.amber.shade600,
                          Colors.amber.shade500
                        ]
                      )
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: widget.postModel.likes!.contains(
                                  FirebaseAuth.instance.currentUser!.uid)
                              ? Icon(Icons.thumb_up, color: Colors.red)
                              : Icon(Icons.thumb_up_alt_outlined,
                                  color: Colors.black),
                          iconSize: 20,
                          onPressed: () async {
                            if (widget.postModel.likes!.contains(
                                FirebaseAuth.instance.currentUser!.uid)) {
                              log("Empty");
                              widget.postModel.likes!.remove(
                                  FirebaseAuth.instance.currentUser!.uid);
                            } else {
                              log("non Empty");
                              widget.postModel.likes!
                                  .add(FirebaseAuth.instance.currentUser!.uid);
                            }
                            await FirebaseFirestore.instance
                                .collection("posts")
                                .doc(widget.postModel.id)
                                .set(widget.postModel.toMap())
                                .whenComplete(() {
                              log("like/unlike");
                              setState(() {});
                            });
                          },
                        ),
                        Text(
                          widget.postModel.likes!.length == 0
                              ? ""
                              : widget.postModel.likes!.length.toString(),
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                        IconButton(
                          onPressed: () {
                            FocusScope.of(context).requestFocus(_focusNode);
                          },
                          icon: Icon(Icons.insert_comment_rounded),
                          color: Colors.black,
                          highlightColor: Colors.transparent,
                          splashColor: Colors.cyan,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    style: TextStyle(color: Colors.white),
                    maxLength: 100,
                    focusNode: _focusNode,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    controller: _commentController,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        color: Colors.white,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              log("Comment state validated");
                              CommentModel commentModel = CommentModel(
                                  createdByPic: FirebaseAuth
                                      .instance.currentUser!.photoURL,
                                  createdByUsername: FirebaseAuth
                                      .instance.currentUser!.displayName,
                                  comment: _commentController.text.trim(),
                                  createdByUid:
                                      FirebaseAuth.instance.currentUser!.uid,
                                  time: Timestamp.now(),
                                  postId: widget.postModel.id);

                              try {
                                await FirebaseFirestore.instance
                                    .collection("Comments")
                                    .add(commentModel.toMap())
                                    .whenComplete(() {
                                  log("Comment added");
                                  _commentController.clear();
                                });
                              } on FirebaseException catch (e) {
                                // TODO
                                log(e.code);
                              }
                            }
                          },
                          icon: Icon(
                            Icons.send,
                            color: Colors.white,
                          )),
                      prefixIcon: Icon(Icons.comment_bank_outlined),
                      hintText: "Add Comment",
                      filled: true,
                      fillColor: Colors.black,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(80.0),
                          ),
                          borderSide: BorderSide(color: Colors.teal)),
                    ),
                  ),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("Comments")
                        .where("postId", isEqualTo: widget.postModel.id)
                        .snapshots(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      QuerySnapshot querySnapshot =
                          snapshot.data as QuerySnapshot;
                      if (querySnapshot.size > 0) {
                        return ListView.builder(
                          reverse: true,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: querySnapshot.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            CommentModel commentModel = CommentModel.fromMap(
                                querySnapshot.docs[index].data()
                                    as Map<String, dynamic>);
                            return Container(
                              child: Column(
                                children: [
                                  Text(commentModel.createdByUsername
                                      .toString()),
                                  Text(commentModel.comment.toString()),
                                  (DateTime.now()
                                              .difference(
                                                  commentModel.time!.toDate())
                                              .inHours >
                                          0
                                      ? Text(DateTime.now()
                                              .difference(
                                                  commentModel.time!.toDate())
                                              .inHours
                                              .toString() +
                                          "h")
                                      : DateTime.now()
                                                  .difference(commentModel.time!
                                                      .toDate())
                                                  .inMinutes >
                                              0
                                          ? Text(DateTime.now()
                                                  .difference(commentModel.time!
                                                      .toDate())
                                                  .inMinutes
                                                  .toString() +
                                              "mins")
                                          : Text(DateTime.now()
                                                  .difference(commentModel.time!
                                                      .toDate())
                                                  .inSeconds
                                                  .toString() +
                                              "sec")),
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        commentModel.createdByPic.toString()),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  )
                                ],
                              ),
                            );
                          },
                        );
                      } else if (querySnapshot.size == 0) {
                        return Text("Empty");
                      }

                      return Container(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
