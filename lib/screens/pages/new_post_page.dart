import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

import '../../services/posts.dart';
import '../../services/storage.dart';
import '../../services/users.dart';
import '../../utils/colors.dart';
import '../../utils/utils.dart';
import '../../widgets/filters.dart';
import '../choose_location_screen.dart';

//the enum is used to distinguish between the different TextFields.
enum FieldType { requirements, description, title, partecipants }

//this screen premits the creation of a new post
class NewPostPage extends StatefulWidget {
  const NewPostPage({Key? key}) : super(key: key);

  @override
  State<NewPostPage> createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  //_restart is set to true when the post was created successfully.
  //it triggres all the widgets in the class to empty and refresh
  var _restart = false;
  //_isLoading is set to true when the 'create post' button is clicked
  var _isLoading = false;

  //These variables contain the data necessary to the creation of a post.
  //They follow the samme pattern: they are initially null. When 'create post' button is clicked,
  //if even one of them is still null, then it shows a snack bar indicating
  // to the user the problem (eg. Before creating the post, insert a thumbnail)
  File? _thumbnail;
  String? _address;
  DateTime? _datePicked;
  TimeOfDay? _timePicked;
  String? requirements;
  List<File?> _photos = [];
  final _isRequirements = false;
  final _isMaximum = false;
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

  //the controllers for all the different text fields are declared and initialized

