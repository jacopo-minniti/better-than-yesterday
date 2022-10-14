import 'package:flutter/material.dart';

//this screen is displayed during the initial loading of the app. It simply contains the logo of the app centered
class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Image.asset('assets/images/new_logo.png')),
      ),
    );
  }
}
