import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class DrinkStats extends StatefulWidget {
  const DrinkStats({Key? key, required this.data}) : super(key: key);

  final List<dynamic> data;

  @override
  _DrinkStatsState createState() => _DrinkStatsState(data);
}


class WaterLevel {
  final int time;
  final int waterLevel;

  WaterLevel(this.time, this.waterLevel);
}

class _DrinkStatsState extends State<DrinkStats> {

  var inputData = [];
  _DrinkStatsState(this.inputData);

  List<charts.Series<WaterLevel, int>> _createSampleData() {
    List<WaterLevel> plotData =[];

    var unpackedData = inputData.expand((i) => i).toList();
    unpackedData.removeWhere((item) => item == 0);

    for( var i = 0 ; i < unpackedData.length; i++ ) {
      plotData.add(WaterLevel(i, unpackedData[i]));
    }

    return [
      charts.Series<WaterLevel, int>(
        id: 'Sales',
        //colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (WaterLevel level, _) => level.time,
        measureFn: (WaterLevel level, _) => level.waterLevel,
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
      body: charts.LineChart(_createSampleData(), animate: true),
    );
  }
}

