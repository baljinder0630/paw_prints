// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:paw_prints/Models/firebaseHelper.dart';
import 'package:paw_prints/Pages/page0.dart';
import 'package:paw_prints/main.dart';
import 'package:restart_app/restart_app.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamController<int> navBarStream = StreamController();
  var _bottomNavIndex = 0;
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Restart.restartApp();
              },
              icon: Icon(Icons.logout))
        ],
        title: Text("Paw Prints"),
      ),

      //
      //
      floatingActionButton: FloatingActionButton(
        tooltip: "Donate pet",
        backgroundColor: Color.fromARGB(255, 236, 219, 67),
        onPressed: (() {}),
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      //
      //
      body: StreamBuilder<int>(
          stream: navBarStream.stream,
          builder: (context, snapshot) {
            if (_bottomNavIndex == 0) {
              return PageZero(userModel: FirebaseHelper.currentAppUser);
            }
            return Container(
              child: Text(
                _bottomNavIndex.toString(),
                textAlign: TextAlign.center,
              ),
            );
          }),
      bottomNavigationBar: AnimatedBottomNavigationBar(
        activeColor: Color.fromARGB(255, 246, 231, 93),
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
          navBarStream.sink.add(index);
        },
      ),
    );
  }
}
