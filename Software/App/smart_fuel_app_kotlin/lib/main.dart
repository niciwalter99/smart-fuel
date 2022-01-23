import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'background_service/notification.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

import 'drink_stats/data.dart';
import 'home_page.dart';

void backgroundFetchHeadlessTask(HeadlessTask task) async {
  if (task.timeout) {
    print("[BackgroundFetch] Headless task timed-out: ${task.taskId}");
    BackgroundFetch.finish(task.taskId);
    return;
  }

  MyApp.backgroundConnect();

  BackgroundFetch.finish(task.taskId);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  static Future<void> backgroundConnect() async {
    DayStats dayStats = await MyApp.getDrinkData();
    if (dayStats.avgGulpSize != -1) {
      NotificationService().init();
      NotificationService().showNotificationWithNoBadge("Trinkerinnerung",
          "Hey! Du hast heute erst ${dayStats.sumOfWater} ml getrunken...");

      await HomeWidget.saveWidgetData<int>('_counter', dayStats.sumOfWater);
      await HomeWidget.updateWidget(
          name: 'AppWidgetProvider', iOSName: 'AppWidgetProvider');
    } else {
      NotificationService().init();
      NotificationService().showNotificationWithNoBadge(
          "Trinkerinnerung", "Hey! Deine Flasche wurde nicht gefunden");
    }
  }

  static Future<DayStats> getDrinkData() async {
    FlutterBlue flutterBlue = FlutterBlue.instance;

    BluetoothDevice? waterBottle;
    int receivingPacket = 1;
    List<List<int>> lists = [];

    bool scan_running = true;
    print(FlutterBlue.instance.state);

    List<BluetoothDevice> connectedDevices = await flutterBlue.connectedDevices;
    bool alreadyConnected = false;
    for (int i = 0; i < connectedDevices.length; i++) {
      if (connectedDevices[i].id.toString() == "C8:B7:77:63:9D:09") {
        waterBottle = connectedDevices[i];
        alreadyConnected = true;
        print('already connected');
        await waterBottle.connect();
        break;
      }
    }

    if (!alreadyConnected) {
      print('Start Scan');
      flutterBlue.startScan(
          withServices: [Guid("00001523-1212-efde-1523-785feabcd123")],
          timeout: const Duration(seconds: 10),
          allowDuplicates: true,
          request_permission: false);

      // Listen to scan results
      var subscription = flutterBlue.scanResults.listen((results) {
        // do something with scan results
        print('in Subscription method');
        for (ScanResult r in results) {
          print("Found Something here");
          if (r.device.id.toString() == "C8:B7:77:63:9D:09") {
            waterBottle = r.device;
            flutterBlue.stopScan();
            scan_running = false;
          }
        }
      });

      Timer(const Duration(seconds: 15), () {
        scan_running = false;
        flutterBlue.stopScan();
        subscription.cancel();
      });

      while (scan_running) {
        await Future.delayed(const Duration(seconds: 1));
      }

      print("end of scan");
    }

    // If device is found
    if (waterBottle != null) {
      print(waterBottle!.name);

      if (!alreadyConnected) {
        await waterBottle!.connect();
      }

      List<BluetoothService> services = await waterBottle!.discoverServices();
      // print('Services');
      BluetoothCharacteristic bottleData = services[2].characteristics[0];
      await bottleData.setNotifyValue(true);

      var s = bottleData.value.listen((value) {
        lists.add(value);
        receivingPacket++;
        print(value.length);
        print(value);
      });

      bottleData.write([2]);

      // Wait until no Packet is received for 500ms
      int i = 0;
      while (receivingPacket > i) {
        i = receivingPacket;
        await Future.delayed(const Duration(milliseconds: 500));
        i++;
      }
      s.cancel();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? lastDelete = prefs.getString("last_delete");

      DateTime date(DateTime dateTime) =>
          DateTime(dateTime.year, dateTime.month, dateTime.day);

      if(lastDelete != null) {
        DateTime lastDeleteDay = DateTime.parse(lastDelete);
        if (date(DateTime.now()).difference(date(lastDeleteDay)).inHours > 0) {
         print("delete now");
         prefs.setString("last_delete", DateTime.now().toString());
         bottleData.write([3]); // Delete Data on Bottle
        }
      }
      else {
        print("Last Delete Value is null");
        prefs.setString("last_delete", DateTime.now().toString());
        bottleData.write([3]); // Delete Data on Bottle
      }
      waterBottle!.disconnect();
    }
    print('END OF connection!');

    if (lists.isNotEmpty) {
      print("List is not empty!");
      Data data = Data();
      data.calculateCluster(4, 6, lists.expand((i) => i).toList());
      data.filterData();
      DayStats dayStats = data.analyzeData();
      print('Water drunk today is: ');
      print(dayStats.sumOfWater);

      return dayStats;
    } else {
      print("List is empty!");
      return DayStats(
          sumOfWater: -1, bottleFillUp: -1, nipCounter: -1, avgGulpSize: -1);
    }
  }

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
