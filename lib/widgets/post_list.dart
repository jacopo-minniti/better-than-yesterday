import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:uuid/uuid.dart';

import 'post_card.dart';

class PostList extends StatelessWidget {
  //this widget is fundamental for the application, as it is used every time a list of posts has to be displayed
  final List posts;
  final int currentUserId;
  PostList({
    Key? key,
    required this.posts,
    required this.currentUserId,
  }) : super(key: key);
  final itemScrollController = ItemScrollController();
  final itemPositionsListener = ItemPositionsListener.create();

  @override
  Widget build(BuildContext context) {
    //If there are no posts to display "No posts to view at the moment" is visualized instead.
    return posts.isEmpty
        ? const Center(child: Text('Nessun Post da visualizzare al momento.'))
        : ScrollablePositionedList.builder(
            //this ScrollablePositionedList.builder is preffered to ListView.builder mainly for performance reasons.
            //See the paragraph 2.4 of the technical PDF for further information
            shrinkWrap: true,
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: PostCard(
                    post: posts[index],
                    currentUserId: currentUserId,
                    heroTag: const Uuid().v1()),
              );
            },
            itemScrollController: itemScrollController,
            itemPositionsListener: itemPositionsListener);
  }
}
