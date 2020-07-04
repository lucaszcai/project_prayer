import 'dart:convert';
import 'dart:math';

import 'package:adopt_a_street/helpers/graph_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<Case> allCases;
  List<Case> provinceCases;
  List<String> provinces;
  String selectedProvince;
  List<GraphStats> statsList;
  int maxInfectedCount;
  GraphHelper graphHelper = new GraphHelper();

  @override
  void initState() {
    super.initState();
    allCases = new List<Case>();
    provinceCases = new List<Case>();
    provinces = new List<String>();
    statsList = new List<GraphStats>();
    provinces.add('All');
    selectedProvince = 'All';
    fillCases();
  }

  List loadDropdownItems() {
    return provinces.map((String province) {
      return new DropdownMenuItem(
        child: Text(province),
        value: province,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (allCases.length == 0) {
      return Scaffold(
        body: CircularProgressIndicator(),
      );
    } else {
      return Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height / 20,
              ),
              Text(
                'Current Statistics',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 60,
              ),
              DropdownButton(
                items: loadDropdownItems(),
                value: selectedProvince,
                onChanged: (newProvince) {
                  if (newProvince != 'All') {
                    getProvinceHistoryUpdated(newProvince);
                  }
                  setState(() {
                    selectedProvince = newProvince;
                  });
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 70,
              ),
              showStatistics(),
            ],
          ),
        ),
      );
    }
  }

  getPlacemark() async {
    List<Placemark> list =
        await Geolocator().placemarkFromCoordinates(56.13, -106.35);
  }

  fillCases() async {
    Map<String, int> currentProvinceCases = new Map<String, int>();
    var value = await http.get(
        "https://api.covid19api.com/country/Canada/status/confirmed");
    var allData = json.decode(value.body);
    for (int i = 0; i < allData.length - 1; i++) {
      Case currentCase;
      if (allData[i]['Province'] == null || allData[i]['Province'] == '') {
        currentCase = new Case('All', allData[i]['Cases'], date: DateTime.parse(allData[i]['Date']));
        currentProvinceCases['All'] = allData[i]['Cases'];
      } else {
        if (allData[i]['Province'] == 'Grand Princess') {
          continue;
        }
        currentCase = new Case(allData[i]['Province'], allData[i]['Cases'], date: DateTime.parse(allData[i]['Date']));
        currentProvinceCases[allData[i]['Province']] = allData[i]['Cases'];
      }
      allCases.add(currentCase);
    }
    provinces = currentProvinceCases.keys.toList();
    provinces.sort();
    for (int i = 0; i < provinces.length; i++) {
      provinceCases
          .add(new Case(provinces[i], currentProvinceCases[provinces[i]]));
    }
    allCases.sort((Case caseA, Case caseB) {
      if (caseA.province == caseB.province) {
        if (caseA.date == caseB.date) {
          return caseA.cases.compareTo(caseB.cases);
        }
        else {
          return caseA.date.compareTo(caseB.date);
        }
      }
      else {
        return caseA.province.compareTo(caseB.province);
      }
    });
    provinceCases.sort((Case caseA, Case caseB){
      if (caseA.cases == caseB.cases) {
        return caseA.province.compareTo(caseB.province);
      }
      else {
        return caseB.cases.compareTo(caseA.cases);
      }
    });
    setState(() {});
  }

  Widget showStatistics() {
    if (selectedProvince == 'All') {
      return Expanded(
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
                    onTap: () {
                      setState(() {
                        getProvinceHistoryUpdated(provinceCases[index].province);
                        selectedProvince = provinceCases[index].province;
                      });
                    },
                  ),
                  Divider()
                ],
              ));
            }),
      );
    } else {
      if (statsList.length == 0) {
        return CircularProgressIndicator();
      }
      statsList.sort((GraphStats graphStatsA, GraphStats graphStatsB) {
        return graphStatsA.dateInt.compareTo(graphStatsB.dateInt);
      });
      List<FlSpot> graphPoints = new List<FlSpot>();
      for (int i = 0; i < statsList.length; i++) {
        GraphStats stat = statsList[i];
        graphPoints
            .add(new FlSpot(stat.dateInt + 0.0, stat.infectedCount + 0.0));
      }
      return Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(18.0, 0, 26.0, 0),
          child: createLineGraph(graphPoints));
    }
  }

  getProvinceHistoryUpdated(String givenProvince) {
    statsList.clear();
    int holdMaxInfectedCount = 0;
    for (int i = 0; i < allCases.length; i++) {
      if (allCases[i].province != givenProvince) {
        continue;
      }
      else {
        holdMaxInfectedCount = max(holdMaxInfectedCount, allCases[i].cases);
        statsList.add(new GraphStats(infectedCount: allCases[i].cases, dateInt: graphHelper.dateToInt(allCases[i].date)));
      }
    }
    setState(() {
      maxInfectedCount = holdMaxInfectedCount;
    });
  }

  String trim(String given) {
    if (given.substring(0, 1) == '\'' || given.substring(0, 1) == '\"') {
      given = given.substring(1);
    }
    if (given.substring(given.length - 1) == '\'' ||
        given.substring(given.length - 1) == '\"') {
      given = given.substring(0, given.length - 1);
    }
    return given;
  }

  Widget createLineGraph(List<FlSpot> graphPoints) {
    return LineChart(
      LineChartData(
        maxY: maxInfectedCount + maxInfectedCount / 5,
        minX: 0,
        lineBarsData: [
          LineChartBarData(
            spots: graphPoints,
            colors: [Colors.lightBlue],
            barWidth: 4.0,
            isCurved: false,
            dotData: FlDotData(show: false),
          )
        ],
        borderData: FlBorderData(
          border: Border.all(color: Colors.grey),
        ),
        titlesData: FlTitlesData(
          leftTitles: SideTitles(
            showTitles: true,
            interval: maxInfectedCount / 5,
          ),
          bottomTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitles: (value) {
                return graphHelper.doubleToAxisValue(value);
              }),
        ),
        gridData: FlGridData(
          horizontalInterval: maxInfectedCount / 5,
          show: true,
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
              tooltipRoundedRadius: 8.0,
              tooltipBgColor: Colors.grey[200],
              getTooltipItems: (List<LineBarSpot> spots) {
                List<LineTooltipItem> returnItems = new List<LineTooltipItem>();
                for (int i = 0; i < spots.length; i++) {
                  returnItems.add(LineTooltipItem(
                      //TODO edit next few lines?
                      graphHelper.doubleToDate(
                              spots[i].bar.spots[spots[i].spotIndex].x) +
                          ': ' +
                          spots[i]
                              .bar
                              .spots[spots[i].spotIndex]
                              .y
                              .toStringAsFixed(0),
                      TextStyle(
                        fontSize: 14.0,
                        color: Colors.blue,
                      )));
                }
                return returnItems;
              }),
        ),
      ),
    );
  }
}

class Case {
  String province;
  int cases;
  DateTime date;

  Case(this.province, this.cases, {this.date});
}

class GraphStats {
  int infectedCount;
  int dateInt;

  GraphStats({this.infectedCount, this.dateInt});
}
