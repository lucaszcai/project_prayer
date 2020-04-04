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
          SizedBox(height: 15,),
          Text(
            'Statistics',
            style: TextStyle(
              fontSize: 40.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15.0,),
          Expanded(
            child: ListView.builder(
              itemCount: provinces.length,
                itemBuilder: (context, index){
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Container(
                      height: 75.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(width: 25, child: Center(child: Text('#' +(index+1).toString(), style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),))),
                          Container(width: 100,child: Center(child: Text(provinces[index], style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),))),
                          Container(width: 120, child: Center(child: Text('12315 Cases', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),))),
                          Container(width: 110, child: Center(child: Text('345 Prayers', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400)))),
                        ],
                      )
                    ),
                  );
                }
            ),
          )
        ],
      )
    );
  }
}
