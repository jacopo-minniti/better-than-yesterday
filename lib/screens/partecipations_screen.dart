import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart'
    show pushNewScreen, PageTransitionAnimation;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../services/posts.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import 'accept_partecipants_screen.dart';
import 'details_screen.dart';

class PartecipationsScreen extends StatefulWidget {
  final int userId;
  const PartecipationsScreen(this.userId);

  @override
  State<PartecipationsScreen> createState() => _PartecipationsScreenState();
}

class _PartecipationsScreenState extends State<PartecipationsScreen> {
  //the posts participated by the user
  var partecipations = <Map<String, dynamic>>[];
  //the posts to which the user requested participation
  var waitlist = [];
  //the posts published by the user and to which at least one user requested to participate
  var requests = [];

  Future<void>? future() async {
    //get all the data in a unique list
    final data = await Provider.of<Posts>(context, listen: false)
        .getPartecipationsAndRequests(widget.userId);

    data.forEach((element) {
      if (element['userId'] == '${widget.userId}') {
        //if the partecipationStatus = 1, it means that the request has not been accepted yet. If it equals to, the user already participates.
        if (element['partecipationStatus'] == '1') {
          waitlist.add(element);
        } else {
          partecipations.add(element);
        }
      } else {
        requests.add(element);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'Gestisci le partecipazioni',
          textAlign: TextAlign.start,
          style: TextStyle(
              fontFamily: 'DarkerGrotesque',
              fontWeight: FontWeight.w800,
              color: Colors.black,
              fontSize: 24),
        ),
      ),
      body: FutureBuilder(
        future: future(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          }
          return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      'Partecipazioni', //Participations
                      style: TextStyle(
                          fontFamily: 'Ubuntu',
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          height: 1.8,
                          fontSize: 25),
                    ),
                    // list of the participated posts
                    PostTile(
                        currentUserId: widget.userId,
                        postsData: partecipations,
                        isRequest: false),
                    const Text(
                      'In attesa', //waiting
                      style: TextStyle(
                          fontFamily: 'Ubuntu',
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          height: 1.8,
                          fontSize: 25),
                    ),
                    // list of the posts without response yet
                    PostTile(
                      currentUserId: widget.userId,
                      postsData: waitlist,
                      isRequest: false,
                    ),
                    const Text(
                      'Richieste', //Requests
                      style: TextStyle(
                          fontFamily: 'Ubuntu',
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          height: 1.8,
                          fontSize: 25),
                    ),
                    // list of the current user's posts to which at least one user requested to participate
                    PostTile(
                      currentUserId: widget.userId,
                      postsData: requests,
                      isRequest: true,
                    ),
                    const SizedBox(
                      height: 100,
                    )
                  ],
                ),
              ));
        },
      ),
    );
  }
}

// a scrollable list of ListTile
class PostTile extends StatelessWidget {
  final List postsData;
  final int currentUserId;
  final bool isRequest;
  const PostTile(
      {Key? key,
      required this.currentUserId,
      required this.postsData,
      required this.isRequest})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (postsData.isEmpty) {
      return const Text(
        'Nessun post da visualizzare',
        style: TextStyle(
            fontFamily: 'Ubuntu',
            color: Colors.black45,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.7),
        textAlign: TextAlign.center,
      );
    }
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: postsData.length,
        itemBuilder: (context, index) {
          //the tag used for the hero animation
          final heroTag = const Uuid().v4();
          final postData = postsData[index];
          return ListTile(
            //if isRequest == true, which means that we are dealing with the posts under 'Requests', by clicking on the ListTile we access the screen to eventually accept the requests
            onTap: isRequest
                ? () => pushNewScreen(context,
                    screen: AcceptPartecipantsScreen(
                      thumbnail: postData['thumbnail'],
                      title: postData['title'],
                      postId: int.parse(postData['postId']),
                    ))
                //otherwise, by clicking on the ListTile, we get all the post information and then access the DetailsScreen()
                : () async {
                    final post =
                        await Provider.of<Posts>(context, listen: false)
                            .getPostById(
                                int.parse(postData['postId']), currentUserId);
                    if (post == null) {
                      return;
                    }
                    pushNewScreen(context,
                        screen: DetailsScreen(
                            currentUserId: currentUserId,
                            heroTag: heroTag,
                            post: post),
                        pageTransitionAnimation:
                            PageTransitionAnimation.slideUp);
                  },
            leading: Hero(
              tag: heroTag,
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  postData['thumbnail'],
                ),
              ),
            ),
            title: Text(
              postData['title'],
              style: const TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.7),
            ),
            subtitle: Text(
              formatDate(postData['postDate']),
              style: const TextStyle(
                  fontFamily: 'Ubuntu',
                  color: Colors.black45,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.7),
            ),
            trailing: isRequest
                ? CircleAvatar(
                    radius: 13,
                    backgroundColor: electricBlueColor,
                    child: Text(
                      postData['numRequests'],
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                : null,
          );
        });
  }
}
