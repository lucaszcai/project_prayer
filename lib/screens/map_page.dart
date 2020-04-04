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

  _showSelectImageDialog() {
    return _androidDialog();
  }



  _androidDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Add Photo'),
          children: <Widget>[
            SimpleDialogOption(
              child: Text('Take Photo'),
              onPressed: () {},
            ),
            SimpleDialogOption(
              child: Text('Choose From Gallery'),
              onPressed: () => {},
            ),
            SimpleDialogOption(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  void _onAddMarker(){
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context){
          return Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: SingleChildScrollView(
              child: Container(
                padding:
                EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 40.0,),
                    Text(
                      'La Centerra',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40
                      ),
                    ),
                    Text(
                      'Katy, Texas',
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 20
                      ),
                    ),
                    SizedBox(height: 50.0,),

                    GestureDetector(
                      onTap: _showSelectImageDialog,
                      child: Container(
                        height: 150,
                        width: 150,
                        color: Colors.grey[300],
                        child: Icon(Icons.add_a_photo, color: Colors.white70, size: 120.0,),
                      ),
                    ),

                    SizedBox(height: 50.0,),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 150.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Prayer Goal',
                        ),
                        keyboardType: TextInputType.numberWithOptions(),
                      ),
                    ),

                    SizedBox(height: 10.0,),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 50.0),
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Description',
                        ),
                      ),
                    ),

                    SizedBox(height: 50.0,),

                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.check),
                      iconSize: 30.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
    );
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
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: _onAddMarker,
        ),
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
