

class Prayer {
  int id;
  int goal;
  double lat;
  double lng;
  String placeName;
  String cityName;
  String note;
  int datetime;

  Prayer({this.id, this.note, this.datetime, this.lat, this.lng, this.goal, this.placeName, this.cityName});

  Map<String, dynamic> toMap() =>{
    "id": id,
    "goal": goal,
    "lat": lat,
    "lng": lng,
    "note": note,
    "datetime":datetime,
    "placeName":placeName,
    "cityName":cityName,
  };

  factory Prayer.fromMap(Map<String, dynamic> json) => new Prayer(
    id: json["id"],
    datetime:int.parse(json["datetime"]),
    note:json["note"],
    goal:int.parse(json["goal"]),
    lat:double.parse(json["lat"]),
    lng:double.parse(json["lng"]),
    placeName: json["placeName"],
    cityName: json["cityName"],
  );



  factory Prayer.fromJson(Map<String, dynamic> json) {
    return Prayer(
      id: json["id"],
      datetime:int.parse(json["datetime"]),
      note:json["note"],
      goal:int.parse(json["goal"]),
      lat:double.parse(json["lat"]),
      lng:double.parse(json["lng"]),
      placeName: json["placeName"],
      cityName: json["cityName"],
    );
  }

  @override
  String toString() {
    return 'Prayer{id: $id, goal: $goal, lat: $lat, lng: $lng, note: $note, datetime $datetime, placeName: $placeName, cityName: $cityName}';
  }


}