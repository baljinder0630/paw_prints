// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:paw_prints/Models/UserModel.dart';
import 'package:paw_prints/Models/firebaseHelper.dart';
import 'package:paw_prints/Pages/AddPost.dart';
import 'package:paw_prints/Pages/Donation_page.dart';
import 'package:paw_prints/Pages/editProfile.dart';
import 'package:paw_prints/Pages/pageNoOne.dart';
import 'package:paw_prints/Pages/pageThree.dart';
import 'package:paw_prints/Pages/pageZero.dart';
import 'package:paw_prints/Pages/pageTwo.dart';
import 'package:paw_prints/main.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class MyHomePage extends StatefulWidget {
  UserModel userModel;
  MyHomePage({Key? key, required this.userModel}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamController<int> navBarStream = StreamController();
  var _bottomNavIndex = 0;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
        stream: navBarStream.stream,
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: Text("Paw Prints"),
            ),

            //
            //
            floatingActionButton: FloatingActionButton(
              tooltip: _bottomNavIndex == 0
                  ? "Add Post"
                  : _bottomNavIndex == 1
                      ? "Want to donate Pet?"
                      : _bottomNavIndex == 2
                          ? "Log Out"
                          : "Edit Profile",
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: (() async {
                _bottomNavIndex == 0
                    ? Navigator.push(context,
                        MaterialPageRoute(builder: ((context) {
                        return AddPost(
                          userModel: widget.userModel,
                        );
                      })))
                    : _bottomNavIndex == 1
                        ? Navigator.push(context,
                            MaterialPageRoute(builder: ((context) {
                            return DonatePet(usermodel: widget.userModel);
                          })))
                        : _bottomNavIndex == 2
                            ? logout(context)
                            : Navigator.push(context,
                                MaterialPageRoute(builder: ((context) {
                                return EditProfile();
                              })));
              }),
              child: _bottomNavIndex == 0
                  ? Icon(Icons.add_a_photo_outlined)
                  : _bottomNavIndex == 1
                      ? Icon(Icons.add)
                      : _bottomNavIndex == 2
                          ? Icon(Icons.logout)
                          : Icon(Icons.edit),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,

            //
            //
            body: _bottomNavIndex == 0
                ? PageNoZero(userModel: widget.userModel)
                : _bottomNavIndex == 1
                    ? PageNoOne(userModel: widget.userModel)
                    : _bottomNavIndex == 2
                        ? SettingPage()
                        : ProfilePage(userModel: widget.userModel),
            bottomNavigationBar: AnimatedBottomNavigationBar(
              activeColor: Theme.of(context).primaryColor,
              backgroundColor: Color.fromARGB(255, 59, 58, 58),
              height: 60,
              icons: [
                CupertinoIcons.home,
                CupertinoIcons.paw,
                CupertinoIcons.settings,
                CupertinoIcons.profile_circled
              ],
              activeIndex: _bottomNavIndex,
              gapLocation: GapLocation.center,
              notchSmoothness: NotchSmoothness.verySmoothEdge,
              leftCornerRadius: 32,
              rightCornerRadius: 32,
              onTap: (index) {
                _bottomNavIndex = index;
                navBarStream.sink.add(_bottomNavIndex);
                // navBarStream.sink.add(_bottomNavIndex);
              },
            ),
          );
        });
  }
}

void logout(context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.popUntil(context, (route) => route.isFirst);
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
    return MyApp();
  }));
}
