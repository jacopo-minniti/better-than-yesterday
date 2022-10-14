import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';

import '../utils/colors.dart';

class ChooseLocationScreen extends StatefulWidget {
  const ChooseLocationScreen({Key? key}) : super(key: key);

  @override
  State<ChooseLocationScreen> createState() => //
      _ChooseLocationScreenState();
}

class _ChooseLocationScreenState extends State<ChooseLocationScreen> {
  final _startSearchFieldController = TextEditingController();

  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];

  @override
  void initState() {
    super.initState();
    //the API key for Google maps
    String apiKey = 'YOUR_GOOGLE_MAPS API KEY';
    //object provided by the google_place package
    googlePlace = GooglePlace(apiKey);
  }

  void autoCompleteSearch(String value) async {
    //get the suggestions for the locations using the autocomplete method. They are all get in italian
    var result = await googlePlace.autocomplete.get(value, language: 'it');
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: const BackButton(color: opaqueBlueColor),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _startSearchFieldController,
                autofocus: false,
                style: const TextStyle(fontSize: 24),
                decoration: InputDecoration(
                    hintText: 'Il luogo che ospiterà la tua attività',
                    hintStyle: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 24),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: InputBorder.none),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    //every time something is typed, autoCompleteSearch is called
                    autoCompleteSearch(value);
                  } else {
                    //clear out the results
                  }
                },
              ),
              //the predictions are listed in the form of a scrollable list
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: predictions.length,
                  itemBuilder: (context, index) {
                    //next to an icon, it is displayed the prediction
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(
                          Icons.pin_drop,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(predictions[index].description.toString()),
                      onTap: () {
                        Navigator.pop(
                            context, predictions[index].description.toString());
                      },
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