  late final _descriptionController;
  late final _requirementsController;
  late final _titleController;
  late final _partecipantsController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _requirementsController = TextEditingController();
    _titleController = TextEditingController();
    _partecipantsController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      //thanks to the AnimatedOpacity widget, when the 'create post' button is clicked,
      //the opacity decrements until the creation of the post is completed and it is inserted into the database
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: _isLoading ? 0.3 : 1,
        child: Scaffold(
          backgroundColor: Colors.white,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: FloatingActionButton(
              //when the FloatingActionButton is clicked all the data is empty.
              //If the user for example wants to change the post to publish, he can easply do so by clicking this button
              onPressed: () {
                _descriptionController.text = '';
                _requirementsController.text = '';
                _titleController.text = '';
                _thumbnail = null;
                _address = null;
                _datePicked = null;
                _timePicked = null;
                requirements = null;
                _photos = [];
                setState(() {
                  _restart = true;
                });
              },
              backgroundColor: electricBlueColor,
              child: const Icon(
                Icons.restart_alt_rounded,
                color: Colors.white,
              )),
          appBar: AppBar(
              elevation: 0.0,
              backgroundColor: electricBlueColor,
              centerTitle: true,
              //the 'create post' button is positioned at the top of the screen, and so it takes the place of the title in the app bar.
              title: ElevatedButton(
                onPressed: () async {
                  //in the submit method it is grouped all the logic for the creation of the post
                  await _submit();
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(electricBlueColor),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                    ),
                    alignment: Alignment.center,
                    minimumSize: MaterialStateProperty.all(Size(double.infinity,
                        MediaQuery.of(context).size.height * 0.1))),
                child: const Text(
                  'Crea Post',
                  style: TextStyle(
                      fontFamily: 'Ubuntu',
                      letterSpacing: 2.2,
                      fontWeight: FontWeight.w600,
                      fontSize: 20),
                ),
              )),
          body: SingleChildScrollView(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Thumbnail(
                callback: (thumbnail) => _thumbnail = thumbnail,
                restart: _restart,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 15, bottom: 20),
                child: Text(
                  "L'immagine sopra mostrata sarà visualizzata con diverse proporzioni dall'utente",
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                  textAlign: TextAlign.start,
                ),
              ),
              //the Place, Date, and Time widgets are used as 'pickers'.
              //they all have the same logic behind. the callback is used to set the local variable (declared above) to the variable of the Widget.
              //they accept _restart as a parameter, so that when they are rebuilt (setState is called) they now if they have to empty themeselves
              Place(
                callback: (place) => _address = place,
                restart: _restart,
              ),
              Date(
                callback: (date) => _datePicked = date,
                restart: _restart,
              ),
              Time(
                callback: (time) => _timePicked = time,
                restart: _restart,
              ),
              //A custom field which accepts a controller (instantiated in the initState) and the fieldType
              NewPostField(
                  controller: _titleController, fieldType: FieldType.title),
              NewPostField(
                  controller: _descriptionController,
                  fieldType: FieldType.description),
              Text('Requisiti per partecipare',
                  style: TextStyle(
                      fontFamily: 'Ubuntu',
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight:
                          _isRequirements ? FontWeight.bold : FontWeight.w400)),
              //Requirements is a switch. When on, it shows the text field to type all the requirements.
              //This is done as requirements is not mandatory for the creation of the post
              Requirements(
                  controller: _requirementsController, restart: _restart),
              Text('Numero massimo di partecipanti',
                  style: TextStyle(
                      fontFamily: 'Ubuntu',
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight:
                          _isMaximum ? FontWeight.bold : FontWeight.w400)),
              //MaximumPartecipants works in the same way of Requirements, but for the maximum number of partecipants
              MaximumPartecipants(
                  controller: _partecipantsController, restart: _restart),
              //Photos is a horizontally scrollable list.
              //Every time an image is inserted, it adds, to its right, a new button to add another image
              Photos(
                callback: (image) {
                  _photos.add(image);
                },
                restart: _restart,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 50),
                child: Text(
                  'Seleziona fino a 3 categorie',
                  style: TextStyle(
                      fontFamily: 'Ubuntu',
                      color: Colors.black87,
                      fontSize: 20),
                ),
              ),
              //the Filters widget is the same, and thus works in the same way, as in user creation.
              //However here, the maximum number of filters is 3.
              Padding(
                padding: const EdgeInsets.only(
                    top: 18, bottom: 80, left: 20, right: 20),
                child: Filters(
                    addFilter: (chipName) {
                      filters['f_$chipName'] = !filters['f_$chipName']!;
                      if (filters['f_$chipName']!) {
                        filtersLength++;
                      } else {
                        filtersLength--;
                      }
                    },
                    userFilters: filters),
              ),
            ],
          )),
        ),
      ),
    );
  }

  //the _validate method return false and shows a snack bar with the problem, in case one of the necessary information was not inserted.
  //Otherwise it returns true
  bool _validate() {
    var res = '';

    if (filtersLength == 0 || filtersLength > 3) {
      res = 'Seleziona un numero adeguato di categorie';
    }
    if (_photos.isEmpty) {
      res = 'Inserisci almeno una foto';
    }
    if (_descriptionController.text.length < 100) {
      res = 'Inserisci una descrizione di almeno 100 caratteri';
    }
    if (_titleController.text.length > 50) {
      res = 'Inserisci un titolo di massimo 50 caratteri';
    }
    if (_timePicked == null) {
      res = "Seleziona un'orario";
    }
    if (_datePicked == null) {
      res = 'Seleziona una data';
    }
    if (_address == null) {
      res = 'Seleziona un luogo';
    }
    if (_thumbnail == null) {
      res = "Inserisci un'immagine di copertina";
    }

    if (res != '') {
      showCustomSnackbar(context, res);
      return false;
    }
    return true;
  }

  //the _submit method is where all the logic is managed
  Future<void> _submit() async {
    //it calls _validate. Only if true, it continues
    if (!_validate()) {
      return;
    }
    //opacity is lowered, the actual work for publishing the post starts now
    setState(() {
      _isLoading = true;
    });
    var res = 'Post creato con successo!';
    //_photos, until now, included all the additional images. Now we add also the thumbnail in position 0.
    _photos.insert(0, _thumbnail);
    final firebaseUserId =
        Provider.of<Users>(context, listen: false).firebaseUserId;
    //in this way, is far simpler to use Storage.uploadPostImages,
    //as the list passed contains all the images to upload
    final imagesUrl =
        await Storage.uploadPostImages(photos: _photos, userId: firebaseUserId);
    //imagesUrl contains the URLs of all the images. At index 0, the image URL contained is for the thumbnail
    final thumbnail = imagesUrl[0];
    //now that the thumbnail is saved into a variable, it can be removed from imagesUrl.
    //This list will be used to upload the additional images in the posts_photos table in the database
    imagesUrl.removeAt(0);
    //the postDate simply uses the constructor of DateTime to union the date and time picked into a single variable.
    final postDate = DateTime(_datePicked!.year, _datePicked!.month,
        _datePicked!.day, _timePicked!.hour, _timePicked!.minute);

    //the coordinates are obtained through the location picked
    final locationAddress = await locationFromAddress(_address!);
    final latitude = locationAddress[0].latitude;
    final longitude = locationAddress[0].longitude;
    final location = _address!;
    //if maxPartecipants is not specified, 1000 is the defaul value
    var maxPartecipants = 1000;
    if (_partecipantsController.text != '') {
      maxPartecipants = int.parse(_partecipantsController.text);
    }
    //if requirements is not specified, "No requirements required" is the defaul value
    var requirements = _requirementsController.text;
    if (requirements == '') {
      requirements = 'Nessun requisito richiesto';
    }
    //the map which contains all the data for the creation of a new post is
    //passed to the method createPost of the Posts provider
    final newPost = {
      'title': _titleController.text,
      'userId': Provider.of<Users>(context, listen: false).userId,
      'thumbnail': thumbnail,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'description': _descriptionController.text,
      'requirements': requirements,
      'maxPartecipants': maxPartecipants,
      'photos': imagesUrl,
      'postDate': phpDateFormat(postDate),
      'f_manuale': fromBoolToInt(filters['f_manuale']),
      'f_intellettuale': fromBoolToInt(filters['f_intellettuale']),
      'f_individuale': fromBoolToInt(filters['f_individuale']),
      'f_collaborativo': fromBoolToInt(filters['f_collaborativo']),
      'f_senzaTetto': fromBoolToInt(filters['f_senzaTetto']),
      'f_ambiente': fromBoolToInt(filters['f_ambiente']),
      'f_donne': fromBoolToInt(filters['f_donne']),
      'f_bambini': fromBoolToInt(filters['f_bambini']),
      'f_famiglie': fromBoolToInt(filters['f_famiglie']),
      'f_immigrati': fromBoolToInt(filters['f_immigrati']),
      'f_tossicoDipendenti': fromBoolToInt(filters['f_tossicoDipendenti']),
      'f_mensaDeiPoveri': fromBoolToInt(filters['f_mensaDeiPoveri']),
      'f_doposcuola': fromBoolToInt(filters['f_doposcuola']),
      'f_consulenza': fromBoolToInt(filters['f_consulenza']),
      'f_centroDiAscolto': fromBoolToInt(filters['f_centroDiAscolto']),
      'f_anziani': fromBoolToInt(filters['f_anziani']),
      'f_diversamenteAbili': fromBoolToInt(filters['f_diversamenteAbili']),
      'f_comunita': fromBoolToInt(filters['f_comunita']),
      'f_attivitaArtistica': fromBoolToInt(filters['f_attivitaArtistica']),
      'f_recuperoCitta': fromBoolToInt(filters['f_recuperoCitta']),
    };

    try {
      //if there is an exception of any kind, res = 'Error in the creation of the post'
      final success =
          await Provider.of<Posts>(context, listen: false).createPost(newPost);
      if (!success) {
        res = 'Erorre nella creazione del post';
      }
    } catch (err) {
      res = 'Erorre nella creazione del post';
    } finally {
      //either way,, exception or not, all the information is reset and empty
      _descriptionController.text = '';
      _requirementsController.text = '';
      _titleController.text = '';
      _thumbnail = null;
      _address = null;
      _datePicked = null;
      _timePicked = null;
      _requirementsController.text = '';
      _photos = [];
      filters.updateAll(
        (key, value) => value = false,
      );
      setState(() {
        _restart = true;
        _isLoading = false;
      });
      //res is displayed in the custom snack bar
      showCustomSnackbar(context, res);
    }
  }
}

