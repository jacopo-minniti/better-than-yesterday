import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/posts.dart';
import '../utils/colors.dart';

class NewSharesButton extends StatelessWidget {
  final bool isShared;
  final int currentUserId;
  final int postId;
  const NewSharesButton(
      {required this.isShared,
      required this.currentUserId,
      required this.postId});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () async {
          //when clicked the property isShared of the post changes, and the post is added/removed form the sharedPost instantly.
          await Provider.of<Posts>(context, listen: false)
              .sharePost(postId: postId, currentUserId: currentUserId);
        },
        icon: Icon(
          Icons.share_outlined,
          //the color of the icon is blue if the post is currently shared by the user, it is black otherwise
          color: isShared ? electricBlueColor : Colors.black,
        ));
  }
}
