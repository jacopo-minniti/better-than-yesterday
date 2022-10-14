import 'package:flutter/material.dart';

import '../utils/colors.dart';

class Filters extends StatelessWidget {
  //userFilters are the filters selected by the user before tapping on anything. When this widget is used in UserInformationScreen(),
  // the starting map has all values equal to false. However, when used in EditScreen(), userFilters correspons to the filters the user previously selected.
  final Map<String, bool> userFilters;
  Function(String)
      addFilter; //the callback is used to change the filters map defined in the Widget where this class is used.
  Filters({required this.addFilter, required this.userFilters});
  @override
  Widget build(BuildContext context) {
    //this widget defines a grid of clickable containers.
    return GridView.count(
      crossAxisCount: 3,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(0.0),
      shrinkWrap: true, //occupies only the space needed. Nothing more.
      childAspectRatio: 3 / 1,
      mainAxisSpacing: 0.0,
      crossAxisSpacing: 0.0,
      children: [
        //all these CustomChips differ for the name and for the value of isSelected
        CustomChip(
            isSelected: userFilters['f_manuale']!,
            chipName: 'manuale',
            addFilter: (chipName) {
              addFilter(chipName);
            }),
        CustomChip(
            isSelected: userFilters['f_intellettuale']!,
            chipName: 'intellettuale',
            addFilter: (chipName) {
              addFilter(chipName);
            }),
        CustomChip(
            isSelected: userFilters['f_famiglie']!,
            chipName: 'famiglie',
            addFilter: (chipName) {
              addFilter(chipName);
            }),
        CustomChip(
            isSelected: userFilters['f_individuale']!,
            chipName: 'individuale',
            addFilter: (chipName) {
              addFilter(chipName);
            }),
        CustomChip(
            isSelected: userFilters['f_collaborativo']!,
            chipName: 'collaborativo',
            addFilter: (chipName) {
              addFilter(chipName);
            }),
        CustomChip(
            isSelected: userFilters['f_senzaTetto']!,
            chipName: 'senzaTetto',
            addFilter: (chipName) {
              addFilter(chipName);
            }),
        CustomChip(
            isSelected: userFilters['f_consulenza']!,
            chipName: 'consulenza',
            addFilter: (chipName) {
              addFilter(chipName);
            }),
        CustomChip(
            isSelected: userFilters['f_bambini']!,
            chipName: 'bambini',
            addFilter: (chipName) {
              addFilter(chipName);
            }),
        CustomChip(
            isSelected: userFilters['f_doposcuola']!,
            chipName: 'doposcuola',
            addFilter: (chipName) {
              addFilter(chipName);
            }),
        CustomChip(
            isSelected: userFilters['f_mensaDeiPoveri']!,
            chipName: 'mensaDeiPoveri',
            addFilter: (chipName) {
              addFilter(chipName);
            }),
        CustomChip(
            isSelected: userFilters['f_centroDiAscolto']!,
            chipName: 'centroDiAscolto',
            addFilter: (chipName) {
              addFilter(chipName);
            }),
        CustomChip(
            isSelected: userFilters['f_immigrati']!,
            chipName: 'immigrati',
            addFilter: (chipName) {
              addFilter(chipName);
            }),
        CustomChip(
            isSelected: userFilters['f_tossicoDipendenti']!,
            chipName: 'tossicoDipendenti',
            addFilter: (chipName) {
              addFilter(chipName);
            }),
        CustomChip(
            isSelected: userFilters['f_donne']!,
            chipName: 'donne',
            addFilter: (chipName) {
              addFilter(chipName);
            }),
        CustomChip(
            isSelected: userFilters['f_anziani']!,
            chipName: 'anziani',
            addFilter: (chipName) {
              addFilter(chipName);
            }),
        CustomChip(
            isSelected: userFilters['f_diversamenteAbili']!,
            chipName: 'diversamenteAbili',
            addFilter: (chipName) {
              addFilter(chipName);
            }),
        CustomChip(
            isSelected: userFilters['f_comunita']!,
            chipName: 'comunita',
            addFilter: (chipName) {
              addFilter(chipName);
            }),
        CustomChip(
            isSelected: userFilters['f_attivitaArtistica']!,
            chipName: 'attivitaArtistica',
            addFilter: (chipName) {
              addFilter(chipName);
            }),
      ],
    );
  }
}

class CustomChip extends StatefulWidget {
  final String chipName; //the name which appears to the user
  final bool
      isSelected; //if isSelected = true, the contain changes color to blue.
  final Function(String) addFilter; //a callback for the Filters class
  const CustomChip(
      {Key? key,
      required this.chipName,
      required this.addFilter,
      required this.isSelected})
      : super(key: key);

  @override
  State<CustomChip> createState() => _CustomChipState();
}

class _CustomChipState extends State<CustomChip> {
  var _isSelected = false;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.isSelected;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: electricBlueColor,
      splashColor: electricBlueColor,
      onTap: () {
        setState(() {
          _isSelected = !_isSelected;
        });
        widget.addFilter(widget.chipName);
      },
      child: Container(
        decoration: BoxDecoration(
            color: _isSelected
                ? electricBlueColor
                : const Color.fromARGB(255, 177, 174, 174).withAlpha(60),
            border: Border.all(width: 0.3, color: Colors.white)),
        height: 10,
        alignment: Alignment.center,
        child: customText(widget.chipName, _isSelected),
      ),
    );
  }

  Text customText(String title, bool isSelected) => Text(
      widget
          .chipName, //the text changes color depending on the state of the Chip.
      textAlign: TextAlign.center,
      style: TextStyle(
          fontFamily: 'Ubuntu',
          letterSpacing: 2,
          fontSize: 13,
          color: isSelected ? Colors.white : Colors.black));
}
