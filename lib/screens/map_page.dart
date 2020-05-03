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
    print("SET UP");
    _firestore.collection('prayers').getDocuments().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents) {
        print(ds);
        Prayer currentPrayer = Prayer.fromSnapshot(ds);
        double hue = 0;
        double percent = currentPrayer.total / currentPrayer.goal; //CHANGE
        if (percent < 0.33) {
          hue = BitmapDescriptor.hueRed;
        } else if (percent < 0.67) {
          hue = BitmapDescriptor.hueOrange;
        } else if (percent < 1) {
          hue = BitmapDescriptor.hueYellow;
        } else {
          hue = BitmapDescriptor.hueGreen;
        }
        print(currentPrayer);
        setState(() {
          markers.add(
            new Marker(
                markerId: MarkerId(
                    LatLng(ds.data['lat'], ds.data['lng']).hashCode.toString()),
                position: LatLng(ds.data['lat'], ds.data['lng']),
                icon: BitmapDescriptor.defaultMarkerWithHue(hue),
                onTap: () {
                  _viewMarker(currentPrayer);
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
            markerId: MarkerId(
                LatLng(currentLocation.latitude, currentLocation.longitude)
                    .hashCode
                    .toString()),
            position:
                LatLng(currentLocation.latitude, currentLocation.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue)),
      );
    }
  }

  //Database code

  Future<DocumentReference> addPrayertoDB(Prayer prayer) async {
    CollectionReference v = _firestore.collection('prayers');
    return v.add(prayer.toJson());
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    addGoalController.dispose();
    addNoteController.dispose();
    super.dispose();
  }

  final addGoalController = TextEditingController();
  final addNoteController = TextEditingController();

  List<String> note = [];

  void _onAddMarker(LatLng position) {
    List<String> holdNotes = new List();
    holdNotes.add(name + " | " + addNoteController.text);
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
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 40),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: TextField(
                        controller: cityInputController,
                        decoration: InputDecoration(hintText: 'City, Province'),
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 20),
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
                      onPressed: () async {
                        Navigator.pop(context, true);
                        Prayer addPrayer = new Prayer(
                          id: null,
                          notes: holdNotes,
                          datetime: Timestamp.fromDate(DateTime.now()),
                          lat: position.latitude,
                          lng: position.longitude,
                          goal: int.parse(addGoalController.text),
                          placeName: placeNameInputController.text,
                          cityName: cityInputController.text,
                          total: 1,
                        );
                        DocumentReference prayerReference = await addPrayertoDB(addPrayer);
                        addPrayer.reference = prayerReference;
                        setState(() {
                          markers.add(new Marker(
                            markerId: MarkerId(position.hashCode.toString()),
                            position: position,
                            onTap: () {
                              _viewMarker(addPrayer);
                            },
                          ));
                        });
                        addGoalController.clear();
                        placeNameInputController.clear();
                        cityInputController.clear();
                        addNoteController.clear();
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

  void updatePrayer(Prayer updatedPrayer) {

    updatedPrayer.reference.updateData(updatedPrayer.toJson());

  }

  void _viewMarker(Prayer currentPrayer) {
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
                    SizedBox(
                      height: 40.0,
                    ),
                    Text(
                      '${currentPrayer.placeName}',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                    ),
                    Text(
                      '${currentPrayer.cityName}',
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    GestureDetector(
                      onTap: null,
                      child: Container(
                        height: 200,
                        width: 300,
                        //color: Colors.grey[300],
                        child: currentPrayer.notes.length == 0
                            ? Center(
                                child: Text("No Prayers Yet"),
                              )
                            : ListView.builder(
                                itemCount: currentPrayer.notes.length,
                                itemBuilder: (context, index) {
                                  note = currentPrayer.notes[index].split("|");
                                  return Column(
                                    children: <Widget>[
                                      Divider(),
                                      ListTile(
                                        title: Text(note[1]),
                                        subtitle: Text(note[0]),
                                      ),
                                    ],
                                  );
                                }),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Spacer(),
                        Text(
                          '${currentPrayer.notes.length}',
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '/${currentPrayer.goal} prayers',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer()
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
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
                    GestureDetector(
                      onTap: () {
                        print(currentPrayer);
                        Navigator.pop(context, true);
                        currentPrayer.notes.add(name + "|" + addNoteController.text);
                        currentPrayer.total++;
                        updatePrayer(currentPrayer);
                        addNoteController.clear();
                      },
                      child: Container(
                        height: 50.0,
                        width: 300.0,
                        decoration: BoxDecoration(
                            color: Colors.blue[500],
                            borderRadius: BorderRadius.all(
                              Radius.circular(30.0),
                            )),
                        child: Center(
                            child: Text(
                          'Pray for this Location',
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
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
