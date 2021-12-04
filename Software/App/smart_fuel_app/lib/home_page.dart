import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:smart_fuel_app/widgets/main_widget.dart';
import 'package:smart_fuel_app/widgets/circular_status.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:smart_fuel_app/drink_stats.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double drunken_water = 1340;
  var lists = [];
  bool notification_listener_set = false;

  void PushDrinkStatsWidget() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => DrinkStats(data: lists)),
    );
  }

  Future<Null> _refreshLocalGallery() async {
    FlutterBlue flutterBlue = FlutterBlue.instance;
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    BluetoothDevice? waterBottle;
    int receivingPacket = 1;
    lists = [];

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

    print('connect');
    print(waterBottle!.name);
    await waterBottle!.connect();

    List<BluetoothService> services = await waterBottle!.discoverServices();
    // print('Services');
    BluetoothCharacteristic bottleData = services[2].characteristics[0];
    await bottleData.setNotifyValue(true);

    if (!notification_listener_set) {
      bottleData.value.listen((value) {
        receivingPacket++;
        lists.add(value);
      });
      notification_listener_set = true;
    }

    await bottleData.write([2]);

    // Wait until no Packet is received for 500ms
    int i = 0;
    while (receivingPacket > i) {
      i = receivingPacket;
      await Future.delayed(const Duration(milliseconds: 500));
      i++;
    }
    print('disconnect');
    print(lists);
    waterBottle!.disconnect();
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
                        child: Image.asset("assets/glass_icon.png"),
                      ),
                    ),
                    Text(drunken_water.round().toString(),
                        style: TextStyle(
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
                    iconPath: "assets/stats_icon.png",
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
                    iconPath: "assets/waage_icon.png",
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
                    iconPath: "assets/bottle_icon.png",
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
                    iconPath: "assets/setting_icon.png",
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
