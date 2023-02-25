// ignore_for_file: prefer_const_constructors

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paw_prints/Models/petModel.dart';
import 'package:uuid/uuid.dart';

class DonatePet extends StatefulWidget {
  var usermodel;
  DonatePet({Key? key, required this.usermodel}) : super(key: key);
  @override
  State<DonatePet> createState() => _DonatePetState();
}

class _DonatePetState extends State<DonatePet> {
  DateTime? _dob;
  final _petName = TextEditingController();
  final _petPic = TextEditingController();
  final _petDescription = TextEditingController();
  var petId;
  String generateId() => Uuid().v1();
  File? petPic;

  void selectimage(ImageSource source) async {
    final XFile? image = await ImagePicker().pickImage(source: source);

    if (image != null) {
      imagecrop(image);
    }
  }

  void imagecrop(XFile BeforeCrop) async {
    log("message1");
    if (BeforeCrop != null) {
      File? FinalImage = await ImageCropper().cropImage(
          sourcePath: BeforeCrop.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 20,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));

      if (FinalImage != null) {
        setState(() {
          petPic = FinalImage;
        });
        log(petPic.toString());
      }
    }
  }

  void uploadData(File imageurl) async {
    setState(() {
      petId = generateId();
    });

    UploadTask uploadTask =
        FirebaseStorage.instance.ref("Storage").child(petId).putFile(imageurl);
    TaskSnapshot taskSnapshot = await uploadTask;
    String networkurl = await taskSnapshot.ref.getDownloadURL();

    PetModel petModel = PetModel(
      likedBy: [],
      pic: networkurl,
      sellingBy: widget.usermodel.uid,
      petId: petId,
      name: _petName.text.trim(),
      description: _petDescription.text.trim(),
      dob: _dob.toString(),
    );
    await FirebaseFirestore.instance
        .collection("Pets")
        .doc(petId)
        .set(petModel.toMap())
        .whenComplete(() {
      log("Pet uploaded");
    }).onError((error, stackTrace) {
      log(error.toString());
    }).whenComplete(() {
      _petName.clear();
      _petDescription.clear();
      _petPic.clear();
    });
  }

  void getCurrentPosition() async {
    // Permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      log("Permission denied");
      Geolocator.requestPermission();
    } else {
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.lowest);
      print(currentPosition);
      List<Placemark> address = await placemarkFromCoordinates(
          currentPosition.latitude, currentPosition.longitude);
      log(address[0].locality.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Donate"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            TextField(
              controller: _petName,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.pets),
                hintText: "Pet Name",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(80.0),
                    ),
                    borderSide: BorderSide(color: Colors.amber)),
              ),
            ),
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
                child: Text("Add pic")),
            TextField(
              controller: _petDescription,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.document_scanner_rounded),
                hintText: "Pet Description",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(80.0),
                    ),
                    borderSide: BorderSide(color: Colors.amber)),
              ),
            ),
            // TextField(
            //   controller: _petDOB,
            //   keyboardType: TextInputType.datetime,
            //   decoration: InputDecoration(hintText: "Pet dob"),
            // ),
            TextButton(
                onPressed: () async {
                  DateTime? _selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _dob == null ? DateTime.now() : _dob!,
                    firstDate: DateTime(1990),
                    lastDate: DateTime(3000),
                  );
                  setState(() {
                    if (_selectedDate != null) {
                      _dob = _selectedDate;
                    }
                  });
                  log(_selectedDate.toString());
                },
                child: Text("Pick DOB")),

            TextButton(
              child: Text("Location"),
              onPressed: () {
                getCurrentPosition();
              },
            ),
            SizedBox(
              height: 50,
            ),
            TextButton(
                onPressed: () async {
                  uploadData(petPic!);
                },
                child: Container(
                  height: 50,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    //color: Colors.amber,
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      stops: [0.1,0.5,0.7,0.9],
                        colors: [
                          Colors.amber.shade800,
                          Colors.amber.shade700,
                          Colors.amber.shade600,
                          Colors.amber.shade500
                          ],
                    ),
                  ),
                  child: Center(
                      child: Text(
                    "Submit",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  )),
                ))
          ],
        ),
      ),
    );
  }
}
