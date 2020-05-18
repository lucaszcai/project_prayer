import 'package:cloud_firestore/cloud_firestore.dart';

class LiveMarker {

  String uid;
  DateTime time;
  double lat;
  double lng;
  String markerID;

  DocumentReference reference;

  LiveMarker({this.uid, this.time, this.lat, this.lng, this.markerID, this.reference});

  factory LiveMarker.fromSnapshot(DocumentSnapshot snapshot) {
    LiveMarker liveMarker = LiveMarker.fromJson(snapshot.data);
    liveMarker.reference = snapshot.reference;
    return liveMarker;
  }

  factory LiveMarker.fromJson(Map<String, dynamic> json) {
    return LiveMarker(
      uid: json['uid'] as String,
      time: (json['time'] as Timestamp).toDate(),
      lat: json['lat'] as double,
      lng: json['lng'] as double,
      markerID: json['markerID'] as String,
    );
  }

  Map<String, dynamic> toJson() => liveMarkerToJson(this);

  liveMarkerToJson(LiveMarker instance) => <String, dynamic> {
    'uid': instance.uid,
    'time': instance.time,
    'lat': instance.lat,
    'lng': instance.lng,
    'markerID': instance.markerID,
  };
}