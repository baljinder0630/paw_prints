import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paw_prints/Models/UserModel.dart';
import 'package:paw_prints/Models/petModel.dart';

class ProfilePage extends StatefulWidget {
  UserModel userModel;

  ProfilePage({required this.userModel, Key? key}) : super(key: key);
  @override
  State<ProfilePage> createState() => _PageTwoState();
}

class _PageTwoState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              CircleAvatar(
                radius: 50,
                backgroundImage: widget.userModel.avatar != ""
                    ? NetworkImage(
                        widget.userModel.avatar.toString(),
                      )
                    : null,
                foregroundImage: widget.userModel.avatar == ""
                    ? AssetImage('assets/userImage.jpg')
                    : null,
              ),
              Text(
                widget.userModel.username.toString(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "For Donation",
                          style: TextStyle(
                              color: Colors.amber, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        height: 130,
                        width: double.infinity,
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("Pets")
                              .where("sellingBy",
                                  isEqualTo: widget.userModel.uid)
                              .snapshots(),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.active) {
                              log("Active Connection State");
                              if (snapshot.hasData) {
                                log("snapshot has data");
                                QuerySnapshot querySnapshot =
                                    snapshot.data as QuerySnapshot;

                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: querySnapshot.docs.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    PetModel petModel = PetModel.fromMap(
                                        querySnapshot.docs[index].data()
                                            as Map<String, dynamic>);
                                    return Card(
                                      child: Column(children: [
                                        Container(
                                          height: 90,
                                          width: 90,
                                          child: Image.network(
                                              petModel.pic.toString()),
                                        ),
                                        Text(petModel.name)
                                      ]),
                                    );
                                  },
                                );
                              }
                            }

                            return Container(
                              child: Text("Loading..."),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Liked",
                          style: TextStyle(
                              color: Colors.amber, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        height: 130,
                        width: double.infinity,
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("Pets")
                              .where("likedBy",
                                  arrayContains: widget.userModel.uid)
                              .snapshots(),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.active) {
                              log("Active Connection State");
                              if (snapshot.hasData) {
                                log("snapshot has data");
                                QuerySnapshot querySnapshot =
                                    snapshot.data as QuerySnapshot;

                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: querySnapshot.docs.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    PetModel petModel = PetModel.fromMap(
                                        querySnapshot.docs[index].data()
                                            as Map<String, dynamic>);
                                    return Card(
                                      child: Column(children: [
                                        Container(
                                          height: 90,
                                          width: 90,
                                          child: Image.network(
                                              petModel.pic.toString()),
                                        ),
                                        Text(petModel.name)
                                      ]),
                                    );
                                  },
                                );
                              }
                            }

                            return Container(
                              child: Text("Loading..."),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Adopted",
                          style: TextStyle(
                              color: Colors.amber, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        height: 130,
                        width: double.infinity,
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("Pets")
                              .where("buyedBy", isEqualTo: widget.userModel.uid)
                              .snapshots(),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.active) {
                              log("Active Connection State");
                              if (snapshot.hasData) {
                                log("snapshot has data");
                                QuerySnapshot querySnapshot =
                                    snapshot.data as QuerySnapshot;
                                if (querySnapshot.docs.length > 0)
                                  return ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: querySnapshot.docs.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      PetModel petModel = PetModel.fromMap(
                                          querySnapshot.docs[index].data()
                                              as Map<String, dynamic>);
                                      return Card(
                                        child: Column(children: [
                                          Container(
                                            height: 90,
                                            width: 90,
                                            child: Image.network(
                                                petModel.pic.toString()),
                                          ),
                                          Text(petModel.name)
                                        ]),
                                      );
                                    },
                                  );
                                else
                                  return Text("Empty");
                              }
                            }

                            return Container(
                              child: Text("Loading..."),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
