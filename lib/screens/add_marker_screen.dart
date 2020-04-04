import 'package:flutter/material.dart';

class AddMarkerScreen extends StatefulWidget {
  @override
  _AddMarkerScreenState createState() => _AddMarkerScreenState();
}

class _AddMarkerScreenState extends State<AddMarkerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0.0,
        leading: BackButton(
          color: Colors.white,
        ),
      ),
    );
  }
}
