import 'package:flutter/material.dart';
import 'package:adopt_a_street/screens/add_marker_screen.dart';
import 'package:adopt_a_street/screens/entry_screen.dart';
import 'package:adopt_a_street/screens/home_screen.dart';
import 'package:adopt_a_street/screens/login_screen.dart';
import 'package:adopt_a_street/screens/map_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/login': (context) => EntryScreen(),
      },
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EntryScreen(),
    );
  }
}
