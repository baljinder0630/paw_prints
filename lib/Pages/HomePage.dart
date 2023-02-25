import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:paw_prints/main.dart';
import 'package:restart_app/restart_app.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _bottomNavIndex = 0;
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
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
      body: Container(
        child: Text(
          "body",
          textAlign: TextAlign.center,
        ),
      ),
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
        onTap: (index) => setState(() => _bottomNavIndex = index),
      ),
    );
  }
}
