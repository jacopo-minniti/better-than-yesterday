import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart'
    show pushNewScreen;
import 'package:provider/provider.dart';

import '../screens/pages/profile_page.dart';
import '../services/comments.dart';
import '../services/users.dart';
import '../screens/settings_screen.dart' show CustomTextButton;
import '../utils/colors.dart';
import '../utils/utils.dart';

class CommentList extends StatefulWidget {
  final int postId;
  const CommentList({Key? key, required this.postId}) : super(key: key);

  @override
  State<CommentList> createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {
  late final TextEditingController controller;
  var width = 0.0;
  late final int currentUserId;
  Future? future;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(); //initialize the controller
    currentUserId = Provider.of<Users>(context, listen: false).userId;
    //once completed, the snapshot of this future will contain all the comments for the post
    future = Provider.of<Comments>(context, listen: false)
        .setAndGetComments(widget.postId, currentUserId);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose(); //dispose the controller
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
        // The whole comment list is inside a consumer, which means that if notifyListener() is called from the comments provider, the list will rebuild
        child: Consumer<Comments>(
      builder: (context, commentsProvider, child) => Column(children: [
        CustomTextButton(
            //the bottom sheet can be closed by clicking on this button or by sliding it down.
            action: () => Navigator.of(context).pop(),
            title: 'Chiudi',
            icon: Icons.close_rounded,
            color: electricBlueColor),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: width * 0.8,
              child: TextField(
                controller: controller,
                maxLength: 500,
                minLines: 1,
                maxLines: 10,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(0),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: electricBlueColor)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: electricBlueColor)),
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: electricBlueColor)),
                    hintText: 'Scrivi un commento',
                    hintStyle: TextStyle(
                        fontFamily: 'Ubuntu', letterSpacing: 2, fontSize: 14)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: IconButton(
                icon: const Icon(Icons.send_rounded),
                color: electricBlueColor,
                onPressed: () async {
                  //if the commment length is between 1 and 2000, the createComment() method is called from the provider. It add the comment to the post, both locally and on the database
                  if (controller.text.isNotEmpty &&
                      controller.text.length <= 2000) {
                    final username =
                        Provider.of<Users>(context, listen: false).username;
                    final profilePictureUrl =
                        Provider.of<Users>(context, listen: false)
                            .profilePictureUrl;
                    commentsProvider.createComment(
                        postId: widget.postId,
                        body: controller.text,
                        userId: currentUserId,
                        username: username,
                        profilePictureUrl: profilePictureUrl);
                    controller.text = '';
                  }
                },
              ),
            )
          ],
        ),
        const SizedBox(
          height: 24,
        ),
        FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              //if the snapshot is not ready or has an error, it shows a buffering
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.hasError) {
                return const Center(
                    child: CircularProgressIndicator(
                  color: electricBlueColor,
                ));
              }
              //comments are displayed in a ListView, i.e. a scrollable list.
              final comments = commentsProvider.comments;
              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comments.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return ListTile(
                      onTap: () => comment.userId != currentUserId
                          ? pushNewScreen(context,
                              screen: ProfilePage(
                                userId: comment.userId,
                              ))
                          : () {},
                      leading: CircleAvatar(
                          radius: 16,
                          backgroundImage:
                              NetworkImage(comment.profilePictureUrl)),
                      title: RichText(
                        text: TextSpan(
                            text: '${comment.username}  ',
                            style: const TextStyle(
                                fontFamily: 'Ubuntu',
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                  text: comment.body,
                                  style: const TextStyle(
                                      fontFamily: 'Ubuntu',
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black))
                            ]),
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 18),
                            child: Text(
                              formatDate(comment.createdAt.toString()),
                              style: const TextStyle(
                                  fontFamily: 'Ubuntu', color: Colors.black45),
                            ),
                          ),
                          Text(
                            '${comment.likes} likes',
                            style: const TextStyle(
                                fontFamily: 'Ubuntu', color: Colors.black45),
                          )
                        ],
                      ),
                      //a like button to like comments is shown at the right of every comment.
                      trailing: IconButton(
                          onPressed: () async {
                            await commentsProvider.likeComment(
                                commentId: comment.commentId,
                                postId: comment.postId,
                                currentUserId: currentUserId);
                          },
                          icon: comment.isLiked
                              ? const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                )
                              : const Icon(
                                  Icons.favorite_outline,
                                  color: Colors.black,
                                )));
                },
              );
            })
      ]),
    ));
  }
}
