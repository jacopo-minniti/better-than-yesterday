import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart'
    show pushNewScreen, PageTransitionAnimation;
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../services/posts.dart';
import '../screens/details_screen.dart';
import '../utils/utils.dart';
import 'comment_button.dart';
import 'new_like_button.dart';
import 'new_partecipate_button.dart';
import 'new_shares_button.dart';
import '../screens/pages/profile_page.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final int currentUserId;
  final String heroTag;
  const PostCard(
      {Key? key,
      required this.post,
      required this.currentUserId,
      required this.heroTag})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        //when the postcard is clicked, the user navigates to the DetailsScreen.
        //The details screen wants as parameters, the post, the currentUserId, and a tag used for the hero animation.
        //The transition is a slide from bottom to top
        pushNewScreen(context,
            screen: DetailsScreen(
              heroTag: heroTag,
              post: post,
              currentUserId: currentUserId,
            ),
            pageTransitionAnimation: PageTransitionAnimation.slideUp);
      },
      //to simplify and make more efficient the widget, all the parts of the card are divided in three widgets
      child: Column(children: [
        Up(post, currentUserId),
        CentralImage(post, heroTag),
        Bottom(post, currentUserId)
      ]),
    );
  }
}

class Up extends StatelessWidget {
  final int currentUserId;
  final Post post;
  const Up(this.post, this.currentUserId);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCurrentUser = currentUserId == post.userId;
    return InkWell(
      //when clicked, if the post does not belong to the current user, the ProfilePage of the author of the post is shown
      onTap: isCurrentUser
          ? () {}
          : () {
              pushNewScreen(context, screen: ProfilePage(userId: post.userId));
            },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 5, right: 12, left: width * 0.03),
            child: CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(post.profilePictureUrl)),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(post.username,
                style: const TextStyle(
                    fontFamily: 'Ubuntu',
                    fontSize: 17,
                    fontWeight: FontWeight.w500)),
          ),
          // if (post.isAuthorVerified)
          //   const Padding(
          //     padding: EdgeInsets.only(left: 9, bottom: 5),
          //     child: Icon(
          //       Icons.verified,
          //       color: electricBlueColor,
          //       size: 18,
          //     ),
          //   ),
          const Expanded(child: SizedBox()),
          Padding(
            padding: const EdgeInsets.only(bottom: 14, right: 10),
            child: PopupMenuButton(
              child: const Icon(
                Icons.more_vert,
                color: Colors.black87,
              ),
              // the post author is the current user, the three dots, when clicked, will show a button to delete the post.
              // Otherwise, a button to report the post is shown
              itemBuilder: (context) => <PopupMenuEntry>[
                isCurrentUser
                    //delete post
                    ? PopupMenuItem(
                        padding: const EdgeInsets.only(left: 25),
                        child: const Text(
                          'Elimina',
                          textAlign: TextAlign.center,
                        ),
                        onTap: () async {
                          var res = 'Post eliminato';
                          try {
                            await Provider.of<Posts>(context, listen: false)
                                .deletePost(post.postId);
                          } catch (err) {
                            res =
                                'Impossibile eliminare il post. Riprova più tardi';
                          }
                          showCustomSnackbar(context, res);
                        },
                      )
                    //report post (feature to add)
                    : PopupMenuItem(
                        padding: const EdgeInsets.only(left: 25),
                        child: const Text(
                          'Segnala',
                          textAlign: TextAlign.center,
                        ),
                        onTap: () async {
                          var res = 'Post segnalato con successo';
                          try {
                            // await Provider.of<Posts>(context, listen: false)
                            //     .report(post.postId.toString(), currentUserId);
                          } catch (err) {
                            res = 'Errore. Riprova più tardi';
                          }
                          showCustomSnackbar(context, res);
                        },
                      )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class CentralImage extends StatelessWidget {
  final Post post;
  final String heroTag;
  const CentralImage(this.post, this.heroTag);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    //to display the title in a consistent way, containerWidth is adjusted according to the length of the title
    final containerWidth =
        post.title.length > 18 ? width - 20 : post.title.length * 17;
    return Stack(
      //the title is positioned above the thumbnail thanks to the Stack and Positioned widgets
      children: [
        SizedBox(
          height: width * 0.68,
          width: width,
          child: Hero(
              tag: heroTag,
              child: Image.network(post.thumbnail, fit: BoxFit.cover)),
        ),
        Positioned(
            bottom: 10,
            left: 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  //height: 35,
                  width: containerWidth.toDouble(),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  child: Text(
                    post.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w800,
                        fontSize: 25),
                  ),
                ),
              ),
            ))
      ],
    );
  }
}

class Bottom extends StatelessWidget {
  final int currentUserId;
  final Post post;
  const Bottom(this.post, this.currentUserId);

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = currentUserId == post.userId;
    final height = MediaQuery.of(context).size.height * 0.07;
    return Column(
      children: [
        //this rows contains the four buttons to like, share, partecipate to the post, and see its comments.
        // Every button, other than the comment one, is child of a Consumer.
        // In this way, every time an action is performed (like, share, partecipation), the button automatically rebuild
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 15, top: 15, right: 10, left: 8),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(10)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      alignment: Alignment.topCenter,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Consumer<Posts>(
                                builder: (context, postsProvider, child) {
                              return NewLikeButton(
                                currentUserId: currentUserId,
                                isLiked: post.isLiked,
                                postId: post.postId,
                              );
                            }),
                            CommentButton(postId: post.postId),
                            if (!isCurrentUser)
                              Consumer<Posts>(
                                  builder: (context, postsProvider, child) {
                                return NewSharesButton(
                                  currentUserId: currentUserId,
                                  isShared: post.isShared,
                                  postId: post.postId,
                                );
                              })
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: Consumer<Posts>(builder: (context, value, child) {
              return NewPartecipateButton(
                  currentUserId: currentUserId,
                  postId: post.postId,
                  isPartecipable:
                      post.maxPartecipants - post.partecipations > 0,
                  partecipationStatus: post.partecipationStatus);
            })),
          ],
        ),
        //a short version of the description is shown.
        Container(
          width: double.maxFinite,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            post.description,
            style: const TextStyle(fontFamily: 'Ubuntu', fontSize: 14),
            //when the description overflows the available space, three dots are shown thanks to the TextOverflow.ellipsis enum value
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        )
      ],
    );
  }
}
