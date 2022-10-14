import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart'
    show pushNewScreen;
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../services/posts.dart';
import '../services/users.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/new_like_button.dart';
import '../widgets/new_partecipate_button.dart';
import 'pages/profile_page.dart';

//This screen is displayed every time the user clicks on a post card
class DetailsScreen extends StatelessWidget {
  static const routeName = '/details';
  final Post post;
  final int currentUserId;
  final String heroTag;
  const DetailsScreen({
    Key? key,
    required this.currentUserId,
    required this.heroTag,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.maxFinite,
      width: double.maxFinite,
      //the Stack widgets displayes its children one over the other
      child: Stack(children: [
        //on the bbackground, it is shown the thumbnail
        Positioned(
          left: 0,
          right: 0,
          child: Hero(
            tag: heroTag,
            child: Container(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(post.thumbnail), fit: BoxFit.cover)),
            ),
          ),
        ),
        //On the foregorund, it is displayed a DraggableScrollableSheet
        Positioned.fill(
          top: 0,
          child: CustomDraggableScrollableSheet(
              context: context,
              post: post,
              username: post.username,
              currentUserId: currentUserId),
        )
      ]),
    );
  }
}

class CustomDraggableScrollableSheet extends StatefulWidget {
  final String username;
  final Post post;
  final int currentUserId;
  final BuildContext context;
  const CustomDraggableScrollableSheet(
      {Key? key,
      required this.post,
      required this.username,
      required this.currentUserId,
      required this.context})
      : super(key: key);

  @override
  State<CustomDraggableScrollableSheet> createState() =>
      _CustomDraggableScrollableSheetState();
}