//it uses a switch button. If the switch is on,
//it shows a text field to input the max number of participants
class MaximumPartecipants extends StatefulWidget {
  final TextEditingController controller;
  bool restart;
  MaximumPartecipants(
      {Key? key, required this.controller, required this.restart})
      : super(key: key);

  @override
  State<MaximumPartecipants> createState() => _MaximumPartecipantsState();
}

class _MaximumPartecipantsState extends State<MaximumPartecipants> {
  var _isMaximum = false;
  @override
  Widget build(BuildContext context) {
    //if restart is true, the switch is turned off. This happens after the post was created
    if (widget.restart) {
      _isMaximum = false;
      widget.restart = false;
    }
    return Column(
      children: [
        Switch(
            value: _isMaximum,
            activeColor: electricBlueColor,
            onChanged: (value) => setState(() => _isMaximum = value)),
        if (_isMaximum)
          //the Text Field for the participants
          NewPostField(
              controller: widget.controller, fieldType: FieldType.partecipants),
      ],
    );
  }
}

//Requirements works in the same exact way to the previous widget.
//Here the text field is used to insert the requirements to participate
class Requirements extends StatefulWidget {
  final TextEditingController controller;
  bool restart;
  Requirements({Key? key, required this.controller, required this.restart})
      : super(key: key);

