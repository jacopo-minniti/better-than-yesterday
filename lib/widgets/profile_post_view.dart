import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../services/posts.dart';
import '../services/users.dart';
import '../utils/circle_tab_indicator.dart';
import '../utils/colors.dart';
import 'post_list.dart';

class ProfilePostView extends StatefulWidget {
  //this widget displays the posts published and shared by the given user.
  //Instead of defining two different classes, one for the current user and one for the selected user, this class manages both situations.
  final User user;
  final bool isPersonal;
  const ProfilePostView(
      {Key? key, required this.user, required this.isPersonal})
      : super(key: key);

  @override
  State<ProfilePostView> createState() => _ProfilePostViewState();
}

//_ProfilePostViewState implements TickerProviderStateMixin, which "Provides [Ticker] objects that are configured to only tick while the current tree is enabled".
//This basically means that by changing the _tabIndex, different items are displayed. In our specific case,
//_taIndex = 0 shows the posts publlished by the user, while _tabIndex = 1 shows the posts shared by the user
class _ProfilePostViewState extends State<ProfilePostView>
    with TickerProviderStateMixin {
  var _tabIndex = 0; //default index value is 0
  late final TabController _tabController;
  var currentUserId = 0;
  var _isInit = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2,
        vsync: this); //length is equal to 2 as there are two trees to display
  }

  void changeTab() {
    setState(() {
      //the _tabIndex changes with the _tabController index.
      _tabIndex = _tabController.index;
    });
  }

  Future<void> postsToDisplay() async {
    if (_isInit) {
      //the future is executed only if this is the first time the widget is built.
      //Otherwise, every time we switch tree, a http query to the database woudld be fired
      _isInit = false;
      currentUserId = Provider.of<Users>(context, listen: false).userId;
      if (!widget.isPersonal) {
        //if the posts belongs to the current user, there is no need to call a future,
        //as they are retrieved when the app starts and thus already available in the app state.
        //Instead, if the user is different from the current user, we need to set his personal and shared posts.
        await Provider.of<Posts>(context, listen: false).setUserPosts(
            currentUserId: currentUserId, authorUserId: widget.user.userId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //TabBar is the widget which shows the name of the two trees (Posts and Shared in our case)
        TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          isScrollable: true,
          labelPadding:
              const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
          indicator:
              const CircleTabIndicator(color: electricBlueColor, radius: 4),
          indicatorSize: TabBarIndicatorSize.label,
          unselectedLabelColor: Colors.grey,
          overlayColor:
              MaterialStateProperty.all(electricBlueColor.withOpacity(0.2)),
          onTap: ((index) => changeTab()),
          tabs: const [
            Text('Post'),
            Text('Condivisi'), //shared in italian
          ],
        ),
        FutureBuilder(
          future: postsToDisplay(), //the future is called
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox();
            }
            if (snapshot.hasError) {
              return const Text('Nessun post da visualizzare');
            }

            return Consumer<Posts>(builder: (context, postsProvider, child) {
              //if the user is the current user, we simply retrieve his posts using the Posts provider.
              //Otherwise, we retrieved the just set userPosts and userSharedPosts
              final personalPosts = widget.isPersonal
                  ? postsProvider.personalPosts
                  : postsProvider.userPosts;
              final sharedPosts = widget.isPersonal
                  ? postsProvider.sharedPosts
                  : postsProvider.userSharedPosts;
              //the list of posts for the corresponding index is shown
              return PostList(
                posts: _tabIndex == 0 ? personalPosts : sharedPosts,
                currentUserId: currentUserId,
              );
            });
          },
        )
      ],
    );
  }
}
