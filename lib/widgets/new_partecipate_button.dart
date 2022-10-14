import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/posts.dart';
import '../services/users.dart';
import '../utils/colors.dart';

class NewPartecipateButton extends StatelessWidget {
  final int partecipationStatus;
  final int currentUserId;
  final int postId;
  final bool isPartecipable;
  const NewPartecipateButton(
      {required this.partecipationStatus,
      required this.currentUserId,
      required this.isPartecipable,
      required this.postId});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        //the value of isPartecipable depends wether max partecipants is greater than the current number of partecipants
        if (!isPartecipable) {
          return;
        }
        //authorUserId != null when, by participating to the post, the new participationStatus is equal to 1;
        // which means that the user requested the partecipation
        final authorUserId = await Provider.of<Posts>(context, listen: false)
            .partecipate(currentUserId: currentUserId, postId: postId);
        if (authorUserId != null) {
          //only if the user has requested participation the notification is sent. Otherwise, it simply changes the value of participationStatus
          await Provider.of<Users>(context, listen: false)
              .sendNotification(authorUserId, postId);
        }
      },
      //below all the styling
      child: Container(
        height: 40,
        margin: const EdgeInsets.only(right: 5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: partecipationStatus > 0 ? Colors.white : electricBlueColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: partecipationStatus > 0
                ? null
                : const [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 1.0), //(x,y)
                      blurRadius: 6.0,
                    ),
                  ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: partecipationStatus > 0
                  ? const Icon(
                      Icons.group_remove_outlined,
                      color: electricBlueColor,
                    )
                  : const Icon(
                      Icons.group_add_outlined,
                      color: Colors.white,
                    ),
            ),
            Text(
              partecipationStatus > 0 ? 'Annulla' : 'Partecipa',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Ubuntu',
                  color: partecipationStatus > 0
                      ? electricBlueColor
                      : Colors.white,
                  fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
