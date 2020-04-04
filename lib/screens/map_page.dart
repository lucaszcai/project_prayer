import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController mapController;
  Position currentLocation;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void getCurrentLocation() async {
    var status = await Permission.location.status;

    if (status.isUndetermined || status.isRestricted || status.isDenied) {
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
    }
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
            zoom: 5,
          ),
        ),
      );
    }
  }
}
