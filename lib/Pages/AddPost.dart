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
import 'package:uuid/uuid.dart';

class AddPost extends StatefulWidget {
  const AddPost({Key? key}) : super(key: key);

  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final _formKey = GlobalKey<FormState>();
  final _captionController = TextEditingController();
  final _picker = ImagePicker();
  File? _imageFile;
  bool _isUploading = false;
  String getPostId(){
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
            // CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio5x3,
            CropAspectRatioPreset.ratio7x5,
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
          )
          );

      if (FinalImage != null) {
        setState(() {
          _imageFile = FinalImage;
        });
      }
    }
  }

  Future<void> _uploadPost() async {
    log("Image:="+_imageFile.toString());
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
          timeStamp: FieldValue.serverTimestamp(),
          userId: FirebaseAuth.instance.currentUser!.uid,
          username: FirebaseAuth.instance.currentUser!.displayName);
      await firestore
          .collection('posts').doc(postModel.id).set(postModel.toMap()).whenComplete(() {
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
        title: const Text('New Post'),
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
                ElevatedButton.icon(
                  onPressed: _getImage,
                  icon: const Icon(Icons.photo),
                  label: const Text('Choose a photo'),
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
                ElevatedButton(
                  onPressed: _isUploading ? null : _uploadPost,
                  child: _isUploading
                      ? const CircularProgressIndicator()
                      : const Text('Upload'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
