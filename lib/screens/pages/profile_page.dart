import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart'
    show pushNewScreen;
import 'package:provider/provider.dart';

import '../../services/authentication__service.dart';
import '../../services/users.dart';
import '../../utils/colors.dart';
import '../../models/user.dart' as model;
import '../../utils/utils.dart';
import '../../widgets/follow_button.dart';
import '../../widgets/profile_post_view.dart';
import '../edit_screen.dart';
import '../partecipations_screen.dart';

class ProfilePage extends StatefulWidget {
  final int? userId;

  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //if isPersonal = true, then we are viewing
  //the profile of the user currently logged
  var isPersonal = true;
  Future? future;

  Future userToDisplay() async {
    //ProfilePage accepts a parameter of type int? If the parameter is equal to null, it means it's the current user's profile.
    //In fact, if it is the current user, there is no need to pass another userId, as we already possses it in  the Users provider.
    //In this way, we easly distuinguish between the two possible situations
    if (widget.userId == null) {
      isPersonal = true;
      final currentUser = Provider.of<Users>(context).currentUser;
      return currentUser;
    }
    //if it is not the current user, we need to obbtain the user's information with a query
    isPersonal = false;
    return Provider.of<Users>(context, listen: false)
        .getUserById(widget.userId!);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        setState(() {});
        return Future.delayed(const Duration(microseconds: 1));
      },
      child: FutureBuilder(
          future: userToDisplay(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                    child: CircularProgressIndicator(
                  color: electricBlueColor,
                )),
              );
            }
            if (snapshot.hasError) {
              return const Scaffold(
                body: Center(
                    child:
                        Text("Si è verificato un'errore. Riprova più tardi")),
              );
            }
            //in both cases, snapshot.data contains a model.User
            final user = snapshot.data as model.User;
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: PreferredSize(
                preferredSize: const Size(double.maxFinite, 70),
                child: CustomAppBar(
                    numFollowers: user.numFollowers,
                    isPersonal: isPersonal,
                    isVerified: user.isVerified,
                    userId: user.userId,
                    username: user.username),
              ),
              body: SingleChildScrollView(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 22, right: 40),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(user.profilePictureUrl),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30, bottom: 17),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Stats is a customized text
                            Stats(
                                firstText: user.numFollowers.toString(),
                                secondText: '  Seguaci'),
                            Stats(
                                firstText: user.numFollowings.toString(),
                                secondText: '  Seguiti'),
                            Stats(
                                firstText: user.numPosts.toString(),
                                secondText: '  Post'),
                          ],
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16, left: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.place,
                            color: electricBlueColor,
                            size: 24,
                          ),
                        ),
                        Text(
                          user.location,
                          style: const TextStyle(
                            fontFamily: 'Ubuntu',
                            fontSize: 15,
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                      width: double.maxFinite,
                      margin: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 10),
                      child: Text(user.bio,
                          style: const TextStyle(
                              fontFamily: 'Ubuntu',
                              height: 1.2,
                              color: Colors.black,
                              fontWeight: FontWeight.w300,
                              fontSize: 14))),
                  ProfilePostView(
                    isPersonal: isPersonal,
                    user: user,
                  )
                ],
              )),
            );
          }),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  final bool isVerified;
  final bool isPersonal;
  final int numFollowers;
  final int userId;
  final String username;
  const CustomAppBar(
      {Key? key,
      required this.isVerified,
      required this.numFollowers,
      required this.userId,
      required this.username,
      required this.isPersonal})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: false,
        toolbarHeight: 65,
        leading: isPersonal
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 3),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                  ),
                ),
              ),
        //if isPersonal, buttons to signout, edit the profile and manage participations are shown
        actions: isPersonal
            ? [
                Padding(
                  padding: const EdgeInsets.only(top: 3, left: 6),
                  child: IconButton(
                    onPressed: () async {
                      await pushNewScreen(
                        context,
                        screen: PartecipationsScreen(userId),
                      );
                    },
                    icon: const Icon(
                      Icons.group_add,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: IconButton(
                    onPressed: () async {
                      await pushNewScreen(
                        context,
                        screen: const EditScreen(),
                      );
                    },
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: IconButton(
                    onPressed: () async {
                      await signout(context);
                    },
                    icon: const Icon(
                      Icons.logout_outlined,
                      color: Colors.black,
                    ),
                  ),
                )
              ]
            //otherwise, the current user is shown only a button to follow/unfollow the other user
            : [
                Center(
                  child: FollowButton(userId: userId),
                ),
              ],
        title: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: Row(
            children: [
              Text(
                username,
                style: const TextStyle(
                  fontFamily: 'Ubuntu',
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              //if the user is verified, it shows an icon which certifies it
              if (isVerified)
                const Padding(
                  padding: EdgeInsets.only(left: 13, top: 2),
                  child: Icon(
                    Icons.verified,
                    color: electricBlueColor,
                    size: 25,
                  ),
                ),
            ],
          ),
        ));
  }
}

class Stats extends StatelessWidget {
  final String firstText;
  final String secondText;
  const Stats({Key? key, required this.firstText, required this.secondText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 10),
        //RichText is used when some words or parts of the text differ in style
        child: RichText(
          text: TextSpan(
              text: firstText,
              style: const TextStyle(
                  fontFamily: 'Ubuntu',
                  color: electricBlueColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                    text: secondText,
                    style: const TextStyle(
                        fontFamily: 'Ubuntu',
                        letterSpacing: 1.8,
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w400)),
              ]),
        ));
  }
}

//this signout method does not contains logic, as it is all contained in the signOut() from the AuthenticationService.
Future<void> signout(BuildContext context) async {
  //A dialog which asks the user if he is sure to continue is shown
  showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
            title: const Text("Sei sicuro di volere uscire dall'account?"),
            actions: [
              TextButton(
                  onPressed: () async {
                    try {
                      Navigator.of(ctx).pop();
                      await Provider.of<AuthenticationService>(context,
                              listen: false)
                          .signOut();
                    } catch (err) {
                      showCustomSnackbar(context, 'Errore. Riprova');
                    }
                  },
                  child: const Text('Sì')),
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('No'))
            ],
          ));
}
