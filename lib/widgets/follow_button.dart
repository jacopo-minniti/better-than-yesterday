import 'dart:convert';

import 'package:better_than_yesterday/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../services/users.dart';
import '../utils/colors.dart';

class FollowButton extends StatefulWidget {
  final int userId;
  const FollowButton({Key? key, required this.userId}) : super(key: key);

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  var _isInit = true;
  var _callFuture = true;
  var _isFollower = false;
  Future? future;

  @override
  void initState() {
    super.initState();
    if (_isInit) {
      final currentUserId = Provider.of<Users>(context, listen: false).userId;
      final url =
          Uri.https('flutterfirsttry.000webhostapp.com', 'isFollower.php');
      //checks if the current user already follows the user selected and changes the button style accordingly.
      future = http.post(url,
          body: json.encode({
            'followerUserId': currentUserId,
            'followingUserId': widget.userId
          }));
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        //usual buffering if the future has not resolved yet.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(
            color: electricBlueColor,
          );
        }
        final response = snapshot.data as http.Response;
        if (_callFuture) {
          //this code is executed only once: the first time the button is built. This is done so that,
          //if the current user decides to follow/unfollow the other user, the button does not set the value of the button based on the future, but according to the previous value
          _isFollower = response.body == '1' ? true : false;
        }
        return TextButton(
          onPressed: () async {
            try {
              //when clicked, the user selected becomes a following if _isFollower was false, otherwise is removed from following
              await Provider.of<Users>(context, listen: false)
                  .followUser(widget.userId, _isFollower);
              setState(() {
                _isFollower = !_isFollower;
                _callFuture = false;
              });
            } catch (err) {
              showCustomSnackbar(
                  context, 'Errore di connessione. Riprova più tardi');
            }
          },
          child: Text(
            //text depends on the _isFollower variable
            _isFollower ? 'Non seguire' : 'Segui',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Ubuntu',
                color: electricBlueColor,
                fontWeight: FontWeight.w500,
                letterSpacing: 2,
                fontSize: _isFollower ? 14 : 18),
          ),
        );
      },
    );
  }
}
