import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/authentication__service.dart';
import '../../utils/colors.dart';
import '../../widgets/electric_button.dart';

class VerifyScreen extends StatefulWidget {
  //final String password;
  const VerifyScreen({Key? key}) : super(key: key);

  @override
  _VerifyScreenState createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  var _isInit = true;
  User? user;
  Timer? timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      user = Provider.of<AuthenticationService>(context, listen: false).user;
      timer = Timer.periodic(const Duration(seconds: 4), (timer) {
        //every 4 seconds, we will check if the user has verified his email
        Provider.of<AuthenticationService>(context, listen: false)
            .checkEmailVerified();
      });
      _isInit = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer!.cancel();
  }

  Future<void> sendNewEmail() async {
    //in case the email was not automatically sent, the user clicks a button to send another email.
    if (!user!.emailVerified) {
      await user!.sendEmailVerification();
    }
  }

  @override
  Widget build(BuildContext context) {
    return VerifyUi(user!.email as String, sendNewEmail);
  }
}

class VerifyUi extends StatelessWidget {
  ///the whole UI for the page is managed in another widget. In this way we split logic and UI and have the oppportunity to use a stateless widget which will not rebuild.
  final VoidCallback _sendNewEmail;
  final String _email;

  // ignore: use_key_in_widget_constructors
  const VerifyUi(this._email, this._sendNewEmail);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        title: const Padding(
          padding: EdgeInsets.only(bottom: 13),
          child: Text(
            'Better than yesterday',
            style: TextStyle(
                fontFamily: 'DarkerGrotesque',
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Colors.black),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              '2 di 3',
              style: TextStyle(
                  fontFamily: 'Ubuntu', color: darkBlueColor, fontSize: 15),
            ),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/verify.jpg',
            height: MediaQuery.of(context).size.height * 0.45,
            width: double.infinity,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          const SizedBox(
            width: double.infinity,
            child: Text(
              "Abbiamo inviato una e-mail all'indirizzo",
              textAlign: TextAlign.center,
              overflow: TextOverflow.clip,
              style: TextStyle(
                  fontFamily: 'Ubuntu',
                  color: darkBlueColor,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w400),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              _email,
              style: const TextStyle(
                  fontFamily: 'Ubuntu',
                  color: electricBlueColor,
                  fontSize: 21,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 14.0),
            child: Text(
              'Controlla anche la cartella spam',
              style: TextStyle(
                  fontFamily: 'Ubuntu',
                  color: opaqueBlueColor,
                  fontSize: 15,
                  letterSpacing: 2),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.12),
          const Text(
            'Non hai ricevuto alcuna e-mail? Clicca sotto',
            style: TextStyle(fontFamily: 'Ubuntu', color: electricBlueColor),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: ElectricButton(
                buttonPressed: _sendNewEmail, title: 'Invia nuova e-mail'),
          )
        ],
      ),
    );
  }
}
