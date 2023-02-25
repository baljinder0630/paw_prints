// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names, unnecessary_null_comparison, must_be_immutable, prefer_typing_uninitialized_variables, unused_local_variable, curly_braces_in_flow_control_structures

import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paw_prints/Pages/HomePage.dart';

class CreateProfile extends StatefulWidget {
  var firebaseUser;

  var usermodel;

  CreateProfile({Key? key, required this.usermodel, required this.firebaseUser})
      : super(key: key);

  @override
  State<CreateProfile> createState() => _CreateProfileState();
}

class _CreateProfileState extends State<CreateProfile> {
  //
  //
  //
  TextEditingController usernamecontroller = TextEditingController();
  bool progressindicator = false;
  File? UserFinalImage;
  void selectimage(ImageSource source) async {
    final XFile? image = await ImagePicker().pickImage(source: source);

    if (image != null) {
      imagecrop(image);
    }
  }

  void imagecrop(XFile BeforeCrop) async {
    log("message1");
    if (BeforeCrop != null) {
      File? FinalImage = await ImageCropper()
          .cropImage(
              sourcePath: BeforeCrop.path,
              aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
              compressQuality: 20)
          .then((value) {
        log("Done");
      });

      if (FinalImage != null) {
        setState(() {
          UserFinalImage = FinalImage;
        });
      }
    }
  }

  void sendData(File imageurl) async {
    setState(() {
      progressindicator = true;
    });
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("Storage")
        .child(widget.firebaseUser.toString())
        .putFile(imageurl);
    TaskSnapshot taskSnapshot = await uploadTask;
    String networkurl = await taskSnapshot.ref.getDownloadURL();

    widget.usermodel.avatar = networkurl;
    widget.usermodel.username = usernamecontroller.text.toString();
    await FirebaseFirestore.instance
        .collection("User")
        .doc(widget.firebaseUser)
        .set(widget.usermodel.toMap())
        .onError((error, stackTrace) => showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(error.toString()),
                actions: [
                  Card(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Ok"),
                    ),
                  )
                ],
              );
            }))
        .then((value) {
      log("user sucessfully created");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return MyHomePage();
      }));
    });
  }

  //
  //
  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Container(
          child: ListView(
            children: [
              SizedBox(
                height: 150,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                                content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  onTap: () {
                                    selectimage(ImageSource.camera);
                                    Navigator.pop(context);
                                  },
                                  leading: Icon(Icons.camera_alt),
                                  title: Text("Camera"),
                                ),
                                ListTile(
                                  onTap: () {
                                    selectimage(ImageSource.gallery);
                                    Navigator.pop(context);
                                  },
                                  leading: Icon(Icons.photo),
                                  title: Text("Gallery"),
                                ),
                              ],
                            ));
                          });
                    },
                    style: ButtonStyle(splashFactory: NoSplash.splashFactory),
                    child: CircleAvatar(
                      radius: 72,
                      backgroundColor: Colors.blue,
                      child: CircleAvatar(
                          radius: 70,
                          backgroundImage: AssetImage(
                            'assets/userimage.png',
                          ),
                          foregroundImage: UserFinalImage != null
                              ? FileImage(UserFinalImage!)
                              : null),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 50,
              ),
              TextField(
                controller: usernamecontroller,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  hintText: "UserName",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(80.0),
                      ),
                      borderSide: BorderSide(color: Colors.teal)),
                ),
              ),
              SizedBox(
                height: 35,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (progressindicator == true) CircularProgressIndicator()
                ],
              ),
              TextButton(
                onPressed: () {
                  if (UserFinalImage == null)
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Add Profile Picture"),
                            actions: [
                              Card(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("Ok"),
                                ),
                              )
                            ],
                          );
                        });
                  else if (usernamecontroller.value == null)
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Enter UserName"),
                            actions: [
                              Card(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("Ok"),
                                ),
                              )
                            ],
                          );
                        });

                  sendData(UserFinalImage!);
                },
                child: Container(
                  height: 40,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Color(0xFF21899C),
                  ),
                  child: Center(
                      child: Text(
                    "Submit",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String errormsg() {
  return "Enter Username";
}
