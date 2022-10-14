import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../models/comment.dart';

class Comments with ChangeNotifier {
  //this list contains the 50 most relevant comments for a given post. Every time the user changes post, comments are reset.
  var comments = <Comment>[];

  Future<List> setAndGetComments(int postId, int userId) async {
    //this getter and setter simmply retrieves the comments for the post and the corresponding commentStatus (isLiked) for the current user
    try {
      comments = [];
      final url =
          Uri.https('YOUR_SITE.com', 'getComments.php');
      final response = await http.post(url,
          body: json.encode({'postId': postId, 'userId': userId}));
      final data = json.decode(response.body) as List;
      data.forEach((element) {
        comments.add(Comment.fromMap(element));
      });
    } catch (e) {
      print(e.toString());
    } finally {
      return comments;
    }
  }

  Future<void> likeComment(
      {required int commentId,
      required int currentUserId,
      required int postId}) async {
    //it works exactly as likePost in posts.dart, but for comments.
    //This method changes the status of isLiked both locally and on the server
    final commentToUpdate =
        comments.firstWhere((comment) => comment.commentId == commentId);
    final newIsLiked = !commentToUpdate.isLiked;
    commentToUpdate.isLiked = newIsLiked;
    if (newIsLiked) {
      commentToUpdate.likes++;
    } else {
      commentToUpdate.likes--;
    }
    notifyListeners();
    final url =
        Uri.https('YOUR_SITE.com', 'likeComment.php');
    final response = await http.post(url,
        body: json.encode({
          'commentId': commentId,
          'userId': currentUserId,
          'postId': postId
        }));
    if (response.body != 1) {
      commentToUpdate.isLiked = !newIsLiked;
    }
  }

  Future<void> createComment(
      {required int postId,
      required String body,
      required int userId,
      required String username,
      required String profilePictureUrl}) async {
    //this method creates a comment by adding a new row in the comments table with the given data.
    //It also add the comment locally and calls notifyListeners() in this way, the users immediatly sees his just published comment.
    final url =
        Uri.https('YOUR_SITE.com', 'createComment.php');
    final response = await http.post(url,
        body: json.encode({'postId': postId, 'userId': userId, 'body': body}));
    final commentId = response.body;
    comments.insert(
        0,
        Comment.fromMap({
          'postId': '$postId',
          'userId': '$userId',
          'body': body,
          'likes': '0',
          'commentId': '$commentId',
          'username': username,
          'profilePictureUrl': profilePictureUrl,
          'createdAt': DateTime.now().toString()
        }));
    notifyListeners();
  }
}
