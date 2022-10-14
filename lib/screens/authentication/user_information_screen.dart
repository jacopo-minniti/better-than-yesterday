import 'dart:convert';
import 'dart:io';

import 'package:better_than_yesterday/screens/pages_controller.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../services/comments.dart';
import '../../services/posts.dart';
import '../../services/users.dart';
import '../../widgets/choose_location.dart';
import '../../widgets/choose_profile_picture.dart';
import '../../widgets/custom_field.dart';
import '../../services/storage.dart';
import '../../utils/colors.dart';
import '../../utils/utils.dart';
import '../../widgets/electric_button.dart';
import '../../widgets/filters.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({Key? key}) : super(key: key);
  static const routeName = '/user-information';

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  //first, we declare all the variables we are going to use
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;

  File? _image;

  var _isLoading =
      false; //_isLoading turns to true when the button to create the account is clicked
  var _isUsed = false;

  final _user = FirebaseAuth.instance.currentUser;

  String? _location;
  var filters = <String, bool>{
    'f_manuale': false,
    'f_intellettuale': false,
    'f_individuale': false,
    'f_collaborativo': false,
    'f_senzaTetto': false,
    'f_ambiente': false,
    'f_donne': false,
    'f_bambini': false,
    'f_famiglie': false,
    'f_immigrati': false,
    'f_tossicoDipendenti': false,
    'f_mensaDeiPoveri': false,
    'f_doposcuola': false,
    'f_consulenza': false,
    'f_centroDiAscolto': false,
    'f_anziani': false,
    'f_diversamenteAbili': false,
    'f_comunita': false,
    'f_attivitaArtistica': false,
    'f_recuperoCitta': false,
  };
  var filtersLength = 0;

  @override
  void initState() {
    //istantiate the objectts
    super.initState();
    _usernameController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    //dispose the controller is fundamental
    super.dispose();
    _usernameController.dispose();
    _bioController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
        //thanks to the animated opacity widget, a simple way to change opacity after an event starts is made available. We do not need to manage the animation as everything is done behind the scene by flutter
        duration: const Duration(seconds: 1),
        opacity: _isLoading ? 0.5 : 1,
        curve: Curves.decelerate,
        child: Scaffold(
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
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
            actions: const [
              Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  '3 di 3',
                  style: TextStyle(
                      fontFamily: 'Ubuntu', color: darkBlueColor, fontSize: 15),
                ),
              )
            ],
          ),
          body: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ChooseProfilePicture(
                        _image,
                        (image) => _image =
                            image, //widget used to manage all the logic and UI of choosing the profile picture for the user. It is written in a sparate class as it will be used other times.
                        const AssetImage('assets/images/user.png')),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.06,
                    ),
                    CustomField(
                      //CustomField is a class which returns the text field with all the due decoration and functionalities, by simply accepting as parameter a type.
                      textEditingController: _usernameController,
                      type: FieldType.username,
                      onChanged: (username) async {
                        if (isUsernameValid(_usernameController.text)) {
                          //returns true if the username is valid
                          final us = await isUsernameUsed(
                              username); //returns true if the username is alredy used
                          setState(() {
                            _isUsed = us;
                          });
                        }
                      },
                    ),
                    if (isUsernameValid(_usernameController
                        .text)) //if can be used inside a Colummn widget without the curly brackets. If the condition is true the widget below is shown.
                      _isUsed
                          ? Text(
                              '${_usernameController.text} è già in uso',
                              style: const TextStyle(
                                fontFamily: 'Ubuntu',
                                color: Colors.red,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.done,
                                  color: Colors.green,
                                ),
                                Text('Username disponibile',
                                    style: TextStyle(
                                        fontFamily: 'Ubuntu',
                                        color: Colors.green))
                              ],
                            ),
                    CustomField(
                        textEditingController: _bioController,
                        type: FieldType.bio),
                    ChooseLocation(
                        //ChooseLocation manages all the logic for choosing the location. It is used both for users, and later for posts.
                        _location,
                        (address) => _location = address),
                    const Padding(
                      padding: EdgeInsets.only(
                          left: 20, right: 20, bottom: 20, top: 10),
                      child: Text(
                        'Seleziona le categorie che ti interessano maggiormente. \n Scegli dalle 5 alle 10 categorie.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Ubuntu',
                            color: darkBlueColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Filters(
                          //Filters manages all the logic for choosing the the filters. See filters.dart to better understand how it works.
                          addFilter: (chipName) {
                            //this callback is used to make the element of the map filters defined above change.
                            //This callback is called every time the container is clicked. chipName gives information on which element of the Grid was clicked
                            filters['f_$chipName'] = !filters['f_$chipName']!;
                            //if the element is true, it means that the user added a filters, and so the number of filters increase. Otherwise decrease.
                            if (filters['f_$chipName']!) {
                              filtersLength++;
                            } else {
                              filtersLength--;
                            }
                          },
                          userFilters: filters),
                    ),
                    const SizedBox(
                      height: 100,
                    )
                  ],
                ),
              )),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: ElectricButton(
              //when this button is pressed, it first check if all data was inserted
              buttonPressed: () async {
                if (!_formKey.currentState!.validate()) {
                  return;
                }
                if (_image == null) {
                  showCustomSnackbar(
                      context, "Seleziona un'immagine di profilo prima");
                  return;
                }
                if (_location == null) {
                  showCustomSnackbar(context, "Seleziona una località prima");
                  return;
                }
                if (filtersLength < 5 || filtersLength > 10) {
                  showCustomSnackbar(
                      context, "Seleziona un numero adeguato di categorie");
                  return;
                }
                if (_isUsed) {
                  return;
                }
                try {
                  //if all the data was inserted correctly and the username is not already in use, _isLoading is set to true, opacity decreases and the actual logic for creating the user profile starts
                  setState(() {
                    _isLoading = true;
                  });
                  final profilePictureUrl = await Storage.uploadProfilePicture(
                      _image!,
                      _user!
                          .uid); //this method uploads the images on Firebase Storage and returns a list with the corrispondive links.
                  final address = await locationFromAddress(
                      _location!); //the geocoding package makes available this static function to find the coordinates from the location
                  final latitude = address[0].latitude;
                  final longitude = address[0].longitude;
                  final username = _usernameController.text;
                  final newUser = {
                    //this map is what is actually passed to the server
                    'firebaseUserId': _user!.uid,
                    'username': username,
                    'profilePictureUrl': profilePictureUrl,
                    'location': _location!,
                    'longitude': longitude,
                    'latitude': latitude,
                    'bio': _bioController.text,
                    'isVerified': 0,
                    'f_manuale': fromBoolToInt(filters[
                        'f_manuale']), //MySql, in particular with php, seems to give problems in some occasions with the boolean type. Since in MySql a boolean is just a tinyint(1), has more sense to pass directly the int value
                    'f_intellettuale':
                        fromBoolToInt(filters['f_intellettuale']),
                    'f_individuale': fromBoolToInt(filters['f_individuale']),
                    'f_collaborativo':
                        fromBoolToInt(filters['f_collaborativo']),
                    'f_senzaTetto': fromBoolToInt(filters['f_senzaTetto']),
                    'f_ambiente': fromBoolToInt(filters['f_ambiente']),
                    'f_donne': fromBoolToInt(filters['f_donne']),
                    'f_bambini': fromBoolToInt(filters['f_bambini']),
                    'f_famiglie': fromBoolToInt(filters['f_famiglie']),
                    'f_immigrati': fromBoolToInt(filters['f_immigrati']),
                    'f_tossicoDipendenti':
                        fromBoolToInt(filters['f_tossicoDipendenti']),
                    'f_mensaDeiPoveri':
                        fromBoolToInt(filters['f_mensaDeiPoveri']),
                    'f_doposcuola': fromBoolToInt(filters['f_doposcuola']),
                    'f_consulenza': fromBoolToInt(filters['f_consulenza']),
                    'f_centroDiAscolto':
                        fromBoolToInt(filters['f_centroDiAscolto']),
                    'f_anziani': fromBoolToInt(filters['f_anziani']),
                    'f_diversamenteAbili':
                        fromBoolToInt(filters['f_diversamenteAbili']),
                    'f_comunita': fromBoolToInt(filters['f_comunita']),
                    'f_attivitaArtistica':
                        fromBoolToInt(filters['f_attivitaArtistica']),
                    'f_recuperoCitta':
                        fromBoolToInt(filters['f_recuperoCitta']),
                  };
                  var client = http.Client(); //start a new connection
                  try {
                    //createUserProfile.php is a php file responsable to recieve data and create a new row in the users_profile table.
                    var response = await client.post(
                        Uri.https('flutterfirsttry.000webhostapp.com',
                            'createUserProfile.php'),
                        headers: {"Content-Type": "application/json"},
                        body: json.encode(
                            newUser)); //the body must encoded into a json file before
                    if (json.decode(response.body) != 1) {
                      //if the output is different from 1, it means an error server side occured.
                      showCustomSnackbar(context, "Si è verificato un'errore");
                      return;
                    }
                  } finally {
                    client.close(); //close the connection in every case
                  } //if everythingg worked fine, the user can finally access PagesController() and use the actual social network.
                  // Providers definition is the same as when PagesController() is accessed through AuthenticationStream()
                  final posts = Posts();
                  final users = Users();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider(create: (context) => posts),
                          ChangeNotifierProvider(create: (context) => users),
                          ChangeNotifierProvider(
                              create: (context) => Comments()),
                        ],
                        child: PagesController(
                          posts: posts,
                          users: users,
                        )),
                  ));
                } catch (err) {
                  showCustomSnackbar(
                      context, "Non è stato possibile creare l'utente");
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              title: 'Completa'),
        ));
  }

  bool isUsernameValid(String text) {
    if (_usernameController.text != '' &&
        _usernameController.text.runes.length > 3 &&
        _usernameController.text.runes.length < 21 &&
        !_usernameController.text
            .contains(RegExp(r'[\^$*\[\]{}()?\"!@#%&/\,><:;~`+=' "'" ']')) &&
        !_usernameController.text.contains(' ')) {
      return true;
    }
    return false;
  }

  Future<bool> isUsernameUsed(String username) async {
    final url =
        Uri.https('flutterfirsttry.000webhostapp.com', 'isUsernameUsed.php');
    final response =
        await http.post(url, body: json.encode({'username': username}));
    final isUsernameUsed = json.decode(response.body);
    return isUsernameUsed == 1 ? true : false;
  }
}
