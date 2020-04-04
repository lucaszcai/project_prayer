import 'package:flutter/material.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {

  List<String> provinces = ['toronto', 'ottowa', 'katy', 'texas'];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            'Statistics',
            style: TextStyle(
              fontSize: 40.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 30.0,),
          ListView.builder(
            itemCount: provinces.length,
              itemBuilder: (context, index){
                return Container(
                  height: 100.0,
                  child: Row(
                    children: <Widget>[

                    ],
                  )
                );
              }
          )
        ],
      )
    );
  }
}
