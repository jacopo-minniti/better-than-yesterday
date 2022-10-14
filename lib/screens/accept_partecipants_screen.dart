import 'package:better_than_yesterday/utils/colors.dart';
import 'package:better_than_yesterday/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart'
    show pushNewScreen;
import 'package:provider/provider.dart';

import '../services/users.dart';
import 'pages/profile_page.dart';

//the user navigates to AcceptPartecipantsScreen when he clicks,
//from the PartecipationsScreen(), on one of the posts under "Requests".
//Here, the user views all the users interested in participating the post.
class AcceptPartecipantsScreen extends StatefulWidget {
  final String title;
  final int postId;
  final String thumbnail;
  const AcceptPartecipantsScreen({
    Key? key,
    required this.title,
    required this.postId,
    required this.thumbnail,
  }) : super(key: key);

  @override
  State<AcceptPartecipantsScreen> createState() =>
      _AcceptPartecipantsScreenState();
}

class _AcceptPartecipantsScreenState extends State<AcceptPartecipantsScreen> {
  Future<void>? future() async {
    //query the database and select all the users who requested to participate to the given post
    await Provider.of<Users>(context, listen: false)
        .setRequestUsers(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(
              fontFamily: 'Ubuntu',
              color: Colors.black,
              fontWeight: FontWeight.w600,
              height: 1.8,
              fontSize: 25,
              letterSpacing: 2),
        ),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            width: double.maxFinite,
            child: Image.network(
              widget.thumbnail,
              fit: BoxFit.cover,
            ),
          ),
          FutureBuilder(
            future: future(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox();
              }
              return Consumer<Users>(
                builder: (context, usersProvider, child) => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: usersProvider.requestUsers.length,
                  itemBuilder: (context, index) {
                    final user = usersProvider.requestUsers[index];
                    //if the LListTile is clicked, the user navigates to the ProfilePage of the user selected
                    return ListTile(
                      onTap: () async {
                        pushNewScreen(
                          context,
                          screen:
                              ProfilePage(userId: int.parse(user['userId'])),
                        );
                      },
                      title: Text(user['username']),
                      leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(user['profilePictureUrl'])),
                      trailing: TextButton(
                        child: const Text('Accetta',
                            style: TextStyle(
                                color: electricBlueColor,
                                fontFamily: 'Ubuntu',
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.7)),
                        onPressed: () async {
                          //if the TextButton "Accept" is clicked, the acceptRequest method is fired, and the user is removed from the list requestUsers instantly
                          try {
                            await usersProvider.acceptRequest(
                                index: index,
                                postId: widget.postId,
                                userId: int.parse(user['userId']));
                          } catch (err) {
                            showCustomSnackbar(context, 'Posti esauriti');
                          }
                        },
                      ),
                    );
                  },
                ),
              );
            },
          )
        ],
      )),
    );
  }
}
