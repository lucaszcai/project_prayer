import 'package:flutter/material.dart';
import 'package:adopt_a_street/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int pageIndex = 0;
  TextEditingController emailInputController;
  TextEditingController passwordInputController;
  final GlobalKey<FormState> _loginFormKey = new GlobalKey();
  String errorText;

  @override
  void initState() {
    super.initState();
    emailInputController = new TextEditingController();
    passwordInputController = new TextEditingController();
    errorText = null;
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(15.0, 100.0, 0.0, 0.0),
                      child: Text('Adopt a',
                          style: TextStyle(
                              fontSize: 80.0, fontWeight: FontWeight.w300)),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(16.0, 165.0, 0.0, 0.0),
                      child: Text('Street',
                          style: TextStyle(
                              fontSize: 80.0, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              Container(
                  padding: EdgeInsets.only(top: 35.0, left: 20.0, right: 20.0),
                  child: Form(
                    key: _loginFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          controller: emailInputController,
                          decoration: InputDecoration(
                            labelText: 'EMAIL',
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue)),
                          ),
                          validator: emailValidator,
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          controller: passwordInputController,
                          decoration: InputDecoration(
                              labelText: 'PASSWORD',
                              labelStyle: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue))),
                          obscureText: true,
                        ),
                        errorText != null
                            ? Padding(
                                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Text(
                                  errorText,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 10.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ))
                            : SizedBox.shrink(),
                        SizedBox(height: 40.0),
                        Material(
                          borderRadius: BorderRadius.circular(20.0),
                          shadowColor: Colors.blueAccent,
                          color: Colors.blue,
                          elevation: 7.0,
                          child: InkWell(
                            onTap: () {
                              if (_loginFormKey.currentState.validate()) {
                                FirebaseAuth.instance
                                    .signInWithEmailAndPassword(
                                    email: emailInputController.text,
                                    password: passwordInputController.text)
                                    .then((currentUser) {
                                  print(currentUser);
                                  Firestore.instance
                                      .collection('users')
                                      .document(currentUser.user.uid)
                                      .get()
                                      .then((value) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomeScreen()),
                                    );
                                  });
                                }).catchError((e) {
                                  print(e.toString());
                                  if (e.code == 'ERROR_TOO_MANY_REQUESTS') {
                                    setState(() {
                                      errorText =
                                      'Too many login attempts. Please try again later';
                                    });
                                  } else {
                                    setState(() {
                                      errorText =
                                      'Username or Password is Incorrect';
                                    });
                                  }
                                });
                              }
                            },
                            child: Container(
                              height: 50.0,
                              child: Center(
                                child: Text(
                                  'LOGIN',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat'),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0,),
                      ],
                    ),
                  ),),
            ],
          ),
        ),
      ),
    );
  }
}
