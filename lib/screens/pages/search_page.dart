import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/posts.dart';
import '../../services/users.dart';
import '../../widgets/post_list.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/tabs.dart';

//search page, or explore page, is where the posts of the explore feed are shown

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    var posts = Provider.of<Posts>(context, listen: false).explorePosts;
    final currentUserId = Provider.of<Users>(context, listen: false).userId;
    final username = Provider.of<Users>(context, listen: false).username;
    return RefreshIndicator(
      onRefresh: () {
        setState(() {});
        return Future.delayed(const Duration(milliseconds: 1));
      },
      child: SingleChildScrollView(
        //it contains, one above the other, the search bar to search for other users,
        //the Tabs to scroll through trend posts and categories, and
        //the actual list of posts
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SearchBar(username),
            Tabs(),
            //a Divider separates the tabs from the posts
            const Padding(
              padding:
                  EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
              child: Divider(
                thickness: 1.2,
                color: Colors.black38,
              ),
            ),
            RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  posts =
                      Provider.of<Posts>(context, listen: false).explorePosts;
                });
              },
              child: PostList(
                currentUserId: currentUserId,
                posts: posts,
              ),
            )
          ],
        ),
      ),
    );
  }
}
