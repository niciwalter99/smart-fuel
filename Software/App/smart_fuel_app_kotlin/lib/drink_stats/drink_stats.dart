import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:home_widget/home_widget.dart';


import 'data.dart';

class DrinkStats extends StatefulWidget {
  const DrinkStats({Key? key, required this.inputData}) : super(key: key);

  final List<int> inputData;

  @override
  _DrinkStatsState createState() => _DrinkStatsState(inputData);
}

class WaterLevel {
  final int timestamp;
  final int value;
  final int cluster;

  WaterLevel(this.timestamp, this.value, this.cluster);
}

class _DrinkStatsState extends State<DrinkStats> {
  List<int> inputData;

  _DrinkStatsState(this.inputData);

  List<int> unpackedData = [];
  List<List<int>> filteredData = [];
  List<List<int>> plotData = [];
  DayStats? dayStats;

  @override
  void initState() {
    super.initState();
    print(inputData);
    if (inputData.isEmpty) {
      dayStats = DayStats(sumOfWater: 0,
          bottleFillUp: 0,
          nipCounter: 0,
          avgGulpSize: 0);
    } else {
      Data data = Data();
      data.calculateCluster(4, 6, inputData);
      data.filterData();
      dayStats = data.analyzeData();
      plotData = data.getDataForPlot();
      HomeWidget.saveWidgetData<int>('_counter', dayStats!.sumOfWater);
      HomeWidget.updateWidget(name: 'AppWidgetProvider', iOSName: 'AppWidgetProvider');
    }
  }

  List<charts.Series<List<int>, int>> _createSampleData() {
    return [
      charts.Series<List<int>, int>(
        id: 'Sales',
        //colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (List<int> level, _) => level[1],
        measureFn: (List<int> level, _) => level[0],
        data: plotData,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trinkgewohnheiten"),
      ),
      body: Column(
        children: [
          Expanded(
              flex: 5,
              child: charts.LineChart(_createSampleData(), animate: true)),
          Expanded(
            flex: 5,
            child: Column(
              children: [
                const Text("Daten von einem Tag",
                    style: TextStyle(fontSize: 35.0)),
                Text("Gesamtmenge: ${dayStats!.sumOfWater} ml ",
                    style: TextStyle(fontSize: 25.0)),
                Text("Aufgefüllt: ${dayStats!.bottleFillUp}",
                    style: TextStyle(fontSize: 25.0)),
                Text("Schluckgröße: ${dayStats!.avgGulpSize} ml",
                    style: TextStyle(fontSize: 25.0)),
                Text("Nippcounter: ${dayStats!.nipCounter}",
                    style: TextStyle(fontSize: 25.0)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
