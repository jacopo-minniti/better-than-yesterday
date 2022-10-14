import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import './screens/authentication/user_information_screen.dart';
import './screens/authentication/verify_screen.dart';

import 'services/authentication__service.dart';
import 'services/comments.dart';
import 'services/posts.dart';
import 'services/users.dart';
import 'screens/authentication/authenticate_user_screen.dart';
import 'screens/pages_controller.dart';
import 'screens/splash_screen.dart';

class AuthenticationStream extends StatefulWidget {
  //this is the first Stateful Widget of the app
  const AuthenticationStream({Key? key}) : super(key: key);

  @override
  State<AuthenticationStream> createState() => _AuthenticationStreamState();
}

class _AuthenticationStreamState extends State<AuthenticationStream> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationService>(
      //we immediatly use the provider instantiate above
      builder: (ctx, AuthenticationService auth, _) {
        switch (auth.status) {
          //depending on the status of the app, the switch case returns the appropriate screen
          case Status.uninitialized:
            return const SplashScreen(); // a white screen with the logo of the app centered. Used as a loading screen.
          case Status.unauthenticated:
          case Status.authenticating:
            return const AuthenticateUserScreen(); //if the authentication token has expired, the AuthenticateUserScreen is shown
          case Status.noVerification:
            return const VerifyScreen(); //the user created the account on firebase but still did not verify its email
          case Status.authenticated:
            return FutureBuilder(
              future: userExist(auth.user!
                  .uid), //userExists(String uid) returns true if uid is found in the tablel users_profiles of the database. Otherwise, false
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SplashScreen();
                }
                final userExist = snapshot.data as bool;
                if (userExist) {
                  final posts = Posts();
                  final users = Users();
                  return MultiProvider(providers: [
                    //the providers will be used for the whole (authenticated part) of the aplication, as their necessary for posts and current user and used basically in every screen
                    //posts and users are passed as arguments in PagesController as they are needed again in case the user open the app from a notification.
                    ChangeNotifierProvider(create: (context) => posts),
                    ChangeNotifierProvider(create: (context) => users),
                    ChangeNotifierProvider(create: (context) => Comments()),
                  ], child: PagesController(posts: posts, users: users));
                } else {
                  return const UserInformationScreen(); //in this screen, after having created his Firebase Account and verified its email, the user has to create the user profile on the database. Every user profile is stored in the users_profile database.
                }
              },
            );
        }
      },
    );
  }

  Future<bool> userExist(String firebaseUserId) async {
    final url = Uri.https('YOUR_SITE.com', 'userExist.php');
    try {
      final response = await http.post(url,
          body: json.encode({'firebaseUserId': firebaseUserId}));
      final userExist = json.decode(response.body);
      return userExist == 1 ? true : false;
    } catch (e) {
      print(e.toString() + 'wwwwwwwwwwwwwwwwwwww');
      return false;
    }
  }
}
