// ignore_for_file: prefer_const_con
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:paw_prints/Pages/splashScreen.dart';
import 'package:paw_prints/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      // theme: ThemeData(
      //   appBarTheme: const AppBarTheme(color: Color(0xFF21899C)),
      //   primaryColor: const Color(0xFF21899C),
      // ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.amber,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
