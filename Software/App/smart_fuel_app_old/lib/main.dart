import 'dart:async';

import 'package:flutter/material.dart';

import 'package:smart_fuel_app/home_page.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:path_provider/path_provider.dart';

import 'package:smart_fuel_app/background_service/notification.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:smart_fuel_app/drink_stats/data.dart';

void isolate2(String arg) {
  getTemporaryDirectory().then((dir) {
    print("isolate2 temporary directory: $dir");
  });
  Timer.periodic(const Duration(seconds: 30), (timer) async {
    print("Timer Running From Isolate 2");

    FlutterBlue flutterBlue = FlutterBlue.instance;
    print(flutterBlue);
    print('Start Scan');
    await flutterBlue.startScan(timeout: const Duration(seconds: 4));
    print('End of Scan');
    BluetoothDevice? waterBottle;
    int receivingPacket = 1;
    List<List<int>> lists = [];

// // Listen to scan results
//     var subscription = flutterBlue.scanResults.listen((results) {
//       // do something with scan results
//       for (ScanResult r in results) {
//         if (r.device.name == "Smart Fuel Prototype") {
//           waterBottle = r.device;
//         }
//       }
//     });
//     await Future.delayed(const Duration(seconds: 3));
//     flutterBlue.stopScan();
//
//     // If device is found
//     if (waterBottle != null) {
//       print(waterBottle!.name);
//       await waterBottle!.connect();
//
//       List<BluetoothService> services = await waterBottle!.discoverServices();
//       // print('Services');
//       BluetoothCharacteristic bottleData = services[2].characteristics[0];
//       await bottleData.setNotifyValue(true);
//
//       // if (!notification_listener_set) {
//       // _readData(bottleData);
//       //
//       // notification_listener_set = true;
//       // }
//
//       bottleData.write([2]);
//
//       // Wait until no Packet is received for 500ms
//       int i = 0;
//       while (receivingPacket > i) {
//         i = receivingPacket;
//         await Future.delayed(const Duration(milliseconds: 500));
//         i++;
//       }
//       waterBottle!.disconnect();
//     }
//     print('END OF connection!');
//
//     Data data = Data();
//     data.calculateCluster(4, 6, lists.expand((i) => i).toList());
//     data.filterData();
//     DayStats dayStats = data.analyzeData();
//     print('Water drunk today is: ');
//     print(dayStats.sumOfWater);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isolate = await FlutterIsolate.spawn(isolate2, "hello");
  Timer(Duration(minutes: 1), () {
    print("Kill Isolate 1");
    isolate.kill();
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Fuel',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF4F6F6),
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Colors.white,
          onPrimary: Colors.black,
          // Colors that are not relevant to AppBar in LIGHT mode:
          primaryVariant: Colors.grey,
          secondary: Colors.grey,
          secondaryVariant: Colors.grey,
          onSecondary: Colors.grey,
          background: Colors.grey,
          onBackground: Colors.grey,
          surface: Colors.grey,
          onSurface: Colors.grey,
          error: Colors.grey,
          onError: Colors.grey,
        ),
      ),
      home: const MyHomePage(title: 'Smart Fuel'),
    );
  }
}

class Palette {
  static const MaterialColor grey = const MaterialColor(
    0xffe55f48,
    // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    const <int, Color>{
      50: const Color(0xffce5641), //10%
      100: const Color(0xFFF4F6F6), //20%
      200: const Color(0xffa04332), //30%
      300: const Color(0xff89392b), //40%
      400: const Color(0xff733024), //50%
      500: const Color(0xff5c261d), //60%
      600: const Color(0xff451c16), //70%
      700: const Color(0xff2e130e), //80%
      800: const Color(0xff170907), //90%
      900: const Color(0xff000000), //100%
    },
  );
} // y
