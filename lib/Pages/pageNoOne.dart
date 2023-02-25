// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paw_prints/Models/UserModel.dart';
import 'package:paw_prints/Pages/PetDetail.dart';

import '../Models/petModel.dart';

class PageNoOne extends StatefulWidget {
  UserModel userModel;

  PageNoOne({required this.userModel, Key? key}) : super(key: key);

  @override
  State<PageNoOne> createState() => _PageZeroState();
}

class _PageZeroState extends State<PageNoOne> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextButton(onPressed: () {}, child: Text("Filter By location")),
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection("Pets").snapshots(),
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

                  QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: querySnapshot.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      PetModel petModel = PetModel.fromMap(
                          querySnapshot.docs[index].data()
                              as Map<String, dynamic>);
                      return InkWell(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: ((context) {
                            return PetDetail(petModel: petModel);
                          })));
                        },
                        child: petWidget(context, petModel, widget.userModel),
                      );
                    },
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget petWidget(context, PetModel petModel, UserModel userModel) {
  return Container(
    margin: EdgeInsets.all(8),
    decoration: BoxDecoration(
        // color: Colors.black
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).shadowColor,
              offset: Offset(1, 1),
              blurStyle: BlurStyle.outer,
              blurRadius: 2),
          BoxShadow(
              color: Theme.of(context).cardColor,
              offset: Offset(1, 1),
              blurStyle: BlurStyle.inner,
              blurRadius: 2)
        ]),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
              margin: EdgeInsets.only(left: 10),
              // width: 300,
              height: 50,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  petModel.name,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              )),
          Container(
            decoration: BoxDecoration(
                // borderRadius: BorderRadius.all(Radius.circular(8)),
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).shadowColor,
                      offset: Offset(1, 1),
                      blurStyle: BlurStyle.outer,
                      blurRadius: 2),
                  BoxShadow(
                      color: Theme.of(context).cardColor,
                      offset: Offset(1, 1),
                      blurStyle: BlurStyle.inner,
                      blurRadius: 2)
                ]),
            // height: 300,
            // width: 300,
            child: Image.network(petModel.pic.toString()),
          ),
          Container(
            height: 50,
            child: Wrap(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: petModel.likedBy!.contains(userModel.uid)
                          ? Icon(Icons.thumb_up, color: Colors.red)
                          : Icon(Icons.thumb_up_alt_outlined,
                              color: Colors.grey),
                      iconSize: 20,
                      onPressed: () async {
                        if (petModel.likedBy!.contains(userModel.uid)) {
                          log("Empty");
                          petModel.likedBy!.remove(userModel.uid);
                        } else {
                          log("non Empty");
                          petModel.likedBy!.add(userModel.uid);
                        }
                        await FirebaseFirestore.instance
                            .collection("Pets")
                            .doc(petModel.petId)
                            .set(petModel.toMap())
                            .whenComplete(() {
                          log("like/unlike");
                        });
                      },
                    ),
                    Text(
                      petModel.likedBy!.length == 0
                          ? ""
                          : petModel.likedBy!.length.toString(),
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ExpansionTile(
            childrenPadding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
            backgroundColor: Colors.blue.shade300,
            title: Text(
              "Description",
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
            expandedAlignment: Alignment.topLeft,
            children: [
              Text(
                petModel.description.toString(),
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          )
        ],
      ),
    ),
  );
}
