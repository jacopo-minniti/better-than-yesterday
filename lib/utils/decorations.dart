import 'package:flutter/material.dart';

import '../utils/colors.dart';
//As for now, this file contains only one method

InputDecoration fieldDecoration(String label, String hint) {
  //given the label and the hintText to display, the fieldDecoration method returns an ImutDecoration.
  //InputDecoration is used by TextField widgets for styling
  return InputDecoration(
    label: Text(
      label,
      style: const TextStyle(
          color: Colors.black87, letterSpacing: 2, fontWeight: FontWeight.w400),
    ),
    hintText: hint,
    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    border: const OutlineInputBorder(
      borderSide: BorderSide(color: electricBlueColor, width: 1.3),
      borderRadius: BorderRadius.all(
        Radius.circular(14.0),
      ),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: electricBlueColor, width: 1.3),
      borderRadius: BorderRadius.all(
        Radius.circular(14.0),
      ),
    ),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: electricBlueColor, width: 1.3),
      borderRadius: BorderRadius.all(
        Radius.circular(14.0),
      ),
    ),
    errorBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: electricBlueColor, width: 1.3),
      borderRadius: BorderRadius.all(
        Radius.circular(14.0),
      ),
    ),
  );
}
