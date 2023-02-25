// ignore_for_file: prefer_const_con
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:paw_prints/Pages/HomePage.dart';


void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      darkTheme: ThemeData(
        primaryColor: const Color.fromARGB(255, 236, 219, 67),
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}
