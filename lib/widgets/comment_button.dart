import 'package:flutter/material.dart';
import 'comment_list.dart';

class CommentButton extends StatelessWidget {
  final int postId;
  const CommentButton({Key? key, required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () async {
          //once clicked, it shows a bottom sheet
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (ctx) {
              return FractionallySizedBox(
                heightFactor: 0.8,
                child: Container(
                  //height: 100,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(23),
                          topRight: Radius.circular(23))),
                  child: CommentList(
                    //the comment list contains all teh comments to view for the given posts
                    postId: postId,
                  ),
                ),
              );
            },
          );
        },
        icon: const Icon(Icons.comment_outlined, color: Colors.black));
  }
}
