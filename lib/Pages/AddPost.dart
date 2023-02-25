// ignore_for_file: prefer_const_constructors

import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paw_prints/Models/Post.dart';
import 'package:paw_prints/Models/UserModel.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:uuid/uuid.dart';

class AddPost extends StatefulWidget {
  UserModel userModel;
  AddPost({Key? key, required this.userModel}) : super(key: key);

  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final _formKey = GlobalKey<FormState>();
  final _captionController = TextEditingController();
  final _picker = ImagePicker();
  File? _imageFile;
  bool _isUploading = false;
  String getPostId() {
    return Uuid().v4();
  }

  Future<void> _getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imagecrop(pickedFile);
    }
  }

  void imagecrop(XFile BeforeCrop) async {
    log("message1");
    if (BeforeCrop != null) {
      File? FinalImage = await ImageCropper().cropImage(
          sourcePath: BeforeCrop.path,
          // aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 20,
          aspectRatioPresets: [
            CropAspectRatioPreset.ratio5x4,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio16x9
          ],
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Theme.of(context).primaryColor,
              cropFrameColor: Theme.of(context).primaryColor,
              backgroundColor: Theme.of(context).backgroundColor,

              // toolbarWidgetColor: Colors.blue,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));

      if (FinalImage != null) {
        setState(() {
          _imageFile = FinalImage;
        });
      }
    }
  }

  Future<void> _uploadPost() async {
    log("Image:=" + _imageFile.toString());
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final storage = FirebaseStorage.instance;
    final ref = storage.ref().child(Uuid().v4());
    final task = ref.putFile(_imageFile!);

    final snapshot = await task.whenComplete(() => null);

    final url = await snapshot.ref.getDownloadURL();
    log(url);

    final firestore = FirebaseFirestore.instance;
    try {
      PostModel postModel = PostModel(
          likes: [],
          id: getPostId(),
          caption: _captionController.text.trim(),
          imgUrl: url,
          createdTime: DateTime.now().toString(),
          createdByAvatar: widget.userModel.avatar,
          userId: FirebaseAuth.instance.currentUser!.uid,
          username: widget.userModel.username);
      await firestore
          .collection('posts')
          .doc(postModel.id)
          .set(postModel.toMap())
          .whenComplete(() {
        log("Completed");
      });
    } catch (e) {
      log(e.toString());
    }

    setState(() {
      _isUploading = false;
      _captionController.clear();
      _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: GradientText(
            'New Post',
            style: TextStyle(
              fontSize: 25,
            ),
            colors: [
              Colors.amber.shade800,
              Colors.amber.shade700,
              Colors.amber.shade600,
              Colors.amber.shade500
            ],
          ),
        ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_imageFile != null) ...[
                  Image.file(_imageFile!),
                  const SizedBox(height: 16),
                ],
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.amber.shade800,
                      Colors.amber.shade700,
                      Colors.amber.shade600,
                      Colors.amber.shade500
                    ]),
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.transparent,
                      onSurface: Colors.transparent,
                      shadowColor: Colors.transparent,
                      //make color or elevated button transparent
                    ),
                    onPressed: _getImage,
                    icon: const Icon(Icons.photo),
                    label: const Text('Choose a photo'),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _captionController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a caption';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Caption',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.amber.shade800,
                      Colors.amber.shade700,
                      Colors.amber.shade600,
                      Colors.amber.shade500
                    ]),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.transparent,
                      onSurface: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.all(10),
                      //make color or elevated button transparent
                    ),
                    onPressed: _isUploading ? null : _uploadPost,
                    child: _isUploading
                        ? const CircularProgressIndicator()
                        : const Text('Upload'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