  @override
  State<Requirements> createState() => _RequirementsState();
}

class _RequirementsState extends State<Requirements> {
  var _isRequirements = false;
  @override
  Widget build(BuildContext context) {
    if (widget.restart) {
      _isRequirements = false;
      widget.restart = false;
    }
    return Column(
      children: [
        Switch(
            value: _isRequirements,
            activeColor: electricBlueColor,
            onChanged: (value) => setState(() => _isRequirements = value)),
        if (_isRequirements)
          NewPostField(
              controller: widget.controller, fieldType: FieldType.requirements),
      ],
    );
  }
}

//A custom TextField. it accepts a controller (it uses one of the four instantiated in the initState of NewPostPage)
class NewPostField extends StatelessWidget {
  final TextEditingController controller;
  final FieldType fieldType;
  const NewPostField(
      {Key? key, required this.controller, required this.fieldType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextInputType keyboardType;
    final EdgeInsets padding;
    //the various properties of the text field are chosen based on the value of the enum FieldType
    int? maxLength;
    switch (fieldType) {
      case FieldType.requirements:
        padding =
            const EdgeInsets.only(left: 20, right: 20, top: 6, bottom: 20);
        keyboardType = TextInputType.text;
        maxLength = 1000;
        break;
      case FieldType.description:
        padding =
            const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 30);
        keyboardType = TextInputType.multiline;
        break;
      case FieldType.title:
        keyboardType = TextInputType.text;
        padding =
            const EdgeInsets.only(left: 20, right: 20, top: 35, bottom: 10);
        maxLength = 50;
        break;
      case FieldType.partecipants:
        padding =
            const EdgeInsets.only(left: 40, right: 40, top: 6, bottom: 20);
        maxLength = 5;
        keyboardType = TextInputType.number;
        break;
    }

    return Padding(
      padding: padding,
      child: TextField(
        controller: controller,
        decoration: fieldDecoration(fieldType),
        cursorColor: Colors.black54,
        keyboardType: keyboardType,
        minLines: 1,
        maxLines: 20,
        maxLength: maxLength,
      ),
    );
  }

  //fieldDecoration provides the stylling of the TextField based on the FieldType
  InputDecoration fieldDecoration(FieldType fieldType) {
    final String labelText;
    final String hintText;
    switch (fieldType) {
      case FieldType.title:
        labelText = 'Titolo';
        hintText = 'Massimo 50 caratteri';
        break;
      case FieldType.requirements:
        labelText = 'Requisiti';
        hintText = 'I requisiti richiesti per la partecipazione';
        break;
      case FieldType.description:
        labelText = 'Descrizione';
        hintText = 'Inserisci una descrizione di almeno 100 caratteri';
        break;
      case FieldType.partecipants:
        labelText = 'Max Partecipanti';
        hintText = '';
        break;
    }

    return InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
        floatingLabelAlignment: FloatingLabelAlignment.center,
        label: Text(
          labelText,
          style: const TextStyle(
              color: Colors.black87, fontWeight: FontWeight.w500),
        ),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black54),
        fillColor: const Color.fromARGB(255, 177, 174, 174).withAlpha(70),
        filled: true,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide(
                color: const Color.fromARGB(255, 177, 174, 174).withAlpha(20),
                width: 2)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide(
                color: const Color.fromARGB(255, 177, 174, 174).withAlpha(20),
                width: 2)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide(
                color: const Color.fromARGB(255, 177, 174, 174).withAlpha(20),
                width: 2)));
  }
}

