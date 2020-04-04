import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project_prayer/models/prayer.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();

}

class _MapPageState extends State<MapPage> {
  GoogleMapController mapController;
  Position currentLocation;
  List<Marker> markers;
  final Firestore _firestore = Firestore.instance;
  String name = "";
  TextEditingController placeNameInputController;
  TextEditingController cityInputController;

  @override
  void initState() {
    super.initState();
    markers = new List<Marker>();
    placeNameInputController = new TextEditingController();
    cityInputController = new TextEditingController();
    //placeNameInputController.text = 'Street Name';
    //cityInputController.text = 'City, Province';
    getName();

    getCurrentLocation();
    _setUpMap();
  }

  void getName() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot data =
    await Firestore.instance.collection('users').document(user.uid).get();
    setState(() {
      name = data["name"];
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _setUpMap() async {
    _firestore.collection('prayers').getDocuments().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents) {
        double hue = 0;
        double percent = 0.1; //CHANGE
        if (percent < 0.33) {
          hue = BitmapDescriptor.hueRed;
        }
        else if (percent < 0.67) {
          hue = BitmapDescriptor.hueOrange;
        }
        else if (percent < 1) {
          hue = BitmapDescriptor.hueYellow;
        }
        else {
          hue = BitmapDescriptor.hueGreen;
        }
        setState(() {
          markers.add(
            new Marker(
                markerId: MarkerId(LatLng(ds.data['lat'], ds.data['lng']).hashCode.toString()),
                position: LatLng(ds.data['lat'], ds.data['lng']),
                icon: BitmapDescriptor.defaultMarkerWithHue(hue),
                onTap: () {
                  onPrayerTap(LatLng(ds.data['lat'], ds.data['lng']));
                }),
          );
        });
      }
    });
  }


  void getCurrentLocation() async {
    var status = await Permission.location.status;

    if (status.isUndetermined || status.isDenied) {
      Map<Permission, PermissionStatus> statues =
      await [Permission.location].request();
    }

    status = await Permission.location.status;
    print(status);

    if (status.isGranted) {
      print('wait');
      Position pos = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentLocation = pos;
      });
      print(currentLocation);
      markers.add(
        new Marker(
            markerId: MarkerId(LatLng(currentLocation.latitude, currentLocation.longitude).hashCode.toString()),
            position:
            LatLng(currentLocation.latitude, currentLocation.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue)),
      );
    }
  }

  //Database code

  void addPrayertoDB(Prayer prayer) {
    CollectionReference v = _firestore.collection('prayers');
    v.add(prayer.toMap());
  }

  Future<List<Prayer>> getLocationPrayers(LatLng location) async {
    print("GETTING LOCATION PRAYERS");
    List<Prayer> prayers = [];
    QuerySnapshot snapshot =
    await _firestore.collection('prayers').getDocuments();
    for (DocumentSnapshot ds in snapshot.documents)
      if (ds.data['lat'] == location.latitude &&
          ds.data['lng'] == location.longitude) {
        prayers.add(Prayer.fromMap(ds.data));
      }

    print("CURPRAYERS" + prayers.toString());
    return prayers;
  }


  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    addGoalController.dispose();
    addNoteController.dispose();
    super.dispose();
  }

  void onPrayerTap(LatLng location) {
    getLocationPrayers(location).then((value) {
      print("hello");
      _viewMarker(location, value);
    });
  }

  final addGoalController = TextEditingController();
  final addNoteController = TextEditingController();

  List<String> note = [];

  void _onAddMarker(LatLng position) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 30.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: TextField(
                        controller: placeNameInputController,
                        decoration: InputDecoration(hintText: 'Street Name'),
                        style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                      ),
                    ),
                    SizedBox(height: 10.0,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: TextField(
                        controller: cityInputController,
                        decoration: InputDecoration(hintText: 'City/Province'),
                        style:
                        TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
                      ),
                    ),

                    SizedBox(
                      height: 50.0,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 150.0),
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: addGoalController,
                        decoration: InputDecoration(
                          hintText: 'Prayer Goal',
                        ),
                        keyboardType: TextInputType.numberWithOptions(),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 50.0),
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        controller: addNoteController,
                        decoration: InputDecoration(
                          hintText: 'Prayer Note',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50.0,
                    ),
                    IconButton(
                      onPressed: () {
                        addPrayertoDB(new Prayer(
                          id: null,
                          note: name + " | " + addNoteController.text,
                          datetime: DateTime.now().millisecondsSinceEpoch,
                          lat: position.latitude,
                          lng: position.longitude,
                          goal: int.parse(addGoalController.text),
                          placeName: placeNameInputController.text,
                          cityName: cityInputController.text,
                        ));
                        addNoteController.clear();
                        setState(() {
                          markers.add(new Marker(
                            markerId: MarkerId(position.hashCode.toString()),
                            position: position,
                            onTap: () {
                              onPrayerTap(position);
                            },
                          ));
                        });
                        Navigator.pop(context, true);
                        setState(() {

                        });
                      },
                      icon: Icon(Icons.check),
                      iconSize: 30.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void _viewMarker(LatLng position, List<Prayer>curprayers){
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 40.0,),
                    Text(
                      '${curprayers[0].placeName}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 40
                      ),
                    ),
                    Text(
                      '${curprayers[0].cityName}',
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 20
                      ),
                    ),
                    SizedBox(height: 20.0,),

                    GestureDetector(
                      onTap: null,
                      child: Container(
                        height: 200,
                        width: 300,
                        //color: Colors.grey[300],
                        child: curprayers.length == 0 ? Center(child: Text("No Prayers Yet"),
                        )
                            : ListView.builder(
                            itemCount: curprayers.length,
                            itemBuilder: (context, index){
                              note = curprayers[index].note.split("|");
                              return Column(
                                children: <Widget>[
                                  Divider(),
                                  ListTile(
                                    title: Text(note[1]),
                                    subtitle: Text(note[0]),
                                  ),

                                ],

                              );
                            }
                        ),
                      ),
                    ),

                    SizedBox(height: 20.0,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Spacer(),
                        Text(
                          '${curprayers.length}',
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '/${curprayers[0].goal} prayers',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer()
                      ],
                    ),

                    SizedBox(height: 20.0,),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 50.0),
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        controller: addNoteController,
                        decoration: InputDecoration(
                          hintText: 'Prayer Note',
                        ),
                      ),
                    ),

                    SizedBox(height: 50.0,),

                    GestureDetector(
                      onTap: () {
                        addPrayertoDB(new Prayer(
                            id: null,
                            note: name + "|" + addNoteController.text,
                            datetime: DateTime.now().millisecondsSinceEpoch,
                            lat: position.latitude,
                            lng: position.longitude,
                            goal: curprayers[0].goal));
                        addNoteController.clear();
                        Navigator.pop(context, true);
                      },
                      child: Container(
                        height: 50.0,
                        width: 300.0,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.all(Radius.circular(30.0),)
                        ),
                        child: Center(child: Text('Pray for this Location',
                          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
                        )),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    if (currentLocation == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(currentLocation.latitude, currentLocation.longitude),
            zoom: 12,
          ),
          onTap: (position) {
            addMarker(position);
          },
          markers: markers.toSet(),
        ),
      );
    }
  }

  addMarker(LatLng position) {
    print(position);
    _onAddMarker(position);
  }
}

