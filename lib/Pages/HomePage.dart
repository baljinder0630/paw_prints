// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:paw_prints/Models/UserModel.dart';
import 'package:paw_prints/Models/firebaseHelper.dart';
import 'package:paw_prints/Pages/Donation_page.dart';
import 'package:paw_prints/Pages/ProfilePage.dart';
import 'package:paw_prints/Pages/page0.dart';
import 'package:paw_prints/Pages/page1.dart';
import 'package:paw_prints/Pages/settingPage.dart';
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
              actions: [
                IconButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.popUntil(context, (route) => route.isFirst);
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return MyApp();
                      }));
                    },
                    icon: Icon(Icons.logout))
              ],
              title: GradientText(
                'Paw Prints',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                colors: [
                  Colors.amber.shade800,
                  Colors.amber.shade700,
                  Colors.amber.shade600,
                  Colors.amber.shade500
                ],
              ),
            ),

            //
            //
            floatingActionButton: FloatingActionButton(
              tooltip: "Want to donate Pet?",
              backgroundColor: Theme.of(context).primaryColor,

              onPressed: (() {
                Navigator.push(context, MaterialPageRoute(builder: ((context) {
                  return DonatePet(usermodel: widget.userModel);
                })));
              }),
              child: Container(child: Icon(Icons.add),
              height: 60,
              width: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.shade800,
                      Colors.amber.shade700,
                      Colors.amber.shade600,
                      Colors.amber.shade500
                    ]
                  )
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,

            //
            //
            body: _bottomNavIndex == 0
                ? PageOne(userModel: widget.userModel)
                : _bottomNavIndex == 1
                    ? PageZero(userModel: widget.userModel)
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
