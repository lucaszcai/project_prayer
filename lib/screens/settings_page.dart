import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:adopt_a_street/models/User.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  User currentUser;

  @override
  void initState() {
    super.initState();
    getSettings();
  }

  //Refresh user settings
  getSettings() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    Firestore.instance
        .collection('users')
        .document(user.uid)
        .snapshots()
        .listen((updatedUser) {
      print('new');
      if (this.mounted) {
        setState(() {
          currentUser = User.fromSnapshot(updatedUser);
        });
      }
    });
  }

  //Update user settings for live tracking
  updateCurrentUserLive(bool value) {
    currentUser.reference.updateData({
      'showLive': value,
    });
  }

  //Update user settings for live prayer length
  updateCurrentUserTime(int liveMinutes, int liveSeconds) {
    currentUser.reference.updateData({
      'liveMinutes': liveMinutes,
      'liveSeconds': liveSeconds,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text('Settings'),
        ),
        body: Scaffold(
            body: ListView(
          children: [
            SwitchListTile(
              title: Text('Live Tracking'),
              subtitle:
                  Text('Allow others to see your location during a prayer'),
              value: currentUser.showLive,
              onChanged: (value) {
                updateCurrentUserLive(value);
              },
            ),
            ListTile(
              title: Text('Live Timer'),
              subtitle: Text(
                  'How long a live prayer lasts before it is automatically turned off'),
              trailing: SizedBox(
                width: 100,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () async {
                      double receivedTime = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return NumberPickerDialog.decimal(
                              minValue: 0,
                              maxValue: 60,
                              initialDoubleValue: currentUser.liveMinutes +
                                  currentUser.liveSeconds / 10,
                              title: Text('Choose a new time'),
                            );
                          });
                      if (receivedTime != null) {
                        int updatedMinutes = receivedTime.floor();
                        int updatedSeconds =
                            ((receivedTime - receivedTime.floor()) * 10)
                                .round();
                        updateCurrentUserTime(updatedMinutes, updatedSeconds);
                      }
                      print('Received: ' + receivedTime.toString());
                    },
                    child: Text(currentUser.liveMinutes.toString() +
                        ":0" +
                        currentUser.liveSeconds.toString()),
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text('Log Out'),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login', (Route<dynamic> route) => false);
              },
            )
          ],
        )),
      );
    }
  }
}