//Thumbnail displays and permits to choose the thumbnail of the post
class Thumbnail extends StatefulWidget {
  final Function(File?) callback;
  bool restart;
  Thumbnail({Key? key, required this.callback, required this.restart})
      : super(key: key);

  @override
  State<Thumbnail> createState() => _ThumbnailState();
}

class _ThumbnailState extends State<Thumbnail> {
  File? _thumbnail;
  @override
  Widget build(BuildContext context) {
    if (widget.restart) {
      _thumbnail = null;
      widget.restart = false;
    }
    return InkWell(
      onTap: () async {
        //if the user did not pick the image, im = null
        final im = await pickImage(context);
        setState(() {
          _thumbnail = im;
        });
        //the callback is called. It is used to set the NewPostPage._thumbail equal to the local variable _thumbnail
        widget.callback(_thumbnail);
      },
      //simple decoration
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.3,
        margin: const EdgeInsets.all(13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color.fromARGB(255, 177, 174, 174).withAlpha(60)),
        //if _thumbnail == null it shows a rounded rectangle and a text "Choose a thumbnail".
        child: _thumbnail == null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Padding(
                    padding: EdgeInsets.only(right: 5),
                    child: Icon(
                      Icons.add_a_photo,
                      color: Colors.black45,
                    ),
                  ),
                  Text('Inserisci una copertina',
                      style: TextStyle(
                          fontFamily: 'Ubuntu', color: Colors.black45))
                ],
              )
            //Otherwise it shows the image
            : ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Image.file(
                    _thumbnail!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
      ),
    );
  }
}

//the Place widget is used to pick the location of the activity
class Place extends StatefulWidget {
  final Function callback;
  bool restart;
  Place({Key? key, required this.callback, required this.restart})
      : super(key: key);

  @override
  State<Place> createState() => _PlaceState();
}

class _PlaceState extends State<Place> {
  String? _address;
  @override
  Widget build(BuildContext context) {
    //iff restart = true, _address = null and thus the widget is empty
    if (widget.restart) {
      _address = null;
      widget.restart = false;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10, right: 25, left: 25, bottom: 6),
      child: InkWell(
        onTap: () async {
          //when popped, the ChooseLocationScreen returns null, if no location was chosen,
          //otherwise it returns a string with the name of the location
          final add = await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ChooseLocationScreen()));
          setState(() {
            _address = add;
          });
          widget.callback(_address);
        },
        //if the location was chosen, an green check is show next to it, otherwise a red X.
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _address == null
                ? const Icon(
                    Icons.close,
                    color: Colors.red,
                  )
                : const Icon(
                    Icons.done,
                    color: Colors.green,
                  ),
            //if the location has still to be chosen, it shows a text "Select a location"
            Flexible(
              child: Text(
                _address == null ? 'Seleziona il luogo' : _address!,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Ubuntu',
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(
              Icons.place_outlined,
              color: Colors.black87,
            ),
          ],
        ),
      ),
    );
  }
}

//The Date class fundamentally works as the Place widget. Also in the design it is similar.
class Date extends StatefulWidget {
  final Function(DateTime?) callback;
  bool restart;
  Date({Key? key, required this.callback, required this.restart})
      : super(key: key);

  @override
  State<Date> createState() => _DateState();
}

