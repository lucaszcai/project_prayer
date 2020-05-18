

import 'package:cloud_firestore/cloud_firestore.dart';

class Prayer {
  int id;
  int goal;
  double lat;
  double lng;
  String placeName;
  String cityName;
  List<dynamic> notes;
  Timestamp datetime;
  int total;
  DocumentReference reference;

  Prayer({this.id, this.notes, this.datetime, this.lat, this.lng, this.goal, this.placeName, this.cityName, this.total, this.reference});

  Map<String, dynamic> toJson() => _PrayerToJson(this);

  Map<String, dynamic> _PrayerToJson(Prayer instance) => <String, dynamic> {
    "id": instance.id,
    "goal": instance.goal,
    "lat": instance.lat,
    "lng": instance.lng,
    "notes": instance.notes,
    "datetime": instance.datetime,
    "placeName": instance.placeName,
    "cityName": instance.cityName,
    "total": instance.total,
  };

  factory Prayer.fromSnapshot(DocumentSnapshot snapshot) {
    Prayer newPrayer = Prayer.fromJson(snapshot.data);
    newPrayer.reference = snapshot.reference;
    return newPrayer;
  }

  factory Prayer.fromJson(Map<String, dynamic> json) {
    return Prayer(
      id: json["id"],
      notes: json["notes"],
      datetime: json["datetime"] as Timestamp,
      goal: json["goal"] as int,
      lat: json["lat"] as double,
      lng: json["lng"] as double,
      placeName: json["placeName"],
      cityName: json["cityName"],
      total: json["total"] as int,
    );
  }

  @override
  String toString() {
    return 'Prayer{id: $id, goal: $goal, lat: $lat, lng: $lng, notes: $notes, datetime $datetime, placeName: $placeName, cityName: $cityName}';
  }

}