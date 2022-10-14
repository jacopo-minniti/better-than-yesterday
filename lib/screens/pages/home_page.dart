import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart'
    show pushNewScreen;
import 'package:provider/provider.dart';
import '../../services/posts.dart';
import '../../services/users.dart';
import '../../widgets/post_list.dart';
import '../settings_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var currentUserId = 0;
  var posts = [];

  @override
  void initState() {
    super.initState();
    //as we already retrieved from the database the posts and the currentUser,
    //here we onlyhave to call them through hte provider.
    //listen = false, which means that there is no need to update the list when
    //it recieves some kind of change and notifyListener() is called
    currentUserId = Provider.of<Users>(context, listen: false).userId;
    posts = Provider.of<Posts>(context, listen: false).homePosts;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          posts = Provider.of<Posts>(context, listen: false).homePosts;
        });
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          //The app bar simply includes a text a button for settings
          appBar: AppBar(
            backgroundColor: Colors.white,
            toolbarHeight: MediaQuery.of(context).size.height * 0.07,
            elevation: 0.0,
            title: const Text(
              'Better than Yesterday',
              style: TextStyle(
                  fontFamily: 'DarkerGrotesque',
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  letterSpacing: 2),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: IconButton(
                    onPressed: () {
                      final email =
                          Provider.of<Users>(context, listen: false).email;
                      final isVerified =
                          Provider.of<Users>(context, listen: false).isVerified;
                      pushNewScreen(context,
                          screen: SettingsScreen(
                            email: email!,
                            isVerified: isVerified,
                            userId: currentUserId,
                          ));
                    },
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.black,
                      size: 27,
                    )),
              )
            ],
          ),
          //The body is the list of posts
          body: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: PostList(
              currentUserId: currentUserId,
              posts: posts,
            ),
          )),
    );
  }
}
