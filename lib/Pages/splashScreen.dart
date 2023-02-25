// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:paw_prints/Models/UserModel.dart';
import 'package:paw_prints/Pages/HomePage.dart';
import 'package:paw_prints/Pages/createprofilepage.dart';
import 'package:paw_prints/Pages/signuppage.dart';

import '../models/firebaseHelper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4), () {
      checkLoginState();
    });
  }

  void checkLoginState() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      UserModel? userModel =
          await FirebaseHelper.getUserModelByID(currentUser.uid);

      if (userModel.username == "")
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: ((context) => CreateProfile(
                      firebaseUser: currentUser,
                      usermodel: userModel,
                    ))));
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: ((context) => MyHomePage(
                    userModel: userModel,
                  ))));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: ((context) => SignUp())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            logo(200, 200),
            const SizedBox(
              height: 50,
            ),
            richText(30),
          ],
        ),
      ),
    );
  }

  Widget logo(double height_, double width_) {
    return Container(
      height: height_,
      width: width_,
      child: Lottie.network(
          'https://assets8.lottiefiles.com/packages/lf20_2ixzdfvy.json'),
    );
    //  return SvgPicture.asset(
    //    'assets/doggy.svg',
    //    height: height_,
    //    width: width_,
    //  );
  }

  Widget richText(double fontSize) {
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          color: Theme.of(context).primaryColor,
          letterSpacing: 3,
          height: 1.03,
        ),
        children: const [
          TextSpan(
            text: 'WELCOME ',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: 'BACK\n',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: 'Paw Prints',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.amber,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
