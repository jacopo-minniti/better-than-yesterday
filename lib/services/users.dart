import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:restart_app/restart_app.dart';

import '../models/user.dart' as model;
import '../utils/utils.dart';

class Users with ChangeNotifier {
  //to differentiate between the Firebase User and the model User, the second is imported as model.
  //Here, _currentUser is an istance of the model class User in models folders
  model.User? _currentUser;
  final firebaseUserId = FirebaseAuth.instance.currentUser!.uid;
  final email = FirebaseAuth.instance.currentUser!.email;
  //requestUsers contains every user has made a request to partecipate to a particular post. Every time a new requested post is clicked, this list is empty
  var requestUsers = [];

  //we define some useful getters

  model.User get currentUser => _currentUser!;
  String get username => _currentUser!.username;
  int get userId => _currentUser!.userId;
  String get profilePictureUrl => _currentUser!.profilePictureUrl;
  bool get isVerified => _currentUser!.isVerified;
  List<double> get coordinates =>
      [_currentUser!.latitude, _currentUser!.longitude];

  Future<model.User> setAndGetCurrentUser() async {
    //this method is called when the application is started. It retrieves the user from the users_profile table
    final url =
        Uri.https('YOUR_SITE.com', 'getCurrentUser.php');
    final response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({'firebaseUserId': firebaseUserId}));
    final data = json.decode(response.body);
    //the map of data is converted into a model.User and it is set equal to the _currentUser
    _currentUser = model.User.fromMap(data);
    //this method is both a setter and a getter
    return _currentUser!;
  }

  Future<model.User> getUserById(int userId) async {
    //when the current user clicks on some other user profile,
    //this user is retrieved by simply checking the row of users_profile with the same userId
    final url =
        Uri.https('YOUR_SITE.com', 'getUserById.php');
    final response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({'userId': userId}));
    final data = json.decode(response.body);
    return model.User.fromMap(data);
  }

  Future<void> setToken(String token) async {
    //this method is called only when the user opens the app for the first time or if the user has previously deleted the cache.
    //It simply set the token column for the current user's row in the users_profile table, to be equal to the device token.
    await http.post(
        Uri.https('YOUR_SITE.com', 'setToken.php'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({'firebaseUserId': firebaseUserId, 'token': token}));
  }

  Future<void> setRequestUsers(int postId) async {
    //this methods set the list requestUsers to be equal to all those users who
    // requested partecipation for a particular post published by the current user
    final url =
        Uri.https('YOUR_SITE.com', 'getRequestUsers.php');
    final response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({'postId': postId}));
    requestUsers = json.decode(response.body);
  }

  Future<void> sendNotification(int authorUserId, int postId) async {
    //this method sends a notification to the post owner every time a user requests to partecipate to that post.
    //As explained in the PDF, it makes use of cloud functions. For now this is the only type of notification,
    //but in the near future others will be created (with the same mechanism).
    //For example, every time a user decides to follow another user, a notification will be sent.
    final url = Uri.https('YOUR_SITE.com', 'getToken.php');
    final response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({'userId': authorUserId, 'postId': postId}));
    final data = json.decode(response.body);
    final title = data['title'];
    var token = data['token'];
    final callable = FirebaseFunctions.instanceFor(region: 'europe-west1')
        .httpsCallable('fcm');
    await callable.call(<String, dynamic>{
      'username': username,
      'title': title,
      'token': token,
      'receiverId': '$authorUserId'
    });
  }

  Future<List> deleteAccount() async {
    //delete the current user account on the database.
    //All related tables to users_profile, as users_followers, will be deleted as well,
    //as they are connected to the parent table and DELETE ON CASCADE property is set for the foreign key.
    final url =
        Uri.https('YOUR_SITE.com', 'deleteAccount.php');
    final response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({'userId': userId}));
    final photos = response.body;
    return json.decode(photos) as List;
  }

  Future<void> acceptRequest(
      {required int index, required int postId, required int userId}) async {
    //accept the user's request to partecipate in the selected post
    final url =
        Uri.https('YOUR_SITE.com', 'acceptRequest.php');
    final response = await http.post(url,
        body: json.encode({'postId': postId, 'userId': userId}));
    if (response.body == '1') {
      requestUsers.removeAt(index);
      notifyListeners();
    }
  }

  Future<List> partecipantsAndPhotos(int postId) async {
    //this methods returns a list which contains two other lists.
    //The first contains all the users' profile pictures who partecipate to the post which and are followed by the current user.
    //The second list contains the additional images for the post.
    final url =
        Uri.https('YOUR_SITE.com', 'getPostDetails.php');
    final response = await http.post(url,
        body: json.encode({'postId': postId, 'userId': userId}));
    return json.decode(response.body);
  }

  Future<void> followUser(int userToFollow, bool isFollower) async {
    //it set the variable isFollower, of the table users_followers, to true/false (for follow or unfollow) for the given users.
    final url =
        Uri.https('YOUR_SITE.com', 'followUser.php');
    final response = await http.post(url,
        body: json.encode({
          'userToFollow': userToFollow,
          'userId': userId,
          'isFollower': isFollower
        }));
    if (response.body != '1') {
      throw Exception();
    }
  }

  Future<String?> updateProfile(
      {required Map<String, bool> filters,
      required String? bio,
      required String? location,
      required double latitude,
      required double longitude,
      required String? profilePictureUrl}) async {
    //This method is called when the user clicks the save button in the edit screen. All the data passed is the actual data which can be modified by the user.
    //The interested fields of the current user are updated with the new data
    final url =
        Uri.https('YOUR_SITE.com', 'editUserProfile.php');
    final response = await http.post(url,
        body: json.encode({
          'f_manuale': fromBoolToInt(filters['f_manuale']),
          'f_intellettuale': fromBoolToInt(filters['f_intellettuale']),
          'f_individuale': fromBoolToInt(filters['f_individuale']),
          'f_collaborativo': fromBoolToInt(filters['f_collaborativo']),
          'f_senzaTetto': fromBoolToInt(filters['f_senzaTetto']),
          'f_ambiente': fromBoolToInt(filters['f_ambiente']),
          'f_donne': fromBoolToInt(filters['f_donne']),
          'f_bambini': fromBoolToInt(filters['f_bambini']),
          'f_famiglie': fromBoolToInt(filters['f_famiglie']),
          'f_immigrati': fromBoolToInt(filters['f_immigrati']),
          'f_tossicoDipendenti': fromBoolToInt(filters['f_tossicoDipendenti']),
          'f_mensaDeiPoveri': fromBoolToInt(filters['f_mensaDeiPoveri']),
          'f_doposcuola': fromBoolToInt(filters['f_doposcuola']),
          'f_consulenza': fromBoolToInt(filters['f_consulenza']),
          'f_centroDiAscolto': fromBoolToInt(filters['f_centroDiAscolto']),
          'f_anziani': fromBoolToInt(filters['f_anziani']),
          'f_diversamenteAbili': fromBoolToInt(filters['f_diversamenteAbili']),
          'f_comunita': fromBoolToInt(filters['f_comunita']),
          'f_attivitaArtistica': fromBoolToInt(filters['f_attivitaArtistica']),
          'f_recuperoCitta': fromBoolToInt(filters['f_recuperoCitta']),
          'userId': userId,
          'location': location,
          'latitude': latitude,
          'longitude': longitude,
          'profilePictureUrl': profilePictureUrl,
          'bio': bio
        }));
    if (response.body != '1') {
      return 'Errore. Riprova';
    }
    //app is restarted if query is successful. After restart, all user's posts and the user profile are updated
    Restart.restartApp();
  }
}
