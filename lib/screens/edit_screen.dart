import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

import '../services/storage.dart';
import '../services/users.dart';
import '../utils/utils.dart';
import '../widgets/choose_location.dart';
import '../widgets/choose_profile_picture.dart';
import '../widgets/custom_field.dart';
import '../utils/colors.dart';
import '../widgets/filters.dart';
import '../models/user.dart';
import '/screens/settings_screen.dart' show CustomTextButton;

//the EditScreen is accessed through the personal profile page
//it is used to modify the information the user provided when he created the account.
class EditScreen extends StatefulWidget {
  const EditScreen({Key? key}) : super(key: key);

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();

  late final User user;

  File? _image;
  String? _address;
  var initialFilters = <String, bool>{};
  var filtersLength = 0;
  var _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      user = Provider.of<Users>(context).currentUser;
      //while the Filters logic is equal to other parts of the app, in this case,
      //the initial filters are not all equal to false, as they have to reflect the actual initial filters of the user
      initialFilters = {
        'f_manuale': user.f_manuale,
        'f_intellettuale': user.f_intellettuale,
        'f_individuale': user.f_individuale,
        'f_collaborativo': user.f_collaborativo,
        'f_senzaTetto': user.f_senzaTetto,
        'f_ambiente': user.f_ambiente,
        'f_donne': user.f_donne,
        'f_bambini': user.f_bambini,
        'f_famiglie': user.f_famiglie,
        'f_immigrati': user.f_immigrati,
        'f_tossicoDipendenti': user.f_tossicoDipendenti,
        'f_mensaDeiPoveri': user.f_mensaDeiPoveri,
        'f_doposcuola': user.f_doposcuola,
        'f_consulenza': user.f_consulenza,
        'f_centroDiAscolto': user.f_centroDiAscolto,
        'f_anziani': user.f_anziani,
        'f_diversamenteAbili': user.f_diversamenteAbili,
        'f_comunita': user.f_comunita,
        'f_attivitaArtistica': user.f_attivitaArtistica,
        'f_recuperoCitta': user.f_recuperoCitta,
      };
      initialFilters.forEach((key, value) {
        if (value == true) {
          filtersLength++;
        }
      });
      //the same for the other variables. They are not null initially
      _address = user.location;
      _bioController.text = user.bio;
      _isInit = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _bioController.dispose(); //dispose the controller for the bio
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const Padding(
            padding: EdgeInsets.only(bottom: 13),
            child: Text(
              'Modifica profilo',
              style: TextStyle(
                  fontFamily: 'DarkerGrotesque',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
        ),
        //basically, this class makes use of most of the widgets already seen and explained in the UserInformatioScreen (when creating the account)
        //the logic is the same for all the widgets.
        body: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ChooseProfilePicture(_image, (image) {
                    _image = image;
                  }, NetworkImage(user.profilePictureUrl)),
                  CustomField(
                      textEditingController: _bioController,
                      type: FieldType.bio),
                  ChooseLocation(_address, (address) {
                    _address = address;
                  }),
                  const Padding(
                    padding: EdgeInsets.only(
                        left: 20, right: 20, bottom: 20, top: 10),
                    child: Text(
                      'Aggiorna le categorie a cui sei maggiormente interessato.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Ubuntu',
                          color: darkBlueColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10)
                        .copyWith(bottom: 10),
                    child: Filters(
                        addFilter: (chipName) {
                          initialFilters['f_$chipName'] =
                              !initialFilters['f_$chipName']!;
                          if (initialFilters['f_$chipName']!) {
                            filtersLength++;
                          } else {
                            filtersLength--;
                          }
                        },
                        userFilters: initialFilters),
                  ),
                  CustomTextButton(
                      action: () async {
                        //When the 'Save' button is clicked, it initially checks that the filters length is between 5 and ten.
                        if (filtersLength < 5 || filtersLength > 10) {
                          showCustomSnackbar(context,
                              'Inserisci un numero adeguato di categorie'); //'Select an adequate number of categories'
                          return;
                        }
                        var profilePictureUrl = user.profilePictureUrl;
                        //if the location is equal to null, it means that the user clicked on the ChooseLocation widget, but then did not pick a location.
                        //In this case, the location is set to the previous location selected by the user
                        var location =
                            _address != null ? _address : user.location;
                        final coordinates =
                            await locationFromAddress(_address!);
                        final latitude = coordinates[0].latitude;
                        final longitude = coordinates[0].longitude;
                        //a validation is performed
                        final bio = _bioController.text.length != 0
                            ? _bioController.text
                            : user.bio;
                        //if a different image was picked, than it has to delete the previous profile picture and upload the new one
                        if (_image != null) {
                          await Storage.deleteProfilePicture(
                              user.firebaseUserId);
                          profilePictureUrl =
                              await Storage.uploadProfilePicture(
                                  _image!, user.firebaseUserId);
                        }
                        //it updates the profile with all the new data
                        final res =
                            await Provider.of<Users>(context, listen: false)
                                .updateProfile(
                                    bio: bio,
                                    filters: initialFilters,
                                    location: location,
                                    latitude: latitude,
                                    longitude: longitude,
                                    profilePictureUrl: profilePictureUrl);
                        if (res != null) {
                          //it shows a snack bar explaining the result of the operation
                          showCustomSnackbar(context, res);
                        }
                      },
                      title: 'Salva modifiche',
                      icon: Icons.save,
                      color: electricBlueColor),
                  const SizedBox(
                    height: 100,
                  )
                ],
              ),
            )));
  }
}
