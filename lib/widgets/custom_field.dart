import 'package:flutter/material.dart';

import '../utils/colors.dart';

enum FieldType { email, password, username, bio }

class CustomField extends StatelessWidget {
  final TextEditingController textEditingController;
  final FieldType type;
  final Function(String)? onChanged;
  const CustomField(
      {Key? key,
      required this.textEditingController,
      required this.type,
      this.onChanged}) // the onchanged parameter is not required, as it is needed only in some occasions
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //all this variables are asigned depending on the FieldType.
    //In this way, instead of manually change them for every TextField, a simple and clear input is needed.
    final bool shouldObscure;
    final Function validation;
    final TextInputType keyboardType;
    final String label;
    final String hintText;
    final int maxLines;
    int? maxLength;
    switch (type) {
      case FieldType.email:
        shouldObscure = false;
        validation = emailValidation;
        keyboardType = TextInputType.emailAddress;
        label = 'Email';
        hintText = '';
        maxLines = 1;
        break;
      case FieldType.password:
        shouldObscure = true;
        validation = passwordValidation;
        keyboardType = TextInputType.text;
        label = 'Password';
        hintText = 'Almeno 6 caratteri e un numero';
        maxLines = 1;
        break;
      case FieldType.username:
        shouldObscure = false;
        validation = usernameValidation;
        keyboardType = TextInputType.text;
        label = 'Username';
        hintText = 'Questo nominativo sarà visualizzato dagli altri utenti';
        maxLines = 1;
        maxLength = 20;
        break;
      case FieldType.bio:
        shouldObscure = false;
        validation = bioValidation;
        keyboardType = TextInputType.multiline;
        label = 'Bio';
        hintText = 'Max 250 caratteri';
        maxLines = 8;
        maxLength = 250;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: TextFormField(
          controller: textEditingController,
          obscureText: shouldObscure,
          validator: (value) => validation(value),
          keyboardType: keyboardType,
          onChanged: onChanged ?? (value) {},
          minLines: 1,
          maxLength: maxLength,
          maxLines: maxLines,
          //always the same decoration, so to remain consistent
          decoration: fieldDecoration(label, hintText)),
    );
  }

  //if the email typed by the user does not respect the pattern of a typical email, the validation is not passed
  String? emailValidation(String? email) {
    if (RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email!)) {
      return null;
    } else {
      return 'Email non valida';
    }
  }

  //if the password typed by the user is not six characters long and does not contains a number , the validation is not passed
  String? passwordValidation(String? password) {
    if (password!.length >= 6 && password.contains(RegExp(r'[0123456789]'))) {
      return null;
    } else {
      return 'Password non valida';
    }
  }

  //the username has to be longer than two characters can not contains special charcters if not the following: ._-
  String? usernameValidation(String? username) {
    if (username == null ||
        username.runes.length <= 3 ||
        username.contains(' ') ||
        username
            .contains(RegExp(r'[\^$*\[\]{}()?\"!@#%&/\,><:;~`+=' "'" ']'))) {
      return 'Username non valido';
    }

    return null;
  }

  //bio has to be longer than four characters
  String? bioValidation(String? bio) {
    if (bio == null || bio.isEmpty) {
      return 'inserisci una bio';
    } else if (bio.runes.length <= 5) {
      return 'Bio troppo corta';
    }
    return null;
  }

  //this functions returns an homogenous decoration and avoids boiler plate code
  InputDecoration fieldDecoration(String label, String hint) {
    return InputDecoration(
      label: Text(
        label,
        style: TextStyle(
            color: electricBlueColor.withOpacity(0.8),
            letterSpacing: 2,
            fontWeight: FontWeight.w400),
      ),
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: electricBlueColor, width: 1.3),
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: electricBlueColor, width: 1.3),
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: electricBlueColor, width: 1.3),
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: electricBlueColor, width: 1.3),
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
    );
  }
}
