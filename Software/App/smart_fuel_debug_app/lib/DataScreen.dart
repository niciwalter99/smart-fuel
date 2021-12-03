import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/foundation.dart';

class PlotData extends StatefulWidget {
  const PlotData({Key key, this.data}) : super(key: key);

  final List<dynamic> data;

  @override
  _PlotDataState createState() => _PlotDataState(data);
}


class WaterLevel {
  final int time;
  final int water_level;

  WaterLevel(this.time, this.water_level);
}

class _PlotDataState extends State<PlotData> {

  var input_data = [];
  _PlotDataState(List<dynamic> input_data) {
      this.input_data = input_data;
  }


  List<charts.Series<WaterLevel, int>> _createSampleData() {
    List<WaterLevel> data =[];

    var unpacked_data = input_data.expand((i) => i).toList();
    unpacked_data.removeWhere((item) => item == 0);

    print("unpacked data");
    print(unpacked_data);

    for( var i = 0 ; i < unpacked_data.length; i++ ) {
      data.add(new WaterLevel(i, unpacked_data[i]));
    }

    return [
      new charts.Series<WaterLevel, int>(
        id: 'Sales',
        //colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (WaterLevel level, _) => level.time,
        measureFn: (WaterLevel level, _) => level.water_level,
        data: data,
      )
    ];
  }



  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
        title: Text("Data Plot of your Bottle"),
        ),
        body: charts.LineChart(_createSampleData(), animate: false),
    );
  }
}

