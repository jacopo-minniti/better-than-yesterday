import 'dart:convert';

import 'package:better_than_yesterday/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart'
    show pushNewScreen;
import 'package:http/http.dart' as http;

import '../screens/pages/profile_page.dart';

class SearchBar extends StatelessWidget {
  final String username;
  const SearchBar(this.username);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      //When clicked, the Search bar fires the showSearch method, which accepts a SearchDelegate as one argument.
      //SearchDelegate is an abstract class which needs to be extended and Overried to actually produce results.
      onTap: () =>
          showSearch(context: context, delegate: MySearchDelegate(username)),
      child: Container(
        //blur effect to sigmmax/y = 15
        alignment: Alignment.center,
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 177, 174, 174).withAlpha(70),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
                width: 2,
                color: const Color.fromARGB(255, 177, 174, 174).withAlpha(20))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              Icons.search,
              color: Colors.black87,
            ),
            Expanded(child: Container()),
            const Text('Cerca utenti',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Ubuntu',
                    color: Colors.black,
                    fontSize: 17,
                    letterSpacing: 2)),
            Expanded(child: Container())
          ],
        ),
      ),
    );
  }
}

class MySearchDelegate extends SearchDelegate {
  final String username;
  MySearchDelegate(this.username);

  @override
  List<Widget>? buildActions(BuildContext context) => [
        //in buildActions we define some widgets to be displayed next to the search bar.
        //In this case, the list contains just one Widget: an IconButton used to resatart what the user typed.
        IconButton(
            onPressed: () => query = '',
            icon: const Icon(
              Icons.clear,
              color: Colors.black,
            ))
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
      //buildLeading returns a Widget (or null).
      //In most cases, this is simply used to build a back-arrow Icon Button to return to the previous screen. To do so, the search.dart class has a static method called close().
      //Its function is self explanatory
      onPressed: () => close(context, null),
      icon: const Icon(
        Icons.arrow_back,
        color: Colors.black,
      ));

  @override
  Widget buildResults(BuildContext context) {
    //buildResults does not need to be override in our specific case.
    //This is used to show results after the user submitted the what he has typed.
    //The use of buildSuggestions is preffered in our case
    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    //buildSuggestions displays a widget while the user is typing.
    //In our context, here will be displayed a maximum of 6 ListTile
    //corresponding to the users whose username is similar to what the user has typed.
    //searchUsers.php returns the 6 similar usernames, profile pictures and userIds.
    //Returning only the necessary parameters, make the whole process faster.
    if (query != '') {
      Future? future = http.post(
          Uri.https('flutterfirsttry.000webhostapp.com', 'searchUsers.php'),
          body: json.encode({'search': query, 'username': username}));
      return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: electricBlueColor,
              ),
            );
          }
          final response = snapshot.data as http.Response;
          print(response.body);
          final data = json.decode(response.body) as List;
          return ListView.builder(
              itemCount: data.length,
              itemBuilder: ((context, index) => ListTile(
                    onTap: () async {
                      pushNewScreen(
                        context,
                        //the ProfilePage takes as argument the userId.
                        //When the ListTile is passed, the profile of the user is displayed
                        screen: ProfilePage(
                            userId: int.parse(data[index]['userId'])),
                      );
                    },
                    title: Text(data[index]['username']),
                    leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(data[index]['profilePictureUrl'])),
                  )));
        },
      );
    } else {
      return const SizedBox();
    }
  }

  @override
  ThemeData appBarTheme(BuildContext context) => ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(width: 0.001)),
            border: OutlineInputBorder(borderSide: BorderSide(width: 0.001)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(width: 0.001))),
        appBarTheme: const AppBarTheme(
            elevation: 0.0, backgroundColor: Color.fromARGB(31, 137, 136, 136)),
      );
}
