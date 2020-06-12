import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:adopt_a_street/screens/map_page.dart';
import 'package:adopt_a_street/screens/statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;
  var _pageOptions = [
    MapPage(),
    StatisticsScreen(),
    //ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        //leading: Icon(Icons.menu, color: Colors.black,),
      ),*/
      /*
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            DrawerHeader(child: Text('Lucas Cai', style: TextStyle(fontSize: 30.0),),),
            Container(
              padding: EdgeInsets.all(10.0),
              margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 25.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.flag,
                    color: Colors.black,
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    'Prayers: 25',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 25.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.add_location,
                    color: Colors.black,
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    'Markers Created: 74',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      */
      body: _pageOptions[_selectedTab],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.black54,
                blurRadius: 5.0,
                offset: Offset(0.0, 0.75)
            )
          ],
          color: Colors.blue,
        ),
        child: CurvedNavigationBar(
          height: MediaQuery.of(context).size.height / 14,
          backgroundColor: Colors.grey[200],
          items: <Widget>[
            Icon(Icons.map, size: 30),
            Icon(Icons.insert_chart, size: 30),
            //Icon(Icons.account_circle, size: 30),
          ],
          onTap: (index) {
            setState(() {
              _selectedTab = index;
            });
          },
        ),
      ),
    );
  }
}
