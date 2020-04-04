import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<Case> provinceCases;

  @override
  void initState() {
    super.initState();
    provinceCases = new List<Case>();
    fillCases();
  }

  @override
  Widget build(BuildContext context) {
    if (provinceCases.length == 0) {
      return Scaffold(
        body: CircularProgressIndicator(),
      );
    } else {
      provinceCases.sort((a, b) => b.cases.compareTo(a.cases));
      return Scaffold(
        body: Column(
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height / 20,),
            Text('Current Statistics', textAlign: TextAlign.center, style: TextStyle(fontSize: 20),),
            SizedBox(height: MediaQuery.of(context).size.height / 30,),
            Expanded(
              child: ListView.builder(
                  itemCount: provinceCases.length,
                  itemBuilder: (context, index) {
                    return (Column(
                      children: <Widget>[
                        ListTile(
                          title: Text(provinceCases[index].province),
                          subtitle: Text(
                              'Infected: ${provinceCases[index].cases.toString()}'),
                          leading: Text('#${index + 1}'),
                        ),
                        Divider()
                      ],
                    ));
                  }),
            )
          ],
        )
      );
    }
  }

  getPlacemark() async {
    List<Placemark> list =
        await Geolocator().placemarkFromCoordinates(56.13, -106.35);
    print(list[0].administrativeArea);
  }

  fillCases() async {
    print('start');
    var value = await http.get(
        "https://api.apify.com/v2/key-value-stores/fabbocwKrtxSDf96h/records/LATEST?disableRedirect=true");
    var allData = json.decode(value.body)['infectedByRegion'];
    print("LENGTH: " + allData.length.toString());
    for (int i = 1; i < allData.length - 1; i++) {
      Case current = new Case(
          allData[i]['region'], int.parse(allData[i]['infectedCount']));
      provinceCases.add(current);
    }
    setState(() {});
  }
}

class Case {
  String province;
  int cases;

  Case(this.province, this.cases);
}
