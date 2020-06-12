import 'dart:convert';
import 'dart:math';

import 'package:adopt_a_street/helpers/graph_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<Case> provinceCases;
  List<String> provinces;
  String selectedProvince;
  List<GraphStats> statsList;
  int maxInfectedCount;
  GraphHelper graphHelper = new GraphHelper();

  @override
  void initState() {
    super.initState();
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
    if (provinceCases.length == 0) {
      return Scaffold(
        body: CircularProgressIndicator(),
      );
    } else {
      provinceCases.sort((a, b) => b.cases.compareTo(a.cases));
      return Scaffold(
        body: Column(
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
                  getProvinceHistory();
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
      provinces.add(allData[i]['region']);
      provinceCases.add(current);
    }
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
      List<FlSpot> graphPoints = new List<FlSpot>();
      for (int i = 0; i < statsList.length; i++) {
        GraphStats stat = statsList[i];
        graphPoints
            .add(new FlSpot(stat.dateInt + 0.0, stat.infectedCount + 0.0));
      }
      return Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(12.0),
          child: createLineGraph(graphPoints));
    }
  }

  getProvinceHistory() async {
    statsList.clear();
    setState(() {});
    int holdMaxInfectedCount = 0;
    print('got');
    var jsonData = await http.get(
        'https://api.apify.com/v2/datasets/ji95MgtBVgGJF7XcP/items',
        headers: {'format': 'json', 'clean': '1'});
    print('got');
    var allData = json.decode(jsonData.body);
    for (int i = 0; i < allData.length; i++) {
      List provinceData = allData[i]['infectedByRegion'];
      if (provinceData != null) {
        for (int j = 0; j < provinceData.length; j++) {
          if (provinceData[j]['region'] == selectedProvince) {
            print(provinceData[j]);
            if (provinceData[j]['infectedCount'] != '') {
              String infectedCount = provinceData[j]['infectedCount'];
              String lastUpdated = allData[i]['lastUpdatedAtApify'];

              infectedCount = trim(infectedCount);
              lastUpdated = trim(lastUpdated);

              int caseCount = int.parse(infectedCount);
              DateTime putDate = DateTime.parse(lastUpdated);
              int intDate = graphHelper.dateToInt(putDate);

              holdMaxInfectedCount = max(holdMaxInfectedCount, caseCount);

              statsList.add(
                  new GraphStats(infectedCount: caseCount, dateInt: intDate));
            }
            break;
          }
        }
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
        minX: 75,
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
                print('length: ' + spots.length.toString());
                List<LineTooltipItem> returnItems = new List<LineTooltipItem>();
                for (int i = 0; i < spots.length; i++) {
                      returnItems.add(LineTooltipItem( //TODO edit next few lines?
                      graphHelper.doubleToDate(spots[i].bar.spots[spots[i].spotIndex].x) +
                          ': ' +
                      spots[i].bar.spots[spots[i].spotIndex].y.toStringAsFixed(0),
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

  Case(this.province, this.cases);
}

class GraphStats {
  int infectedCount;
  int dateInt;

  GraphStats({this.infectedCount, this.dateInt});
}
