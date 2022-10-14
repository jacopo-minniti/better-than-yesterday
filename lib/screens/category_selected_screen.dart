import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/posts.dart';
import '../services/users.dart';
import '../utils/utils.dart';
import '../widgets/post_list.dart';

class CategorySelectedScreen extends StatefulWidget {
  static const routeName = '/category';
  final String category;
  // ignore: use_key_in_widget_constructors
  const CategorySelectedScreen(this.category);

  @override
  State<CategorySelectedScreen> createState() => _CategorySelectedScreenState();
}

class _CategorySelectedScreenState extends State<CategorySelectedScreen> {
  var _isInit = true;
  Future? future;
  late final String categoryName;
  late final int currentUserId;

  @override
  void initState() {
    super.initState();
    if (_isInit) {
      //the category name is the String actually seen by the user
      categoryName = createCategoryNameFromString(widget.category);
      currentUserId = Provider.of<Users>(context, listen: false).userId;
      final coordinates =
          Provider.of<Users>(context, listen: false).coordinates;
      //set the posts for the given category
      future = Provider.of<Posts>(context, listen: false).categoryFeed({
        'userId': currentUserId,
        'filter': widget.category,
        'latitude': coordinates[0],
        'longitude': coordinates[1]
      });
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
            ),
          ),
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: Colors.white,
          title: Text(
            categoryName,
            style: const TextStyle(
                fontFamily: 'Ubuntu',
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 25),
          ),
        ),
        body: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Color.fromRGBO(47, 86, 226, 1),
                ),
              );
            }
            if (snapshot.hasError) {
              return const Center(
                  child: Text("Si è verificato un'errore. Riprova più tardi"));
            }
            //the feed for this category was set, now we can retrieve the categoryPosts and display them
            final posts =
                Provider.of<Posts>(context, listen: false).categoryPosts;
            return PostList(
              currentUserId: currentUserId,
              posts: posts,
            );
          },
        ));
  }
}
