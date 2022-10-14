import 'dart:ui';

import 'package:flutter/material.dart';

class SmallPostCard extends StatelessWidget {
  //the small post card is used only for trend posts and categories. It displays only the thumbnail of the post and its title.
  //It works similarly to the classic post card
  final VoidCallback action;
  final ImageProvider image;
  final String heroTag;
  final String title;
  const SmallPostCard(
      {Key? key,
      required this.action,
      required this.image,
      required this.heroTag,
      required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final boxWidth = MediaQuery.of(context).size.width * 0.58;
    final boxHeight = MediaQuery.of(context).size.height * 0.35;
    //When clicked shows the DetailsScreen
    return InkWell(
        onTap: action,
        child: Stack(children: [
          heroTag != ''
              ? Hero(
                  tag: heroTag,
                  child: Container(
                    width: boxWidth,
                    height: boxHeight,
                    margin: const EdgeInsets.only(right: 10, top: 12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        image:
                            DecorationImage(image: image, fit: BoxFit.cover)),
                  ),
                )
              : Container(
                  width: boxWidth,
                  height: boxHeight,
                  margin: const EdgeInsets.only(right: 10, top: 12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(image: image, fit: BoxFit.cover)),
                ),
          //The styling used for the title is equal to that used for the post card
          Container(
              width: boxWidth,
              padding: const EdgeInsets.all(8),
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        child: Flex(direction: Axis.horizontal, children: [
                          Expanded(
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontFamily: 'Ubuntu',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 25),
                            ),
                          ),
                        ]),
                      ))))
        ]));
  }
}
