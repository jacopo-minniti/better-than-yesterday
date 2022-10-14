import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart'
    show pushNewScreen;
import 'package:provider/provider.dart';

import '../screens/partecipations_screen.dart';
import 'posts.dart';
import 'users.dart';

class LocalNotificationService {
  static final _notificationsPlugin = FlutterLocalNotificationsPlugin();
  static void initialize(BuildContext context) {
    const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: IOSInitializationSettings());
    _notificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? receiverId) async {
      if (receiverId != null) {
        pushNewScreen(context,
            screen: MultiProvider(providers: [
              ChangeNotifierProvider(create: (context) => Posts()),
              ChangeNotifierProvider(create: (context) => Users()),
            ], child: PartecipationsScreen(int.parse(receiverId))));
      }
    });
  }

  static void display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails('new_channel', 'default_channel',
              channelDescription: 'default channel for app',
              priority: Priority.high,
              playSound: true,
              importance: Importance.max),
          iOS: IOSNotificationDetails());
      await _notificationsPlugin.show(id, message.notification!.title,
          message.notification!.body, notificationDetails,
          payload: message.data['receiverId']);
    } on Exception catch (e) {
      print(e.toString());
    }
  }
}
