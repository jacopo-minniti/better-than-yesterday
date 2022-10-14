import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/colors.dart';
import '../../utils/decorations.dart';
import '../../utils/utils.dart';
import '../../widgets/electric_button.dart';
import '../../services/authentication__service.dart';

enum FieldType { email, password }

class AuthenticateUserScreen extends StatefulWidget {
  const AuthenticateUserScreen({Key? key}) : super(key: key);

  @override
  State<AuthenticateUserScreen> createState() => _AuthenticateUserScreenState();
}

class _AuthenticateUserScreenState extends State<AuthenticateUserScreen> {
  var _isSignin =
      true; //this variable controls whether the user wants to sign in or sign up.
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final GlobalKey _formKey;

  @override
  void initState() {
    //initState() is override so to istantiate the already declared variables. This approach is widely used and follows the convention.
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      //extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar:
          _isSignin //bool a ? Widget1 : Widget2  is equal to   if (bool a) {return Widget1;} else {return Widget2;}
              ? AppBar(
                  centerTitle: true,
                  backgroundColor: Colors.white,
                  elevation: 0.0,
                  title: const Text(
                    'Better Than Yesterday',
                    style: TextStyle(
                        letterSpacing: 2,
                        fontFamily: 'Ubuntu',
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                )
              : AppBar(
                  elevation: 0.0,
                  backgroundColor: Colors.white,
                  title: const Padding(
                    padding: EdgeInsets.only(bottom: 13),
                    child: Text(
                      'Better than yesterday',
                      style: TextStyle(
                          fontFamily: 'DarkerGrotesque',
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 27),
                    ),
                  ),
                  actions: const [
                    Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        '1 di 3',
                        style: TextStyle(
                            fontFamily: 'Ubuntu',
                            color: darkBlueColor,
                            fontSize: 15),
                      ),
                    )
                  ],
                ),
      body: SingleChildScrollView(
          child: Form(
        //defining a Form is a necessary step to then use TextFormFields
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _isSignin
                ? Image.asset(
                    'assets/images/no_background_logo.png',
                    height: height * 0.4,
                  )
                : Image.asset('assets/images/create_account_resized.png',
                    height: height * 0.47),
            CustomField(
                controller: _emailController,
                type: FieldType
                    .email), //to avoid boilder plate code, I've created a simple widget which returns a custom TextFormField
            CustomField(
                controller: _passwordController, type: FieldType.password),
            if (_isSignin)
              TextButton(
                  onPressed:
                      _forgotPassword, //in case the user has forgotten the password for the account
                  child: const Text(
                    'Password dimenticata?',
                    style: TextStyle(
                        fontFamily: 'Ubuntu',
                        color: electricBlueColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w400),
                  )),
            SizedBox(height: height * 0.027),
            _isSignin
                ? ElectricButton(
                    buttonPressed: () async {
                      try {
                        await Provider.of<AuthenticationService>(context,
                                listen: false)
                            .signIn(_emailController.text,
                                _passwordController.text);
                      } on FirebaseAuthException catch (e) {
                        var res = '';
                        switch (e.code) {
                          //the strings next to the case keyword are the codes used by firebase to identify the different exception
                          case 'invalid-email':
                            res = 'Email non valida';
                            break;
                          case 'user-disabled':
                            res = 'Utente disabilitato';
                            break;
                          case 'user-not-found':
                            res = "Utente non trovato. Controlla l'email";
                            break;
                          case 'wrong-password':
                            res = 'Password errata. Riprova.';
                            break;
                        }
                        showCustomSnackbar(context, res);
                      }
                    },
                    title: 'Accedi')
                : ElectricButton(
                    buttonPressed: () async {
                      try {
                        await Provider.of<AuthenticationService>(context,
                                listen: false)
                            .signUp(_emailController.text,
                                _passwordController.text);
                        await Provider.of<AuthenticationService>(context,
                                listen: false)
                            .reauthenticate();
                      } catch (err) {
                        showCustomSnackbar(
                            context, 'Errore. Riprova più tardi');
                      }
                    },
                    title: 'Continua'),
            SizedBox(
              height: height * 0.060,
            ),
            TextButton(
                //by clicking on this TextButton, _signIn is changes and thus the screen passes from Signin to Signup or viceversa
                onPressed: () {
                  setState(() {
                    //without the setState(() {}) the state of the Widget would not change
                    _isSignin = !_isSignin;
                  });
                },
                child: Text(
                  _isSignin
                      ? 'Non hai un account? Registrati ora!'
                      : 'Hai già un account? Accedi subito!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Ubuntu',
                      color: Colors.black87,
                      fontSize: 17,
                      fontWeight: FontWeight.w300),
                ))
          ],
        ),
      )),
    );
  }

  Future<void> _forgotPassword() async {
    final emailForgotController = TextEditingController();
    return showDialog(
        context: context,
        builder: ((context) => AlertDialog(
              title: const Text('Reset password'),
              content: TextField(
                controller: emailForgotController,
                decoration: fieldDecoration('email', ''),
              ),
              actions: [
                TextButton(
                    onPressed: () async {
                      var res =
                          "Email inviata all'indirizzo ${emailForgotController.text}";
                      try {
                        await Provider.of<AuthenticationService>(context,
                                listen: false)
                            .passwordForgotten(emailForgotController
                                .text); //this method, provided by the AuthenticationService, send an email for changing password to the email passed as parameter.
                      } catch (err) {
                        res = 'Errore. Riprova in seguito';
                      }
                      Navigator.of(context).pop();
                      showCustomSnackbar(context, res);
                    },
                    child: const Text('Invia email')),
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annulla'))
              ],
            )));
  }
}

class CustomField extends StatelessWidget {
  //a simple TextFormField with some decoration and settings. To avoid unnecessary rebuilds, it is better to use widgets than methods with return type Widget
  final FieldType type;
  final TextEditingController controller;
  const CustomField({Key? key, required this.type, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isEmail = type == FieldType.email ? true : false;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: TextFormField(
          controller: controller,
          obscureText: isEmail ? false : true,
          validator: (value) {
            if (isEmail) {
              return emailValidation(value);
            } else {
              return passwordValidation(value);
            }
          },
          keyboardType:
              isEmail ? TextInputType.emailAddress : TextInputType.text,
          decoration: fieldDecoration(isEmail ? 'Email' : 'Password',
              isEmail ? '' : 'Almeno 6 caratteri ed un numero')),
    );
  }

  String? emailValidation(String? email) {
    //email validation to avoid obliviously fake email
    if (RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email!)) {
      return null;
    } else {
      return 'Email non valida';
    }
  }

  String? passwordValidation(String? password) {
    //password validation. It must contains a number and be >=6. Either way it would be too weak, and thus insecure.
    if (password!.length >= 6 && password.contains(RegExp(r'[0123456789]'))) {
      return null;
    } else {
      return 'Password non valida';
    }
  }
}
