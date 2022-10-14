import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/posts.dart';

class NewLikeButton extends StatelessWidget {
  final bool isLiked;
  final int currentUserId;
  final int postId;
  const NewLikeButton(
      {required this.isLiked,
      required this.currentUserId,
      required this.postId});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () async {
          //when clicked the property isLiked of the post changes.
          await Provider.of<Posts>(context, listen: false)
              .likePost(postId: postId, currentUserId: currentUserId);
        },
        //the heart icon is filled in red if the post is liked, it is empty otherwise
        icon: isLiked
            ? const Icon(
                Icons.favorite,
                color: Colors.red,
              )
            : const Icon(Icons.favorite_border_outlined));
  }
}
