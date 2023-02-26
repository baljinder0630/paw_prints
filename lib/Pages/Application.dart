import 'package:flutter/material.dart';

class ApplicationPage extends StatefulWidget {
  ApplicationPage({Key? key}) : super(key: key);

  @override
  State<ApplicationPage> createState() => _ApplicationPageState();
}

class _ApplicationPageState extends State<ApplicationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Application")),
      body: Column(
        children: [
          Text("What is your occupation?"),
          TextFormField(),
          Text("Have you owned a pet before?"),
          TextFormField(),
          Text("How will to take care of your the pet?"),
          TextFormField(),
          TextButton(onPressed: () {}, child: Text("Sumbit"))
        ],
      ),
    );
  }
}
