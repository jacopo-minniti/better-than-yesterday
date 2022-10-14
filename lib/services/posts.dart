import 'dart:async';
import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../models/post.dart';

class Posts with ChangeNotifier {
  final storage = FirebaseStorage.instance;

  //all the different lists, which correspond to the different feeds, are defined below
  //the posts for the home page.
  List<Post> homePosts = [];
  //the posts for the explore page.
  List<Post> explorePosts = [];
  //the posts published by the user currently logged
  List<Post> personalPosts = [];
  //the posts shared by the user currently logged
  List<Post> sharedPosts = [];
  //the posts for the category selected. This list will be empty when the user selects another category.
  List<Post> categoryPosts = [];
  //the posts published by the user selected. This list will be empty when the current user closes the profile page of the previouslly selected user.
  List<Post> userPosts = [];
  //the posts shared by the user selected. This list will be empty when the current user closes the profile page of the previouslly selected user.
  List<Post> userSharedPosts = [];
  //the ten most trending posts.
  List<Post> trendPosts = [];
  //this list simply groupes all posts. This is not a deep copy, which means that no duplicates are created. It simply contains the references to all the posts which are currently loaded in the state of the app.
  List<Post> allPosts = [];
  Post? trendPostSelected;

  Future<bool> createPost(Map<String, dynamic> data) async {
    //the data map contains all the information needed to create a new record on the mysql table posts, in which all posts are contained.
    final url =
        Uri.https('YOUR_SITE.com', 'createPost.php');
    try {
      //it returns a bool; if the query was successfull returns true, otherwise false
      final response = await http.post(url, body: json.encode(data));
      if (response.statusCode == 200 && json.decode(response.body) == 1) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> deletePost(int postId) async {
    //delete a post from the database and all the corresponding images from the storage.
    //All related rows in the tables posts_status and posts_photos
    //are automatically deleted as their foreign keys are defined withe the ON DELETE CASCADE property

    //Mysql
    final url =
        Uri.https('YOUR_SITE.com', 'deletePost.php');
    final response =
        await http.post(url, body: json.encode({'postId': postId}));
    //before deleting the related photos, deletePost.php effectuate a query which retrieves and returns them
    final photos = json.decode(response.body) as List;
    //Storage
    for (var photo in photos) {
      //every photo is a link. Thanks to the refFromUrl method in firebase_storage, it is possible to obtain the reference of the file form the URL.
      // malicious uses of this method to read the data contained in the storage, ad hoc security rules are defined on the back-end
      final storageRef = storage.refFromURL(photo['photo']);
      await storageRef.delete();
    }
  }

  Future<Post?> getPostById(int postId, int currentUserId) async {
    //it uses the postId and the currentUserId to find the post and the associated postStatus from the table posts_status (table which contains information about likes, participations ecc)
    final url =
        Uri.https('YOUR_SITE.com', 'getPostById.php');
    final response = await http.post(url,
        body: json.encode({'userId': currentUserId, 'postId': postId}));
    final data = json.decode(response.body);
    try {
      //the map of data is converted into a Post
      //and added to the allPosts list
      final post = Post.fromMap(data);
      allPosts.add(post);
      return post;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Iterable<Post> searchPosts(int postId) {
    //it searches all the posts with the same postId.
    //In fact, it is possible that the same post is visualized in more pages.
    // In that case we have to make sure that an action on one post, is trasmitted to all posts with the same id
    final postsToUpdate = allPosts.where((element) => element.postId == postId);
    return postsToUpdate;
  }

  Future<void> likePost({
    required int postId,
    required int currentUserId,
  }) async {
    //this method first changes the isLiked property for the interested posts, then increment/decrement the likes counter,
    //and finally it updates the posts_status table, at the corresponding row, with the new value of isLiked.
    //If the row with the combination of postId and currentUserId does not exist, it is created and isLiked is set to true.
    final postsToUpdate = searchPosts(postId);
    final newIsLiked = !postsToUpdate.first.isLiked;
    postsToUpdate.forEach((post) {
      post.isLiked = newIsLiked;
      if (newIsLiked) {
        post.likes++;
      } else {
        post.likes--;
      }
    });
    notifyListeners();
    final url = Uri.https('YOUR_SITE.com', 'likePost.php');
    final response = await http.post(url,
        body: json.encode({'userId': currentUserId, 'postId': postId}));
    if (response.body != '1') {
      final postsToUpdate = searchPosts(postId);
      postsToUpdate.forEach((post) {
        post.isLiked = !post.isLiked;
      });
      notifyListeners();
    }
  }

  Future<void> sharePost({
    required int postId,
    required int currentUserId,
  }) async {
    //this method first changes the isShared property for the interested posts, then add/remove the post from the sharedPosts list,
    //and finally it updates the posts_status table, at the corresponding row, with the new value of isShared.
    //If the row with the combination of postId and currentUserId does not exist, it is created and isShared is set to true.
    final postsToUpdate = searchPosts(postId);
    final isShared = !postsToUpdate.first.isShared;
    postsToUpdate.forEach((post) {
      post.isShared = !post.isShared;
    });

    if (isShared) {
      sharedPosts.insert(0, postsToUpdate.first);
    } else {
      sharedPosts.removeWhere((post) => post.postId == postId);
    }

    notifyListeners();
    final url = Uri.https('YOUR_SITE.com', 'sharePost.php');
    final response = await http.post(url,
        body: json.encode({'userId': currentUserId, 'postId': postId}));
    if (response.body != '1') {
      final postsToUpdate = searchPosts(postId);
      postsToUpdate.forEach((post) {
        post.isShared = !post.isShared;
      });
      notifyListeners();
    }
  }

  Future<int?> partecipate({
    required int postId,
    required int currentUserId,
  }) async {
    //remember that participationStatus is equal to 0,
    // if the user is no interested to partecipate,
    // to 1 if the user requested to participate, to 2 if the user was accepted

    //this method first changes the participationStatus property to be equal to 0/1.
    //Then it updates the posts_status table, at the corresponding row, with the new value of participationStatus.
    //If the row with the combination of postId and currentUserId does not exist, it is created and participationStatus is set to 1.
    final postsToUpdate = searchPosts(postId);
    final newPartecipationStatus =
        postsToUpdate.first.partecipationStatus == 0 ? 1 : 0;

    postsToUpdate.forEach((post) {
      post.partecipationStatus = newPartecipationStatus;
    });
    notifyListeners();
    final url =
        Uri.https('YOUR_SITE.com', 'partecipatePost.php');
    await http.post(url,
        body: json.encode({
          'userId': currentUserId,
          'postId': postId,
          'partecipationStatus': newPartecipationStatus
        }));
    if (newPartecipationStatus == 1) {
      //if the user ha requested participation, the userId of the author of the post is returned as it will be used to send the notification.
      return postsToUpdate.first.userId;
    }
    return null;
  }

  Future<void> postsFeed(Map<String, dynamic> body) async {
    //this method is called when the app is started. It returns all the posts for the different feeds.
    //Instead of establishing multiple connections, we maintain a persistent connection across multiple requests to the same server using http.Client()
    final client = http.Client();
    try {
      //the postRequest method defined below, takes as paramaters the client, a php file, and the body. In most cases, only the userId is needed.
      final personalPostsResponse = await postRequest(
          client, 'userProfileFeed.php', {'userId': body['userId']});
      final personalPostsData = json.decode(personalPostsResponse.body) as List;

      final sharedPostResponse = await postRequest(
          client, 'sharedPostsFeed.php', {'userId': body['userId']});
      final sharedPostsData = json.decode(sharedPostResponse.body) as List;

      final homePostResponse = await postRequest(
          client, 'homePostsFeed.php', {'userId': body['userId']});
      final homePostsData = json.decode(homePostResponse.body) as List;

      final explorePostResponse =
          await postRequest(client, 'explorePostsFeed.php', body);
      final explorePostsData = json.decode(explorePostResponse.body) as List;

      final trendPostResponse = await postRequest(
          client, 'trendPostsFeed.php', {'userId': body['userId']});
      final trenPostsData = json.decode(trendPostResponse.body) as List;

      //by calculating the length of the various responsed, we can use a single for loop instead of one for each list

      final personalPostsLength = personalPostsData.length;
      final sharedPostsLength = sharedPostsData.length;
      final homePostsLength = homePostsData.length;
      final explorePostsLength = explorePostsData.length;
      final trendPostsLength = trenPostsData.length;
      for (var i = 0; i < 90; i++) {
        if (personalPostsLength > i) {
          personalPosts.add(Post.fromMap(personalPostsData[i]));
        }
        if (sharedPostsLength > i) {
          sharedPosts.add(Post.fromMap(sharedPostsData[i]));
        }
        if (homePostsLength > i) {
          homePosts.add(Post.fromMap(homePostsData[i]));
        }
        if (explorePostsLength > i) {
          explorePosts.add(Post.fromMap(explorePostsData[i]));
        }
        if (trendPostsLength > i) {
          trendPosts.add(Post.fromMap(trenPostsData[i]));
        }
      }

      //we add the 5 main feeds to allPosts

      allPosts.addAll(personalPosts);
      allPosts.addAll(sharedPosts);
      allPosts.addAll(homePosts);
      allPosts.addAll(explorePosts);
      allPosts.addAll(trendPosts);
    } finally {
      //connection is always closed, even when an error occurs.
      client.close();
    }
  }

  Future<void> setUserPosts(
      {required int currentUserId, required int authorUserId}) async {
    //all the operations of postsFeed() are repeated, just for different feeds.
    //setUserPosts is called every time the user clicks on some user profile.
    //The published and shared posts of that users are contained respectively in userPosts and userSharedPosts
    final client = http.Client();
    try {
      final selectedUserPostsResponse = await postRequest(
          client,
          'selectedUserProfileFeed.php',
          {'userId': currentUserId, 'authorUserId': authorUserId});

      final data = json.decode(selectedUserPostsResponse.body) as List;
      final selectedUserPostsData = data[0] as List;
      final sharedPostsData = data[1] as List;

      final selectedUserPostsLength = selectedUserPostsData.length;
      final sharedPostsLength = sharedPostsData.length;
      //userPosts and userSharePosts are always empty.
      userPosts = [];
      userSharedPosts = [];
      for (var i = 0; i < 90; i++) {
        if (selectedUserPostsLength > i) {
          userPosts.add(Post.fromMap(selectedUserPostsData[i]));
        }
        if (sharedPostsLength > i) {
          userSharedPosts.add(Post.fromMap(sharedPostsData[i]));
        }
      }
      allPosts.addAll(userPosts);
      allPosts.addAll(userSharedPosts);
    } finally {
      client.close();
    }
  }

  Future<List> getPartecipationsAndRequests(int currentUserId) async {
    //this method returns a list containing all the posts to which the user requested to partecipate or already partecipate, and the user's posts to chich at least one user requested partecipation
    final url = Uri.https('YOUR_SITE.com',
        'getPartecipationsAndRequests.php');
    final response = await http.post(url,
        body: json.encode({
          'userId': currentUserId,
        }));
    return json.decode(response.body);
  }

  Future<void> categoryFeed(Map<String, dynamic> body) async {
    //this method is called whenever the user clicks on a category card.
    //the body parameters contains all the data needed by the query on server side
    categoryPosts = [];
    final url =
        Uri.https('YOUR_SITE.com', 'categoryPostsFeed.php');
    try {
      final response = await http.post(url, body: json.encode(body));
      final categoryPostsData = json.decode(response.body) as List;
      categoryPostsData.forEach((post) {
        categoryPosts.add(Post.fromMap(post));
      });
      allPosts.addAll(categoryPosts);
    } catch (e) {}
  }

  Future<Response> postRequest(
      Client client, String file, Map<String, dynamic> body) {
    return client.post(Uri.https('YOUR_SITE.com', file),
        headers: {"Content-Type": "application/json"}, body: json.encode(body));
  }
}
