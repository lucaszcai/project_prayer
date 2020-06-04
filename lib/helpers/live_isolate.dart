import 'dart:isolate';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adopt_a_street/models/User.dart';

Isolate isolate;

void start() async {
  ReceivePort receivePort = ReceivePort();
  FirebaseUser getUser = await FirebaseAuth.instance.currentUser();
  DocumentSnapshot userData = await Firestore.instance.collection('users').document(getUser.uid).get();
  User currentUser = User.fromSnapshot(userData);
  isolate = await Isolate.spawn(runTimer, receivePort.sendPort);
  receivePort.listen((message) async {
    if (message is SendPort) {
      message.send('${currentUser.liveMinutes},${currentUser.liveSeconds}');
      print('sent!');
    }
    else if (message.toString() == 'done!') {
      if (currentUser.showLive) {
        Firestore.instance.collection('live').document(currentUser.uid).delete();
      }
      Firestore.instance.collection('users').document(currentUser.uid).updateData({
        'live': false,
        'liveMarkerID': 'none',
      });
      stop();
    }
  });
}

void runTimer(SendPort sendPort) {
  print('running timer');
  int liveMinutes = 0;
  int liveSeconds = 0;
  ReceivePort receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);
  print('created receive');
  receivePort.listen((message) {
    print(message.toString());
    if (message.toString().contains(',')) {
      print('yes!');
      List<String> splitMessage = message.split(',');
      liveMinutes = int.parse(splitMessage[0]);
      liveSeconds = int.parse(splitMessage[1]);
      Timer.periodic(new Duration(minutes: liveMinutes, seconds: liveSeconds), (timer) {
        String message = 'done!';
        sendPort.send(message);
      });
    }
  });

}

void stop() {
  if (isolate != null) {
    isolate.kill(priority: Isolate.immediate);
    isolate = null;
  }
}
