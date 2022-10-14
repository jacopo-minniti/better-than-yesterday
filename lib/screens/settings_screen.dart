import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:provider/provider.dart';

import '../services/authentication__service.dart';
import '../services/storage.dart';
import '../services/users.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';

//the SettingsScreen is accessed through the Home page.
class SettingsScreen extends StatelessWidget {
  final String email;
  final int userId;
  final bool isVerified;
  const SettingsScreen(
      {Key? key,
      required this.isVerified,
      required this.email,
      required this.userId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.0,
            leading: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                ),
              ),
            ),
            centerTitle: true,
            title: const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text(
                'Impostazioni',
                style: TextStyle(
                    fontFamily: 'DarkerGrotesque',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 2),
              ),
            )),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          child: Column(
            children: [
              const Text(
                  "Nel caso tu sia un'associazione, cooperativa, organizzazione o personalità con un seguito pubblico, puoi provare a richiedere il verificato. In questo modo si evita ogni tentativo di furto d'identità",
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 2)),
              //This TextButton, when clicked, requests the 'verified' by sending an email.
              CustomTextButton(
                title: 'Richiedi verificato',
                color: electricBlueColor,
                icon: Icons.verified_user,
                action: () => showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) {
                      final controller = TextEditingController();
                      return AlertDialog(
                        scrollable: true,
                        title: const Text(
                            'Invia una breve descrizione su di te e le tue attività su questa piattaforma',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Ubuntu',
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                        actionsAlignment: MainAxisAlignment.spaceAround,
                        content: SingleChildScrollView(
                          //the email has to contain the name of the organization, what it does and why it is on this platform
                          child: Column(
                            children: [
                              const Text(
                                  'es. Il nome della mia organizzazione è xxx, ci occupiamo di xxx e siamo su questa piattaforma perchè xxx',
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                      fontFamily: 'Ubuntu',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black54)),
                              const SizedBox(
                                height: 25,
                              ),
                              SingleChildScrollView(
                                child: TextField(
                                  controller: controller,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 10),
                                      label: const Text(
                                        'Descrizione',
                                        style:
                                            TextStyle(color: electricBlueColor),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          borderSide: const BorderSide(
                                              color: electricBlueColor,
                                              width: 0.8)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          borderSide: const BorderSide(
                                              color: electricBlueColor,
                                              width: 0.8)),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          borderSide: const BorderSide(
                                              color: electricBlueColor,
                                              width: 0.8))),
                                  keyboardType: TextInputType.multiline,
                                  minLines: 1,
                                  maxLines: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: Text('Annulla',
                                  style: TextStyle(
                                      color:
                                          electricBlueColor.withAlpha(170)))),
                          TextButton(
                              //if the user is already verified, the button does nothing
                              onPressed: isVerified
                                  ? null
                                  : () async {
                                      //to send the email is used the flutterEmailSender package
                                      final emailToSend = Email(
                                        body: controller.text,
                                        subject: 'Richiesta Verificato',
                                        recipients: [
                                          'app.betterthanyesterday@gmail.com'
                                        ],
                                        isHTML: false,
                                      );

                                      await FlutterEmailSender.send(
                                          emailToSend);
                                      Navigator.of(ctx).pop();
                                    },
                              child: Text(
                                'Invia',
                                style: TextStyle(
                                    color: electricBlueColor.withAlpha(170)),
                              )),
                        ],
                      );
                    }),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 13),
                child: Divider(
                  thickness: 1,
                  color: Colors.black26,
                ),
              ),
              //this button is used to permantly delete the account.
              CustomTextButton(
                  action: () => showDialog(
                      context: context,
                      builder: (ctx) {
                        final controller = TextEditingController();
                        return AlertDialog(
                          title: const Text(
                              "Sicuro di volere eliminare l'account? L'operazione è irreversibile.",
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                  fontFamily: 'Ubuntu',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500)),
                          //the user is asked to insert his password.
                          content: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 10),
                                label: const Text(
                                  'Password',
                                  style: TextStyle(color: electricBlueColor),
                                ),
                                hintText: 'Inserisci password',
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(
                                        color: electricBlueColor, width: 0.8)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(
                                        color: electricBlueColor, width: 0.8)),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(
                                        color: electricBlueColor, width: 0.8))),
                            keyboardType: TextInputType.text,
                            obscureText: true,
                          ),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: Text('Annulla',
                                    style: TextStyle(
                                        color:
                                            electricBlueColor.withAlpha(170)))),
                            TextButton(
                                //first, the password inserted and email are used to reauthenticate the user.
                                onPressed: () async {
                                  try {
                                    final profilePictureUrl =
                                        Provider.of<Users>(context,
                                                listen: false)
                                            .profilePictureUrl;
                                    Navigator.of(ctx).pop();
                                    print('start');
                                    await Provider.of<AuthenticationService>(
                                            context,
                                            listen: false)
                                        .reauthenticateWithCredentials(
                                            email, controller.text);
                                    // after reauthentication, the account on the Firebase Authentication Service is deleted.
                                    // if the user is authenticated correctly, it calls deleteAccount.
                                    // This deletes the user profile from the database.
                                    // While the method just delete the record from the users_profile table, all the other tables are connected to the userId through foreign keys.
                                    // Therefore, all the posts, photos, interactions, follow relations adre deleted as well.
                                    // this method returns the URLs of the images of every post by the user too.
                                    final photos = await Provider.of<Users>(
                                            context,
                                            listen: false)
                                        .deleteAccount();
                                    // Storage.deleteAccount delete all the images stored in the posts_photos table, and the profile picture
                                    await Storage.deleteAccount(
                                        photos, profilePictureUrl);
                                  } catch (err) {
                                    showCustomSnackbar(
                                        context, 'Errore. Riprova più tardi');
                                  }
                                },
                                child: Text('Elimina',
                                    style: TextStyle(
                                        color:
                                            electricBlueColor.withAlpha(170))))
                          ],
                        );
                      }),
                  title: 'Elimina account',
                  icon: Icons.person_remove,
                  color: Colors.red),
              const SizedBox(
                height: 80,
              )
            ],
          ),
        )));
  }
}

// A custom TextButton
class CustomTextButton extends StatelessWidget {
  final VoidCallback action;
  final String title;
  final IconData icon;
  final Color color;
  // ignore: use_key_in_widget_constructors
  const CustomTextButton(
      {required this.action,
      required this.title,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: action,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.white),
        elevation: MaterialStateProperty.all(0),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 7),
              child: Icon(
                icon,
                color: color,
              ),
            ),
            Text(title,
                style: TextStyle(
                    fontFamily: 'Ubuntu',
                    letterSpacing: 2,
                    fontSize: 14,
                    color: color)),
          ],
        ),
      ),
    );
  }
}
