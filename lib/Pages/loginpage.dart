// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, body_might_complete_normally_nullable, sized_box_for_whitespace, prefer_const_constructors_in_immutables

import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:paw_prints/Models/firebaseHelper.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  //
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _focusScopeNode = FocusScopeNode();
  final _passwordFocus = FocusNode();
  final _emailFocus = FocusNode();
  bool _submitted = false;
  bool _obsecurePassword = true;
  void login() async {
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailcontroller.text.trim(),
          password: passwordcontroller.text.trim());
    } on Exception catch (e) {
      setState(() {
        _submitted = false;
      });
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.toString()),
              actions: [
                Card(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Ok"),
                  ),
                )
              ],
            );
          });
    }
    if (credential != null) {
      log("Sucessfully login");
      FirebaseHelper.currentAppUser = await FirebaseHelper.getUserModelByID(
          credential.user!.uid.toString());
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) {
      //     return NewHomePage(
      //       userModel: FirebaseHelper.currentAppUser,
      //     );
      //   }),
      // );
    }
    _submitted = false;

    emailcontroller.clear();
    passwordcontroller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: GestureDetector(
          onTap: () {
            _focusScopeNode.unfocus();
          },
          child: FocusScope(
            node: _focusScopeNode,
            child: Center(
              child: SingleChildScrollView(
                  child: Container(
                width: MediaQuery.of(context).size.shortestSide,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      """Login""",
                      style: TextStyle(
                          color: Color(0xFF21899C),
                          fontSize: 45,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 60,
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: TextFormField(
                          controller: emailcontroller,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter some text';
                            } else if (!value.contains("@")) {
                              return 'Invalid Email';
                            }
                            return null;
                          },
                          onFieldSubmitted: (v) {
                            FocusScope.of(context).requestFocus(_passwordFocus);
                          },
                          focusNode: _emailFocus,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            hintText: "Email",
                            filled: true,
                            fillColor: Colors.black,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(80.0),
                                ),
                                borderSide: BorderSide(color: Colors.teal)),
                          ),
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: TextFormField(
                          focusNode: _passwordFocus,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter some text';
                            } else if (value.length < 8) {
                              return "Password length >= 8";
                            }
                            return null;
                          },
                          obscureText: _obsecurePassword,
                          controller: passwordcontroller,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.password),
                            hintText: "Password",
                            filled: true,
                            fillColor: Colors.black,
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obsecurePassword = !_obsecurePassword;
                                  });
                                },
                                highlightColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                icon: _obsecurePassword
                                    ? Icon(Icons.visibility_off)
                                    : Icon(Icons.visibility)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(80.0),
                                ),
                                borderSide: BorderSide(color: Colors.teal)),
                          ),
                        )),
                    SizedBox(
                      height: 30,
                    ),
                    _submitted ? CircularProgressIndicator() : SizedBox(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: TextButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _submitted = true;
                            });

                            login();
                          }
                        },
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Color(0xFF21899C),
                          ),
                          child: Center(
                              child: Text(
                            "Submit",
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          )),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Do Not Have Account?"),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Sign Up"))
                      ],
                    )
                  ],
                ),
              )),
            ),
          ),
        ),
      ),
    );
  }
}
