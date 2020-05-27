import 'package:cloud_firestore/cloud_firestore.dart';

class User {

  String email;
  bool live;
  String name;
  int liveMinutes;
  int liveSeconds;
  bool showLive;
  String uid;

  DocumentReference reference;

  User({this.email, this.live, this.name, this.liveMinutes, this.liveSeconds, this.showLive, this.uid, this.reference});

  factory User.fromSnapshot(DocumentSnapshot snapshot) {
    User user = User.fromJson(snapshot.data);
    user.reference = snapshot.reference;
    return user;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] as String,
      live: json['live'] as bool,
      name: json['name'] as String,
      liveMinutes: json['liveMinutes'] as int,
      liveSeconds: json['liveSeconds'] as int,
      showLive: json['showLive'] as bool,
      uid: json['uid'] as String,
    );
  }

  Map<String, dynamic> toJson() => userToJson(this);

  userToJson(User instance) => <String, dynamic> {
    'email': instance.email,
    'live': instance.live,
    'name': instance.name,
    'liveMinutes': instance.liveMinutes,
    'liveSeconds': instance.liveSeconds,
    'showLive': instance.showLive,
    'uid': instance.uid,
  };
}