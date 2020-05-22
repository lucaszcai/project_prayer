

import 'package:cloud_firestore/cloud_firestore.dart';

class Prayer {
  int goal;
  double lat;
  double lng;
  String placeName;
  String cityName;
  List<dynamic> notes;
  List<dynamic> noteTimes;
  DateTime datetime;
  int total;
  DocumentReference reference;

  Prayer({this.notes, this.datetime, this.lat, this.lng, this.goal, this.placeName, this.cityName, this.total, this.noteTimes, this.reference});

  Map<String, dynamic> toJson() => _PrayerToJson(this);

  Map<String, dynamic> _PrayerToJson(Prayer instance) => <String, dynamic> {
    "goal": instance.goal,
    "lat": instance.lat,
    "lng": instance.lng,
    "notes": instance.notes,
    "datetime": instance.datetime,
    "placeName": instance.placeName,
    "cityName": instance.cityName,
    "total": instance.total,
    "noteTimes": instance.noteTimes,
  };

  factory Prayer.fromSnapshot(DocumentSnapshot snapshot) {
    Prayer newPrayer = Prayer.fromJson(snapshot.data);
    newPrayer.reference = snapshot.reference;
    return newPrayer;
  }

  factory Prayer.fromJson(Map<String, dynamic> json) {
    return Prayer(
      notes: json["notes"],
      datetime: (json["datetime"] as Timestamp).toDate(),
      goal: json["goal"] as int,
      lat: json["lat"] as double,
      lng: json["lng"] as double,
      placeName: json["placeName"],
      cityName: json["cityName"],
      total: json["total"] as int,
      noteTimes: json["noteTimes"],
    );
  }

  @override
  String toString() {
    return 'Prayer{goal: $goal, lat: $lat, lng: $lng, notes: $notes, datetime $datetime, placeName: $placeName, cityName: $cityName}';
  }

}