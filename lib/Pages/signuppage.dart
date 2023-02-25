// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, body_might_complete_normally_nullable, sized_box_for_whitespace, prefer_const_constructors_in_immutables

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:paw_prints/Models/UserModel.dart';
import 'package:paw_prints/Pages/createprofilepage.dart';

import 'loginpage.dart';

class SignUp extends StatefulWidget {
  SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  //
  final _formKey = GlobalKey<FormState>();
  final _focusScopeNode = FocusScopeNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _cpasswordFocus = FocusNode();
  bool _obsecurePassword = true;
  bool _cObsecurePassword = true;
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController cpasswordcontroller = TextEditingController();
  bool _submitted = false;
  void signup() async {
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
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
      String uid = credential.user!.uid;
      UserModel newuser = UserModel(
          uid: uid,
          email: emailcontroller.text.toString(),
          username: '',
          avatar: '');
      await FirebaseFirestore.instance
          .collection("User")
          .doc(uid)
          .set(newuser.toMap())
          .then((value) {
        log("New User Created");
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return CreateProfile(
              usermodel: newuser, firebaseUser: credential!.user!.uid);
        }),
      );
    }
    _submitted = false;
    _cObsecurePassword = true;
    _obsecurePassword = true;
    emailcontroller.clear();
    passwordcontroller.clear();
    cpasswordcontroller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          _focusScopeNode.unfocus();
        },
        child: Form(
          key: _formKey,
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
                      """Sign Up""",
                      style: TextStyle(
                          color: Color(0xFF21899C),
                          fontSize: 45,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 60,
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0),
                        child: TextFormField(
                          focusNode: _emailFocus,
                          controller: emailcontroller,
                          keyboardType: TextInputType.emailAddress,
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
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            hintText: "Email",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(80.0),
                                ),
                                borderSide: BorderSide(color: Colors.teal)),
                          ),
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: TextFormField(
                          focusNode: _passwordFocus,
                          obscureText: _obsecurePassword,
                          onFieldSubmitted: (v) {
                            FocusScope.of(context)
                                .requestFocus(_cpasswordFocus);
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter some text';
                            } else if (value.length < 8) {
                              return "Password length >= 8";
                            }
                            return null;
                          },
                          controller: passwordcontroller,
                          decoration: InputDecoration(
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
                            prefixIcon: Icon(Icons.password),
                            hintText: "Password",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(80.0),
                                ),
                                borderSide: BorderSide(color: Colors.teal)),
                          ),
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: TextFormField(
                          obscureText: _cObsecurePassword,
                          focusNode: _cpasswordFocus,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter some text';
                            } else if (value.length < 8) {
                              return "Password length >= 8";
                            } else if (value !=
                                passwordcontroller.text.trim()) {
                              return "Password doesn't match";
                            }
                            return null;
                          },
                          controller: cpasswordcontroller,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _cObsecurePassword = !_cObsecurePassword;
                                  });
                                },
                                highlightColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                icon: _cObsecurePassword
                                    ? Icon(Icons.visibility_off)
                                    : Icon(Icons.visibility)),
                            prefixIcon: Icon(Icons.password),
                            hintText: "Confirm Password",
                            filled: true,
                            fillColor: Colors.white,
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _submitted ? CircularProgressIndicator() : SizedBox()
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: TextButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _submitted = true;
                            });
                            signup();
                            log("Validate stage");
                          } else
                            log("Non Validate stage");
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
                        Text("Already Have Account?"),
                        TextButton(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return LoginPage();
                              }));
                            },
                            child: Text("Login"))
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
