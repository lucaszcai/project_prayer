import 'dart:isolate';
import 'dart:async';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project_prayer/models/LiveMarker.dart';
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
  FirebaseUser user;
  String liveMarkerID;
  BitmapDescriptor liveMarkerIcon;

  @override
  void initState() {
    super.initState();
    markers = new List<Marker>();
    placeNameInputController = new TextEditingController();
    cityInputController = new TextEditingController();
    //placeNameInputController.text = 'Street Name';
    //cityInputController.text = 'City, Province';
    liveMarkerID = 'none';

    setUp();
  }

  void setUp() async {
    await getUser();
    await getBitmapDescriptorFromSVG(context, 'assets/51.svg');

    getCurrentLocation();
    getLivePrayers();
    setLiveTimer();
    _setUpMap();
  }

  getUser() async {
    user = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot data =
        await Firestore.instance.collection('users').document(user.uid).get();
    if (this.mounted) {
      setState(() {
        name = data["name"];
      });
    }
  }

  getBitmapDescriptorFromSVG(BuildContext context, String assetName) async {
    String svgString = await DefaultAssetBundle.of(context).loadString(assetName);
    DrawableRoot svgDrawableRoot = await svg.fromSvgString(svgString, null);

    MediaQueryData queryData = MediaQuery.of(context);
    double devicePixelRatio = queryData.devicePixelRatio;
    double width = 40 * devicePixelRatio;
    double height = 40 * devicePixelRatio;

    ui.Picture picture = svgDrawableRoot.toPicture(size: Size(width, height));

    ui.Image image = await picture.toImage(width.round(), height.round());
    ByteData bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    liveMarkerIcon = BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
  }

  void getLivePrayers() async {
    //Listen for live prayers
    _firestore.collection('live').snapshots().listen((event) async {
      for (DocumentSnapshot ds in event.documents) {
        print("LIVE CHANGES: " + ds.data.toString());
        for (int i = 0; i < markers.length; i++) {
          if (markers[i].markerId.value == ds.documentID + "LIVE") {
            markers.removeAt(i);
            break;
          }
        }

        if (this.mounted) {
          setState(() {
            markers.add(new Marker(
                markerId: MarkerId(ds.documentID + "LIVE"),
                icon: liveMarkerIcon,
                position: LatLng(ds.data['lat'], ds.data['lng'])));
          });
        }
      }
    });

    //Check if user is live
    DocumentSnapshot liveMarkerSnapshot =
    await _firestore.collection('live').document(user.uid).get();
    print('SNAPSHOT' + liveMarkerSnapshot.toString());
    if (liveMarkerSnapshot.data != null) {
      liveMarkerID = liveMarkerSnapshot.data['markerID'];
    }
  }

  setLiveTimer() {
    Timer.periodic(new Duration(seconds: 20), (timer) async {
      QuerySnapshot querySnapshot = await _firestore.collection('live').getDocuments();
      for (int i = 0; i < markers.length; i++) {
        if (markers[i].markerId.value.endsWith('LIVE')) {
          markers.removeAt(i);
        }
      }
      for (DocumentSnapshot liveMarkerSnapshot in querySnapshot.documents) {
        LiveMarker receivedLiveMarker = LiveMarker.fromSnapshot(liveMarkerSnapshot);
        markers.add(new Marker(
          markerId: MarkerId(receivedLiveMarker.reference.documentID + 'LIVE'),
          position: LatLng(receivedLiveMarker.lat, receivedLiveMarker.lng),
          icon: liveMarkerIcon,
        ));
      }
      setState(() {

      });
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
      Geolocator().getPositionStream().listen((event) async {
        currentLocation = event;
        DocumentSnapshot userSnapshot =
        await _firestore.collection('users').document(user.uid).get();
        print('DATA' + userSnapshot.data.toString());
        if (userSnapshot.data['live']) {
          updateUserLiveMarkerCoordinates(currentLocation.latitude, currentLocation.longitude);
        }
        for (int i = 0; i < markers.length; i++) {
          if (markers[i].markerId.value == 'user location') {
            print('remove');
            markers.removeAt(i);
            break;
          }
        }

        if (!userSnapshot.data['live']) {
          if (this.mounted) {
            setState(() {
              markers.add(
                new Marker(
                    markerId: MarkerId('user location'),
                    position: LatLng(
                        currentLocation.latitude, currentLocation.longitude),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueBlue)),
              );
            });
          }

        }
      });
    }
  }


  void _setUpMap() async {
    print("SET UP");
    _firestore.collection('prayers').snapshots().listen((event) {
      for (DocumentSnapshot ds in event.documents) {
        print("CHANGED:" + ds.data.toString());
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
        for (int i = 0; i < markers.length; i++) {
          if (markers[i].markerId.value == ds.documentID) {
            markers.removeAt(i);
            break;
          }
        }
        if (this.mounted) {
          setState(() {
            markers.add(
              new Marker(
                  markerId: MarkerId(ds.documentID),
                  position: LatLng(ds.data['lat'], ds.data['lng']),
                  icon: BitmapDescriptor.defaultMarkerWithHue(hue),
                  onTap: () {
                    _viewMarker(currentPrayer);
                  }),
            );
          });
        }
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  //Database code
  Future<DocumentReference> addPrayertoDB(Prayer prayer) async {
    CollectionReference v = _firestore.collection('prayers');
    return v.add(prayer.toJson());
  }

  Future addLiveMarkerToDB(LiveMarker liveMarker) async {
    CollectionReference v = _firestore.collection('live');
    return v.document(user.uid).setData(liveMarker.toJson());
  }

  updateLiveMarker(LiveMarker liveMarker) async {
    _firestore
        .collection('live')
        .document(user.uid)
        .updateData(liveMarker.toJson());
  }

  updateUserLiveMarkerCoordinates(double lat, double lng) {
    _firestore.collection('live').document(user.uid).updateData({
      'lat': lat,
      'lng': lng,
    });
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
                          notes: holdNotes,
                          datetime: DateTime.now(),
                          lat: position.latitude,
                          lng: position.longitude,
                          goal: int.parse(addGoalController.text),
                          placeName: placeNameInputController.text,
                          cityName: cityInputController.text,
                          total: 1,
                        );
                        DocumentReference prayerReference =
                            await addPrayertoDB(addPrayer);
                        addPrayer.reference = prayerReference;
                        if (this.mounted) {
                          setState(() {
                            markers.add(new Marker(
                              markerId: MarkerId(prayerReference.documentID),
                              position: position,
                              onTap: () {
                                _viewMarker(addPrayer);
                              },
                            ));
                          });
                        }
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
                                        subtitle: Row(
                                          children: [
                                            Text(note[0]),
                                            Spacer(),
                                            Text("[Working on adding dates]")
                                          ],
                                        ),
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
                      onTap: liveMarkerID != currentPrayer.reference.documentID
                          ? () {
                              print(currentPrayer);
                              Navigator.pop(context, true);
                              currentPrayer.notes
                                  .insert(0, name + "|" + addNoteController.text);
                              currentPrayer.total++;
                              updatePrayer(currentPrayer);
                              LiveMarker newLiveMarker = LiveMarker(
                                uid: user.uid,
                                time: DateTime.now(),
                                lat: currentLocation.latitude,
                                lng: currentLocation.longitude,
                                markerID: currentPrayer.reference.documentID,
                              );
                              addLiveMarkerToDB(newLiveMarker);
                              liveMarkerID = currentPrayer.reference.documentID;
                              _firestore
                                  .collection('users')
                                  .document(user.uid)
                                  .updateData({
                                'live': true,
                              });
                              print('added to live');
                              start();
                              addNoteController.clear();
                            }
                          : () {
                              Navigator.pop(context, true);
                              stop();

                              //Use transaction to delete document?
                              _firestore
                                  .collection('live')
                                  .document(user.uid)
                                  .delete();

                              liveMarkerID = 'none';
                              _firestore
                                  .collection('users')
                                  .document(user.uid)
                                  .updateData({
                                'live': false,
                              });
                            },
                      child: liveMarkerID != currentPrayer.reference.documentID
                          ? Container(
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
                            )
                          : Container(
                              height: 50.0,
                              width: 300.0,
                              decoration: BoxDecoration(
                                  color: Colors.orange[500],
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(30.0),
                                  )),
                              child: Center(
                                  child: Text(
                                'Stop Praying',
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
      print('building');
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

Isolate isolate;

void start() async {
  print('STARTING');
  ReceivePort receivePort = ReceivePort();
  isolate = await Isolate.spawn(runTimer, receivePort.sendPort);
  receivePort.listen((message) async {
    print('removing');
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    Firestore.instance.collection('live').document(user.uid).delete();
    Firestore.instance.collection('users').document(user.uid).updateData({
      'live': false,
    });
    stop();
  });
}

void runTimer(SendPort sendPort) {
  int counter = 0;
  Timer.periodic(new Duration(minutes: 10), (timer) {
    counter++;
    String message = 'sending ' + counter.toString();
    print(message);
    sendPort.send(message);
  });
}

void stop() {
  if (isolate != null) {
    print('kill');
    isolate.kill(priority: Isolate.immediate);
    isolate = null;
  }
}