class _DateState extends State<Date> {
  DateTime? _datePicked;
  @override
  Widget build(BuildContext context) {
    if (widget.restart) {
      _datePicked = null;
      widget.restart = false;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10, right: 25, left: 25, bottom: 6),
      child: InkWell(
        onTap: () async {
          DateTime currentDate = DateTime.now();
          //the only difference, is that of course to pick the date a datePicker is shown.
          //Remember that if no date is chosen, date = null
          final date = await showDatePicker(
              context: context,
              //it is not possible to choose a date before the current date, as all posts are events for the future, of course
              initialDate: currentDate,
              firstDate: currentDate,
              lastDate: DateTime(currentDate.year + 1));
          setState(() {
            _datePicked = date;
          });
          widget.callback(_datePicked);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _datePicked == null
                ? const Icon(
                    Icons.close,
                    color: Colors.red,
                  )
                : const Icon(
                    Icons.done,
                    color: Colors.green,
                  ),
            //formatDate displays the date in a more readble way, isntead of showing just some numbers
            Flexible(
              child: Text(
                _datePicked == null
                    ? 'Seleziona la data'
                    : formatDate(_datePicked!.toString()),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontFamily: 'Ubuntu',
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(
              Icons.date_range_outlined,
              color: Colors.black87,
            )
          ],
        ),
      ),
    );
  }
}

//The Time class fundamentally works as the Date widget. Also in the design it is similar.
class Time extends StatefulWidget {
  final Function callback;
  bool restart;
  Time({Key? key, required this.callback, required this.restart})
      : super(key: key);

  @override
  State<Time> createState() => _TimeState();
}

class _TimeState extends State<Time> {
  TimeOfDay? _timePicked;
  @override
  Widget build(BuildContext context) {
    if (widget.restart) {
      _timePicked = null;
      widget.restart = false;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10, right: 25, left: 25, bottom: 6),
      child: InkWell(
        onTap: () async {
          //the only actual difference with the Date widget, is that instead of showDatePicker, showTimePicker is used
          final time = await showTimePicker(
              context: context,
              //the initial time is the default time.
              initialTime: const TimeOfDay(hour: 12, minute: 00));
          setState(() {
            _timePicked = time;
          });
          widget.callback(_timePicked);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _timePicked == null
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
                _timePicked == null
                    ? "Seleziona l'orario"
                    : _timePicked!.format(context),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontFamily: 'Ubuntu',
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(
              Icons.timer_outlined,
              color: Colors.black87,
            )
          ],
        ),
      ),
    );
  }
}

//photos is a horizontally scrollable list, used to insert additional images to the post
class Photos extends StatefulWidget {
  final Function(File?) callback;
  bool restart;
  Photos({Key? key, required this.callback, required this.restart})
      : super(key: key);

  @override
  State<Photos> createState() => _PhotosState();
}

class _PhotosState extends State<Photos> {
  //initially, _photos is a list containing just a null value
  var _photos = <File?>[null];
  @override
  Widget build(BuildContext context) {
    //if restart = true, __photos returns to its original state
    if (widget.restart) {
      _photos = <File?>[null];
      widget.restart = false;
    }
    return Container(
        width: double.maxFinite,
        height: 300,
        margin: const EdgeInsets.only(left: 30),
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _photos.length,
            itemBuilder: ((context, index) => InkWell(
                  //only the last item of the list can be clicked, and the last item is always equal to null.
                  onTap: (_photos[index] == null)
                      //when an item of the list is tapped, the picker is shown and the corresponding index of the photo is set to be equal to the image picked (im)
                      ? () async {
                          final im = await pickImage(context);
                          setState(() {
                            _photos[index] = im;
                          });
                          //the callback is used to add to the NewPostPage._photos list the _photo picked
                          widget.callback(im);
                          if (im != null) {
                            _photos.add(null);
                          }
                        }
                      : () {},
                  child: Container(
                    width: 200,
                    height: 250,
                    margin: const EdgeInsets.only(right: 10, top: 12),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 177, 174, 174)
                          .withAlpha(60),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    //if the object at the current index is equal to null,
                    //it means that it is the last element of the array, and thus it is used only to diplay to the user 'add a new image'.
                    //the last item is always used to be clicked to add a new image. Instead the other items of the array are the images already added
                    child: (_photos[index] == null)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Inserisci immagine',
                                style: TextStyle(
                                    fontFamily: 'Ubuntu',
                                    color: Colors.black45),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Icon(
                                  Icons.add_a_photo_outlined,
                                  color: Colors.black45,
                                ),
                              )
                            ],
                          )
                        //Otherwise, it simply displays the image
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              _photos[index]!,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ))));
  }
}
