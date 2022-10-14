import 'package:better_than_yesterday/authentication_stream.dart';
//import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import './utils/colors.dart';
import 'services/authentication__service.dart';

// In order to make reading the code easier, it is recommended to first read the technical PDF about the project. In particular chapters 2 and 3

Future<void> backgroundHandler(RemoteMessage message) async {
  // as for now, there is no need to implement any backgorund action
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase
      .initializeApp(); //all firebase services require this method to start working
  //await FirebaseAppCheck.instance.activate();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation
        .portraitUp, // a social network has to be displayed exclusively in potrait mode
  ]);
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  runApp(
      const MyApp()); // this static function displays the widget we pass as parameter
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:
          electricBlueColor, //electricBlueColor is the color most representive of the app, thus I decided to customize the notification bar accordingly
    ));
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          //We istantiate the first actual provider of the application. As for convention, providers should be instatiated just one level above the first class where they need to be used
          value: AuthenticationService.instance(),
        ),
      ],
      child: const MaterialApp(
        title:
            'Better Than Yesterday', // the title displayed below the launcher
        debugShowCheckedModeBanner:
            false, //this is useful just in debug mode, as the banner is not diplayed in release mode
        home:
            AuthenticationStream(), //the actual home widget of the app, i.e. the widget shown initially, is not a screen
      ),
    );
  }
}
