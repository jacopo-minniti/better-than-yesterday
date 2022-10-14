import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'colors.dart';

showCustomSnackbar(BuildContext context, String content) {
  //shoCustomSnackbar is widely used across the application. It shows a custom snackbar with a customized color, duration, and style.
  //The only non-constant paramater is the text content to display.
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    behavior: SnackBarBehavior.floating,
    elevation: 0.0,
    backgroundColor: Colors.transparent,
    width: double.infinity,
    content: Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 13),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: electricBlueColor,
        border: Border.all(color: electricBlueColor, width: 3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        padding: const EdgeInsets.only(left: 8.0),
        child: Text(
          content,
          style: const TextStyle(
              color: Colors.white, fontSize: 15, letterSpacing: 1.4),
          textAlign: TextAlign.center,
        ),
      ),
    ),
    duration: const Duration(seconds: 3),
  ));
}

Future<File?> pickImage(BuildContext context) async {
  //an ImagePicker object is instatiated. The ImagePicker class comes from the image_picker package.
  final _picker = ImagePicker();
  //A CrossFile is a cross-platform, simplified File abstraction
  XFile? im;
  //it shows a dialog to choose between camera and gallery as source to select a photo.
  //In both cases, when selected the dialog is closed and the image returned
  await showDialog(
      context: context,
      builder: ((context) => AlertDialog(
            title: const Text('Come vuoi scegliere la foto?'),
            actions: [
              TextButton(
                  onPressed: () async {
                    im = await _picker.pickImage(source: ImageSource.gallery);

                    Navigator.of(context).pop();
                  },
                  child: const Text('Galleria')),
              TextButton(
                  onPressed: () async {
                    im = await _picker.pickImage(source: ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Fotocamera')),
            ],
          )));
  //there is the possibility that a picker is closed but the user did not select any image. In that case, im will be equal to null
  if (im == null) {
    return null;
  }
  //Otherwise, the imamge was selected and the XFile is casted into a classic file
  return File(im!.path);
}

String formatDate(String date) {
  //the string date is in the form of yyyy-mm-dd hh-mm-ss (eg. 2022-11-03 18:10:00)
  //we want only the date, so we take a sub string only of the first ten characters
  final d = date.substring(0, 10);
  //we split the string starting at every '-'
  List<String> components = d.split('-');
  final year = components[0];
  var month = components[1];
  var day = components[2];
  //the name (in Italian) of the month is obtained from the corresponding number.
  switch (month) {
    case '01':
      month = 'Gennaio';
      break;
    case '02':
      month = 'Febbraio';
      break;
    case '03':
      month = 'Marzo';
      break;
    case '04':
      month = 'Aprile';
      break;
    case '05':
      month = 'Maggio';
      break;
    case '06':
      month = 'Giugno';
      break;
    case '07':
      month = 'Luglio';
      break;
    case '08':
      month = 'Agosto';
      break;
    case '09':
      month = 'Settembre';
      break;
    case '10':
      month = 'Ottobre';
      break;
    case '11':
      month = 'Novembre';
      break;
    case '12':
      month = 'Dicembre';
      break;
  }
  //the formatted date is in the form of day month, yeard (eg. 5 May, 2022)
  final formattedDate = '$day $month, $year';
  return formattedDate;
}

String formatTime(String date) {
  //Simply returns the other sub string. There is no need for ulterior operations
  return date.substring(10, 16);
}

String createCategoryNameFromString(String category) {
  //there are two special cases, since in italian, the words Comunità and Attività Artistica contain accents
  if (category == 'Comunita') {
    category = 'Comunità';
    return category;
  } else if (category == 'Attivita Artistica') {
    category = 'Attività Artistica';
    return category;
  }
  //if the word is not a special case, it is modified
  //the starting category String is in the form of f_categoryName (eg. f_puliziaCitta)
  category = category.substring(2); //the f_ part is removed
  final beforeCapitalLetter = RegExp(r"(?=[A-Z])");
  //the word is split at every capital letter
  final parts = category.split(beforeCapitalLetter);
  category = parts[0][0].toUpperCase() + parts[0].substring(1);
  //the first letter of the first word is now uppercase
  //in case there are multiple words, they are concatenate
  if (parts.length == 2) {
    category += ' ' + parts[1];
  } else if (parts.length == 3) {
    category += ' ' + parts[2];
  }

  return category;
}

int fromBoolToInt(bool? boolVar) {
  //to avoid problems with mysql and php (as reported by many users online)
  //it is better to change boolean values to integers, as in MySql every boolean is actually a tinyint(1)
  return boolVar == true ? 1 : 0;
}

bool fromStringToBool(String stringVar) {
  //of course, this means that, when we are reading data from a quert, the inverse operation has to be executed
  return stringVar == '1' ? true : false;
}

String phpDateFormat(DateTime date) {
  //a date format to which convert the date before sending it to the server
  final newDate = date.toString();
  return newDate.substring(0, 19);
}

// Future<Response> postRequest(
//     Client client, String file, Map<String, dynamic> body) {
//   return client.post(Uri.https('flutterfirsttry.000webhostapp.com', file),
//       headers: {"Content-Type": "application/json"}, body: json.encode(body));
// }
