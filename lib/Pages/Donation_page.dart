// ignore_for_file: prefer_const_constructors

import 'dart:async';
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
  bool uploadingData = false;

  String? dropdownValue = 'Dog';
  String generateId() => Uuid().v1();
  File? petPic;
  StreamController<Position> posContoller = StreamController();
  double? lat;
  double? long;
  @override
  void initState() {
    // TODO: implement initState
    getCurrentLocation();
  }

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
        lat: lat,
        long: long);
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

  Future<void> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      log("Permission denied");
      Geolocator.requestPermission();
    } else {
      log("Permission allowed");
      final currPosition = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .then((value) {
        setState(() {
          lat = value.latitude;
          long = value.longitude;
          if (uploadingData) {
            uploadData(petPic!);
          } else {
            uploadingData = false;
          }
        });
      });
      log("Lat:- " + lat.toString() + " Long:- " + long.toString());
    }
  }

  // void _getCurrentLocation() async {
  //   final position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  //   setState(() {
  //     _currentPosition = position;
  //   });
  // }

  // Future<void> getCurrentPosition() async {
  //   // Permission
  //   LocationPermission permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied ||
  //       permission == LocationPermission.deniedForever) {
  //     log("Permission denied");
  //     Geolocator.requestPermission();
  //   } else {
  //     log("Have location permissions");
  //     try {
  //       Position currentPosition = await Geolocator.getCurrentPosition(
  //               desiredAccuracy: LocationAccuracy.lowest)
  //           .whenComplete(() {
  //         log("Accesed");
  //       });
  //       print(currentPosition);
  //       List<Placemark> address = await placemarkFromCoordinates(
  //           currentPosition.latitude, currentPosition.longitude);
  //       log(address[0].locality.toString());
  //     } on Exception catch (e) {
  //       // TODO
  //       log(e.toString());
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        stream: posContoller.stream,
        builder: (context, snapshot) {
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
                      fillColor: Colors.black,
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
                      fillColor: Colors.black,
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

                  // TextButton(
                  //   child: Text("Location"),
                  //   onPressed: () {
                  //     getCurrentLocation();
                  //   },
                  // ),
                  uploadingData == true
                      ? CircularProgressIndicator()
                      : SizedBox(
                          height: 30,
                        ),
                  DropdownButton<String>(

                    isExpanded: true,
                    value: dropdownValue,
                    items: <String>['Dog','bird', 'Cat', 'Cow', 'other']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(fontSize: 30, color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue;
                      });
                    },
                  ),

                  TextButton(
                      onPressed: () {
                        setState(() {
                          uploadingData = true;
                          if (!uploadingData &&
                              lat.toString() != "" &&
                              long.toString() != "") {
                            uploadData(petPic!);
                          } else if (uploadingData &&
                              lat.toString() != "" &&
                              long.toString() != "") {
                            log("Lat:- " +
                                lat.toString() +
                                " Long:- " +
                                long.toString());
                            uploadData(petPic!);
                          }
                          uploadingData = false;
                        });
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
                            stops: [0.1, 0.5, 0.7, 0.9],
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
        });
  }
}