class _CustomDraggableScrollableSheetState
    extends State<CustomDraggableScrollableSheet> {
  var _isInit = true;
  var circularRadius = 30.0;
  Future? future;
  late final double width;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      // The width of the screen
      width = MediaQuery.of(context).size.width;
      // While most of the data for the post details is already in the app state and passed to the details screen through a constructor,
      // the additional images have to be retrieved from the database.
      // In addition, in this screen, are also displayed the users who both participate to the post and are current user's followings.
      // To obtain all this information, a Futurebuilder is used
      future = Provider.of<Users>(context, listen: false)
          .partecipantsAndPhotos(widget.post.postId);

      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      //the onNotification function is called whenever the user scrolls the DraggableScrollableSheet.
      onNotification: (DraggableScrollableNotification dsNotification) {
        //the circularRadius defines how much the corners of the sheet are rounded.
        //If the user is going to completely open the sheet, occupying all the screen, these corners gradually loose all their 'roundness'.
        if (dsNotification.extent >= 0.90 && dsNotification.extent < 0.98) {
          setState(() {
            circularRadius = 15;
          });
        }
        if (dsNotification.extent >= 0.98) {
          setState(() {
            circularRadius = 0;
          });
        }
        return true;
      },
      child: DraggableScrollableSheet(
          initialChildSize: 0.63,
          //the sheet never goes lower than the initial size
          minChildSize: 0.63,
          builder: (ctx, scrollController) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(circularRadius),
                      topRight: Radius.circular(circularRadius))),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(children: [
                  Container(
                      width: width * 0.3,
                      margin: const EdgeInsets.only(bottom: 10, top: 3),
                      child:
                          const Divider(color: Colors.black38, thickness: 1.4)),
                  //starting from here, all the detailed information are displayed.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: width * 0.70,
                        child: Text(
                          //the title
                          widget.post.title,
                          style: const TextStyle(
                              fontFamily: 'Ubuntu',
                              fontWeight: FontWeight.w800,
                              fontSize: 25),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'Organizzatore',
                              style: TextStyle(
                                  fontFamily: 'Ubuntu',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400),
                            ),
                            //the author of the post
                            Text(widget.username,
                                style: const TextStyle(
                                    fontFamily: 'Ubuntu',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: electricBlueColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.place,
                            color: electricBlueColor,
                            size: 24,
                          ),
                        ),
                        Text(
                          //the name of the location
                          widget.post.location!,
                          style: const TextStyle(
                            fontFamily: 'Ubuntu',
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.date_range_rounded,
                          color: electricBlueColor,
                          size: 24,
                        ),
                      ),
                      Text(
                        //the date of the event
                        formatDate(widget.post.date),
                        style: const TextStyle(
                          fontFamily: 'Ubuntu',
                        ),
                      ),
                      const SizedBox(
                        width: 40,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.timer_outlined,
                          color: electricBlueColor,
                          size: 24,
                        ),
                      ),
                      Text(
                        //the time of the event
                        formatTime(widget.post.date),
                        style: const TextStyle(
                          fontFamily: 'Ubuntu',
                        ),
                      )
                    ],
                  ),
                  //the following row contains Consumers as its children are the like button, and the text with the number of likes. Thus, they change when the user clicks on the button
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Consumer<Posts>(
                          builder: (context, value, child) => RichText(
                            text: TextSpan(
                                text: 'Questo evento piace a ',
                                style: const TextStyle(
                                    fontFamily: 'Ubuntu',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                    color: Colors.black),
                                children: [
                                  TextSpan(
                                      text:
                                          '${widget.post.likes.toString()} persone',
                                      style: const TextStyle(
                                          fontFamily: 'Ubuntu',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: electricBlueColor))
                                ]),
                          ),
                        ),
                        //this is the exact same button, and works the exact same way, as the like button in the post card
                        Consumer<Posts>(
                            builder: (context, postsProvider, child) {
                          return NewLikeButton(
                            currentUserId: widget.currentUserId,
                            isLiked: widget.post.isLiked,
                            postId: widget.post.postId,
                          );
                        }),
                      ]),
                  //the same is true for the participate button. It is the same widget as the on edisplayed on the post card
                  Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Consumer<Posts>(
                          builder: (context, postProvider, child) {
                        return NewPartecipateButton(
                          currentUserId: widget.currentUserId,
                          postId: widget.post.postId,
                          isPartecipable: widget.post.maxPartecipants -
                                  widget.post.partecipations >
                              0,
                          partecipationStatus: widget.post.partecipationStatus,
                        );
                      })),
                  //from here, the information which have to be retrieved from the database are displayed
                  SizedBox(
                    width: double.maxFinite,
                    child: FutureBuilder(
                        future: future,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox();
                          }
                          //data is a list of list (List<List>). The first list contains the participants, the second list the images
                          final data = snapshot.data as List;
                          final followingPartecipants = data[0] as List;
                          final photos = data[1] as List;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                  textAlign: TextAlign.start,
                                  text: TextSpan(
                                    text: 'Partecipanti \n', //Participants
                                    style: const TextStyle(
                                        fontFamily: 'Ubuntu',
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 22),
                                    children: <TextSpan>[
                                      const TextSpan(
                                          text:
                                              'A questo evento partecipano ', //{numParticipants} participate in this event
                                          style: TextStyle(
                                              fontFamily: 'Ubuntu',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 15)),
                                      TextSpan(
                                          text:
                                              '${widget.post.partecipations.toString()} persone \n',
                                          style: const TextStyle(
                                              fontFamily: 'Ubuntu',
                                              fontWeight: FontWeight.w600,
                                              color: electricBlueColor,
                                              height: 1.8,
                                              fontSize: 15)),
                                      //maxParticipants - numParticipants = remaining seats
                                      TextSpan(
                                          text: (widget.post.maxPartecipants -
                                                  widget.post.partecipations)
                                              .toString(),
                                          style: const TextStyle(
                                              fontFamily: 'Ubuntu',
                                              fontWeight: FontWeight.w600,
                                              color: electricBlueColor,
                                              height: 1.8,
                                              fontSize: 15)),
                                      const TextSpan(
                                          text:
                                              ' posti disponibili \n', //Available seats
                                          style: TextStyle(
                                            fontFamily: 'Ubuntu',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15,
                                            height: 1.8,
                                          )),
                                      const TextSpan(
                                          text: 'Segui ',
                                          style: TextStyle(
                                            fontFamily: 'Ubuntu',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15,
                                            height: 1.8,
                                          )),
                                      TextSpan(
                                          text:
                                              '${followingPartecipants.length.toString()} persone',
                                          style: const TextStyle(
                                              fontFamily: 'Ubuntu',
                                              fontWeight: FontWeight.w600,
                                              color: electricBlueColor,
                                              height: 1.8,
                                              fontSize: 15)),
                                      const TextSpan(
                                          text: ' fra i partecipanti',
                                          style: TextStyle(
                                              fontFamily: 'Ubuntu',
                                              fontWeight: FontWeight.w400,
                                              height: 1.8,
                                              fontSize: 15))
                                    ],
                                  )),
                              //if there are participants who are also followed by the user, a horizontal ListView is shown.
                              if (followingPartecipants.isNotEmpty)
                                SizedBox(
                                  width: double.maxFinite,
                                  height: 80,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: followingPartecipants.length,
                                    itemBuilder: (context, index) => Padding(
                                      padding: const EdgeInsets.only(
                                        top: 13,
                                        left: 9,
                                      ),
                                      child: InkWell(
                                        //if the profile picture is clicked, the ProfilePage of the user is shown.
                                        onTap: () {
                                          pushNewScreen(context,
                                              screen: ProfilePage(
                                                  userId: int.parse(
                                                      followingPartecipants[
                                                          index]['userId'])));
                                        },
                                        //every participant is represented by his profile picture
                                        child: CircleAvatar(
                                            radius: 28,
                                            backgroundImage: NetworkImage(
                                                followingPartecipants[index]
                                                    ['profilePictureUrl'])),
                                      ),
                                    ),
                                  ),
                                ),
                              //Requirements
                              SizedBox(
                                width: double.maxFinite,
                                child: RichText(
                                    textAlign: TextAlign.start,
                                    text: TextSpan(
                                      text: 'Requisiti \n',
                                      style: const TextStyle(
                                          fontFamily: 'Ubuntu',
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          height: 1.8,
                                          fontSize: 22),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: widget.post.requirements,
                                            style: const TextStyle(
                                              fontFamily: 'Ubuntu',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 15,
                                              height: 1.2,
                                            )),
                                      ],
                                    )),
                              ),
                              //The whole description
                              SizedBox(
                                width: double.maxFinite,
                                child: RichText(
                                    textAlign: TextAlign.start,
                                    text: TextSpan(
                                      text: 'Descrizione \n',
                                      style: const TextStyle(
                                          fontFamily: 'Ubuntu',
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          height: 1.8,
                                          fontSize: 22),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: widget.post.description,
                                            style: const TextStyle(
                                              fontFamily: 'Ubuntu',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 15,
                                              height: 1.2,
                                            )),
                                      ],
                                    )),
                              ),
                              //An horizontal ListView is used to display additional images
                              Container(
                                width: double.maxFinite,
                                height: 300,
                                margin:
                                    const EdgeInsets.only(top: 17, bottom: 30),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: photos.length,
                                  itemBuilder: (context, index) => Container(
                                    width: 200,
                                    height: 300,
                                    margin: const EdgeInsets.only(
                                        right: 10, top: 12),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                              255, 177, 174, 174)
                                          .withAlpha(60),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        photos[index]['photo'],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                  ),
                ]),
              ),
            );
          }),
    );
  }
}
