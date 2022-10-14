import 'package:flutter/material.dart';

import '../utils/colors.dart';

class ElectricButton extends StatelessWidget {
  final VoidCallback buttonPressed;
  final String title;

  const ElectricButton({required this.buttonPressed, required this.title});

  @override
  Widget build(BuildContext context) {
    //ElevatedButton is simply an ElevatedButton with a custom decoration
    return ElevatedButton(
        onPressed: buttonPressed,
        style: ButtonStyle(
            elevation: MaterialStateProperty.all(10),
            backgroundColor: MaterialStateProperty.all(electricBlueColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
            ),
            alignment: Alignment.center,
            //size is constant for all MaterialStateProperties
            minimumSize: MaterialStateProperty.all(Size(
                MediaQuery.of(context).size.width * 0.6,
                MediaQuery.of(context).size.height * 0.06)),
            maximumSize: MaterialStateProperty.all(Size(
                MediaQuery.of(context).size.width * 0.8,
                MediaQuery.of(context).size.height * 0.3))),
        child: Text(
          title,
          style: const TextStyle(
              fontFamily: 'Ubuntu',
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 2),
          textAlign: TextAlign.center,
        ));
  }
}
