import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project_prayer/models/prayer.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController mapController;
  Position currentLocation;
  List<Marker> markers;
  final Firestore _firestore = Firestore.instance;

  @override
  void initState() {
    super.initState();
    markers = new List<Marker>();
    getCurrentLocation();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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
        new Marker(markerId: MarkerId("Current"),
        position: LatLng(currentLocation.latitude, currentLocation.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)),
      );
    }
  }

  void addPrayertoDB(Prayer prayer){
    CollectionReference v = _firestore.collection('prayers');
    v.add(prayer.toMap());
  }

  void getLocationPrayers(LatLng location){
    _firestore.collection('prayers').getDocuments().then((snapshot){
      for (DocumentSnapshot ds in snapshot.documents)
        ds.reference.delete();
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
    addPrayertoDB(new Prayer(id:null, note:"hi", datetime:1003, lat:100.100, lng:100.100, goal:45));
    markers.add(new Marker(
      markerId: MarkerId(position.hashCode.toString()),
      position: position,
    ));
    setState(() {

    });
  }
}
