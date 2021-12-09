import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:smart_fuel_app/widgets/main_widget.dart';
import 'package:smart_fuel_app/widgets/circular_status.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:smart_fuel_app/drink_stats/drink_stats.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smart_fuel_app/drink_stats/data.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'package:simple_cluster/src/dbscan.dart';
import 'dart:convert';




class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Future<String> calculate(List<List<double>> inputData) async {
  print('function');

  DBSCAN dbscan = DBSCAN(
    epsilon: 2,
    minPoints: 3,
  );
  dbscan.run(inputData);
  print('end');

  return dbscan.label.toString();
}

class _MyHomePageState extends State<MyHomePage> {
  double drunken_water = 1340;
  List<List<double>> inputData = [];
  List<List<int>> lists = [];
  List<List<int>> filteredData = [];
  var cluster = [];
  bool notification_listener_set = false;
  int receivingPacket = 1;

  _readData(characteristic) async {
    characteristic.value.listen((value) {
      //List<int> readData = new List.from(value);
      print(value);
      lists.add(value);
      print(value.length);
      receivingPacket++;

      // if (readData.isNotEmpty && readData != []) {
      //   receivingPacket++;
      //   lists.add(value);
      //   print(value);
      // }
    });
  }

  void PushDrinkStatsWidget() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => DrinkStats(cluster: cluster, inputData: inputData)),
    );
  }

  Future<Null> _refreshLocalGallery() async {
    FlutterBlue flutterBlue = FlutterBlue.instance;
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    BluetoothDevice? waterBottle;
    receivingPacket = 1;
    lists = [];

    print(FlutterBlue.instance.state);

    // if(FlutterBlue.instance.state == BluetoothState.off) {
    //   print(" no BL");
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text("Bitte schalte dein Bluetooth an."),
    //   ));
    //   return;
    // }

// Listen to scan results
    var subscription = flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results) {
        if (r.device.name == "Smart Fuel Prototype") {
          waterBottle = r.device;
        }
      }
    });
    await Future.delayed(const Duration(seconds: 3));
    flutterBlue.stopScan();

    // If device is found
    if(waterBottle != null) {
      print(waterBottle!.name);
      await waterBottle!.connect();

      List<BluetoothService> services = await waterBottle!.discoverServices();
      // print('Services');
      BluetoothCharacteristic bottleData = services[2].characteristics[0];
      await bottleData.setNotifyValue(true);

      if (!notification_listener_set) {
        _readData(bottleData);

        notification_listener_set = true;
      }

      bottleData.write([2]);

      // Wait until no Packet is received for 500ms
      int i = 0;
      while (receivingPacket > i) {
        i = receivingPacket;
        await Future.delayed(const Duration(milliseconds: 500));
        i++;
      }
      print(lists.length);
      waterBottle!.disconnect();

      print("Start async calculation");


      //data = Data(inputData);

      print('start calc');
      var unpackedData = lists.expand((i) => i).toList();

      for (int i = 0; i < unpackedData.length; i++) {
        inputData.add([i.toDouble(), unpackedData[i].toDouble()]);
      }
      Future.delayed(Duration.zero,() async {
        String i = await compute(calculate, inputData);
        cluster = json.decode(i);
      });

    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Gerät konnte nicht gefunden werden"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(widget.title, style: const TextStyle(fontSize: 23))),
      ),
      body: LiquidPullToRefresh(
        onRefresh: _refreshLocalGallery,
        showChildOpacityTransition: false,
        springAnimationDurationInMilliseconds: 600,
        height: 70,
        color: const Color(0x2216B9ED),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularStatus(
                      progress: 600,
                      height: 70,
                      padding: 5,
                      width: 50,
                      child: const Text("M")),
                  CircularStatus(
                      progress: 800,
                      height: 70,
                      padding: 5,
                      width: 50,
                      child: const Text("D")),
                  CircularStatus(
                      progress: 1000,
                      height: 70,
                      padding: 5,
                      width: 50,
                      child: const Text("M")),
                  CircularStatus(
                      progress: 1200,
                      height: 70,
                      padding: 5,
                      width: 50,
                      child: const Text("D")),
                  CircularStatus(
                      progress: 1400,
                      height: 70,
                      padding: 5,
                      width: 50,
                      child: const Text("F")),
                  CircularStatus(
                      progress: 100,
                      height: 70,
                      padding: 5,
                      width: 50,
                      child: const Text("S")),
                  // CircularStatus(
                  //     progress: 30, height: 50, padding:10, child: const Text("M")),
                ],
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Heute",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              CircularStatus(
                progress: drunken_water,
                height: 200,
                width: 180,
                padding: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        height: 50,
                        child: SvgPicture.asset(
                            "assets/glass_icon.svg"
                        ),
                      ),
                    ),
                    Text(drunken_water.round().toString(),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text("ml",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 100,
                  child: MainWidget(
                    title: "Trinkgewohnheiten",
                    subTitle: "Betrachte deine Trends",
                    iconPath: "assets/stats_icon.svg",
                    onPressedFunction: PushDrinkStatsWidget,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 100,
                  child: MainWidget(
                    title: "Wiegen",
                    subTitle: "Deine Flasche als Waage",
                    iconPath: "assets/waage_icon.svg",
                    onPressedFunction: PushDrinkStatsWidget,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 100,
                  child: MainWidget(
                    title: "Flasche",
                    subTitle: "Personalisiere deine Flasche",
                    iconPath: "assets/bottle_icon.svg",
                    onPressedFunction: PushDrinkStatsWidget,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 100,
                  child: MainWidget(
                    title: "Einstellungen",
                    subTitle: "Konto, Benachrichtigungen ...",
                    iconPath: "assets/setting_icon.svg",
                    onPressedFunction: PushDrinkStatsWidget,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
