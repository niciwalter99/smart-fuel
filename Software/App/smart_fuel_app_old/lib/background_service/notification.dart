
import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _notificationService =
  NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  Future<void> init() async {
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin!.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    // Timer.periodic(new Duration(seconds: 1), (timer) {
      //_showNotificationWithNoBadge("TestiTest", "Connected");
    // });
  }

  Future<void> showNotificationWithNoBadge(String? title, String? body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'no badge channel', 'no badge name', channelDescription:'no badge description',
        channelShowBadge: false,
        importance: Importance.max,
        priority: Priority.high,
        onlyAlertOnce: true);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin!
        .show(0, title, body, platformChannelSpecifics, payload: 'item x');
  }

  Future<void> onDidReceiveLocalNotification(int? id, String? title,
      String? body, String? payload) async {
  }

  Future<void> onSelectNotification(String? payload) async {
    if (payload != null) {
      print(payload);
    }
  }
}


