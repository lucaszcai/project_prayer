import 'package:adopt_a_street/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'entry_screen.dart';

class RootScreen extends StatefulWidget {
  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;

  Widget build(BuildContext context) {
    return FutureBuilder(
        future: auth.currentUser(),
        builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            if (snapshot.data == null) {
              return EntryScreen();
            } else {
              return HomeScreen();
            }
          }
        });
  }
}
