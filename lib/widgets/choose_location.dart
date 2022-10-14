import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart'
    show pushNewScreen;

import '../screens/choose_location_screen.dart';
import '../utils/colors.dart';

class ChooseLocation extends StatefulWidget {
  String? _address;
  Function(String) retrieveAddress;
  ChooseLocation(this._address, this.retrieveAddress);

  @override
  State<ChooseLocation> createState() => _ChooseLocationState();
}

class _ChooseLocationState extends State<ChooseLocation> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, right: 25, left: 25, bottom: 6),
      child: InkWell(
        onTap: chooseLocation, //all the logic is contained in this function
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            widget._address == null
                ? const Icon(
                    Icons.close,
                    color: Colors.red,
                  )
                : const Icon(
                    Icons.done,
                    color: Colors.green,
                  ),
            Flexible(
              child: Text(
                widget._address == null
                    ? 'Seleziona il luogo'
                    : widget._address!,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Ubuntu',
                    color: darkBlueColor,
                    fontSize: 15,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(
              Icons.place_outlined,
              color: darkBlueColor,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> chooseLocation() async {
    //add is defined starting from a pushNewScreen() functions, which is needed to change screen. This is possible, as ChooseLocationScreen, when popped, returns an argument. If the user just clicked the back-arrow to close the page, add = null
    final add =
        await pushNewScreen(context, screen: const ChooseLocationScreen());
    if (add != null) {
      //in other words, if the user actually chose a location
      setState(() {
        widget._address =
            add; //the class variable is set to be equal to the local variable
      });
      widget.retrieveAddress(
          add); //the callback is needed to set the variable in another widget (i.e. screen) equal to _address.
    }
  }
}
