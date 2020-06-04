import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:adopt_a_street/screens/home_screen.dart';
import 'package:adopt_a_street/models/User.dart';
import 'package:adopt_a_street/screens/map_page.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();
  TextEditingController nameInputController;
  TextEditingController emailInputController;
  TextEditingController passwordInputController;

  @override
  void initState() {
    super.initState();
    nameInputController = new TextEditingController();
    emailInputController = new TextEditingController();
    passwordInputController = new TextEditingController();
  }

  String emailValidator(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Email format is invalid';
    } else {
      return null;
    }
  }

  String passwordValidator(String value) {
    if (value.length < 8) {
      return 'Password length must be longer than 8 characters';
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        body: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                  Widget>[
            Container(
              child: Stack(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(15.0, 110.0, 0.0, 0.0),
                    child: Text(
                      'Signup',
                      style: TextStyle(
                          fontSize: 80.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Container(
                padding: EdgeInsets.only(top: 35.0, left: 20.0, right: 20.0),
                child: Form(
                  key: _signUpFormKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: nameInputController,
                        decoration: InputDecoration(
                            labelText: 'NAME',
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.green))),
                        validator: (input) {
                          if (input.trim().length < 1) {
                            return "Please input a valid name";
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: emailInputController,
                        decoration: InputDecoration(
                            labelText: 'EMAIL',
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                            // hintText: 'EMAIL',
                            // hintStyle: ,
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.green))),
                        validator: emailValidator,
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: passwordInputController,
                        decoration: InputDecoration(
                            labelText: 'PASSWORD ',
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.green))),
                        obscureText: true,
                        validator: passwordValidator,
                      ),
                      SizedBox(height: 50.0),
                      Material(
                        borderRadius: BorderRadius.circular(20.0),
                        shadowColor: Colors.greenAccent,
                        color: Colors.green,
                        elevation: 7.0,
                        child: InkWell(
                          onTap: () {
                            if (_signUpFormKey.currentState.validate()) {
                              FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                  email: emailInputController.text,
                                  password: passwordInputController.text)
                                  .then((currentUser) async {
                                User createdUser = new User(
                                  name: nameInputController.text,
                                  email: emailInputController.text,
                                  live: false,
                                  liveMinutes: 10,
                                  liveSeconds: 0,
                                  showLive: false,
                                  uid: currentUser.user.uid,
                                );
                                await Firestore.instance
                                    .collection('users')
                                    .document(currentUser.user.uid)
                                    .setData(createdUser.toJson());
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomeScreen()),
                                );
                              });
                            }
                          },
                          child: Container(
                            height: 50.0,
                            child: Center(
                              child: Text(
                                'SIGNUP',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Montserrat'),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                    ],
                  ),
                )),
          ]),
        ));
  }
}
