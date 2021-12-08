import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/scheduler.dart';
import 'package:smart_fuel_app/drink_stats/data.dart';

class DrinkStats extends StatefulWidget {
  const DrinkStats({Key? key, required this.data}) : super(key: key);

  final List<List<int>> data;

  @override
  _DrinkStatsState createState() => _DrinkStatsState(data);
}

class WaterLevel {
  final int timestamp;
  final int value;
  final int cluster;

  WaterLevel(this.timestamp, this.value, this.cluster);
}

class _DrinkStatsState extends State<DrinkStats> {
  List<List<int>> inputData = [];

  _DrinkStatsState(this.filteredData);

  List<int> unpackedData = [];
  List<List<int>> filteredData = [];
  List<List<int>> plotData = [];
  DayStats? dayStats;

  Future<void> processData() async {
    unpackedData = inputData.expand((i) => i).toList();
    Data data = Data(unpackedData);
    //filteredData = await data.filterData();
    dayStats = await data.analyzeData(filteredData);
    plotData = data.getDataForPlot(filteredData);

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      processData();
    });
    dayStats =
        DayStats(sumOfWater: 0, bottleFillUp: 0, nipCounter: 0, avgGulpSize: 0);
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
