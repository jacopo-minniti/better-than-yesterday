import 'package:better_than_yesterday/utils/utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:provider/provider.dart';

import '../services/local_notification_service.dart';
import '../services/posts.dart';
import '../services/users.dart';
import '../utils/colors.dart';
import 'pages/home_page.dart';
import 'pages/new_post_page.dart';
import 'pages/profile_page.dart';
import 'pages/search_page.dart';
import 'partecipations_screen.dart';
import 'splash_screen.dart';

// this widget is accessed every time the user opens the app and is logged.
// Here is defined the bottom navigation bar and all the pages are instantiated.
// The bottom navigation bar is from the package persistent_bottom_nav_bar_v2
class PagesController extends StatefulWidget {
  static const routeName = '/pages';
  final Posts posts;
  final Users users;
  const PagesController({Key? key, required this.posts, required this.users})
      : super(key: key);

  @override
  State<PagesController> createState() => _PagesControllerState();
}

class _PagesControllerState extends State<PagesController> {
  late final PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    //the controller for the bottom navigation bar is instantiated. The initial index is 0 (home page)
    _controller = PersistentTabController(initialIndex: 0);

    LocalNotificationService.initialize(context);
    final _firebaseMessaging = FirebaseMessaging.instance;
    //if it is the first time the user authenticates, the onTokenRefresh stream is fired, and thus the method setToken called. In this way, the device token is associated with the corresponding user
    _firebaseMessaging.onTokenRefresh.listen((token) {
      Provider.of<Users>(context, listen: false).setToken(token);
    });
    //The onMessage stream listens to notifications. When a notification is sent to the user, LocalNotificationService.display(message) is executed.
    FirebaseMessaging.onMessage.listen((message) async {
      if (message.notification != null) {
        LocalNotificationService.display(message);
      }
    });
    setupInteractedMessage();
  }

  //if the app is not in the foreground, the notification is not handled by the LocalNotificationService, but by Firebase itself
  Future<void> setupInteractedMessage() async {
    //we get the message
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    //the message is handled
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  //when clicked, the notification brings the user to the Participations screen
  void _handleMessage(RemoteMessage message) {
    final currentUserId = Provider.of<Users>(context, listen: false).userId;
    pushNewScreenWithRouteSettings(context,
        settings: RouteSettings(arguments: [widget.posts, widget.users]),
        screen: MultiProvider(providers: [
          ChangeNotifierProvider.value(value: widget.posts),
          ChangeNotifierProvider.value(value: widget.users),
          // ChangeNotifierProvider(create: create)
        ], child: PartecipationsScreen(currentUserId)));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: FutureBuilder(
      //setUserAndFeed() set the current user and all the main posts feeds of the app
      future: setUserAndFeed(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
                child: Text("Si è verificato un'errore. Riprova più tardi")),
          );
        }
        //PersistentTabView is the actual navigation bar
        return Scaffold(
          appBar: null,
          backgroundColor: Colors.white,
          body: PersistentTabView(
            context,
            controller: _controller, //assign the controller
            screens: pages, //assign all the pages
            items: navigationBar, //the items (i.e. icons and texts)
            handleAndroidBackButtonPress: true,
            resizeToAvoidBottomInset: true,
            stateManagement: true,
            hideNavigationBarWhenKeyboardShows:
                true, //when the keyboard is used, the navigation bar is not shown
            navBarHeight: MediaQuery.of(context).size.height * 0.08,
            decoration:
                NavBarDecoration(borderRadius: BorderRadius.circular(0.0)),
            itemAnimationProperties: const ItemAnimationProperties(
              duration: Duration(milliseconds: 200),
              curve: Curves.ease,
            ),
            //the animation to execute every time the user changes page
            screenTransitionAnimation: const ScreenTransitionAnimation(
              animateTabTransition: true,
              curve: Curves.ease,
              duration: Duration(milliseconds: 200),
            ),
            navBarStyle: NavBarStyle.style15,
            backgroundColor: Colors.white,
          ),
        );
      },
    ));
  }

  //the pages in order
  final pages = <Widget>[
    const HomePage(),
    const SearchPage(),
    const NewPostPage(),
    const Center(
      child: Text('Presto in arrivo...'),
    ),
    const ProfilePage(
      userId: null,
    ),
  ];
  //all the items are just an Icon and a text one above the other. When selected the color of the icon changes to blue
  List<PersistentBottomNavBarItem> get navigationBar => [
        PersistentBottomNavBarItem(
            inactiveIcon: const Icon(
              Icons.home_outlined,
              color: electricBlueColor,
            ),
            icon: const Icon(
              Icons.home_rounded,
              color: electricBlueColor,
            ),
            activeColorPrimary: electricBlueColor,
            inactiveColorPrimary: Colors.white,
            title: 'Home',
            textStyle:
                const TextStyle(fontFamily: 'Ubuntu', letterSpacing: 1.5)),
        PersistentBottomNavBarItem(
            inactiveIcon:
                const Icon(CupertinoIcons.compass, color: electricBlueColor),
            icon: const Icon(CupertinoIcons.compass_fill,
                color: electricBlueColor),
            activeColorPrimary: electricBlueColor,
            inactiveColorPrimary: Colors.white,
            title: 'Esplora',
            textStyle:
                const TextStyle(fontFamily: 'Ubuntu', letterSpacing: 1.5)),
        //In the style 15, the third item is different from the others. It is above the others and circular.
        //This corresponds to the NewPostPage
        PersistentBottomNavBarItem(
          icon: const Icon(
            CupertinoIcons.add,
            color: Colors.white,
          ),
          activeColorPrimary: electricBlueColor,
        ),
        PersistentBottomNavBarItem(
            inactiveIcon:
                const Icon(Icons.message_outlined, color: electricBlueColor),
            icon: const Icon(Icons.message, color: electricBlueColor),
            activeColorPrimary: electricBlueColor,
            inactiveColorPrimary: Colors.white,
            title: 'Messaggi',
            textStyle:
                const TextStyle(fontFamily: 'Ubuntu', letterSpacing: 1.5)),
        PersistentBottomNavBarItem(
          inactiveIcon: const Icon(
            Icons.account_circle_outlined,
            color: electricBlueColor,
          ),
          icon: const Icon(
            Icons.account_circle,
            color: electricBlueColor,
          ),
          activeColorPrimary: electricBlueColor,
          inactiveColorPrimary: Colors.white,
          title: 'Profilo',
          textStyle: const TextStyle(fontFamily: 'Ubuntu', letterSpacing: 1.5),
        )
      ];

  Future<void> setUserAndFeed() async {
    try {
      final currentUser = await Provider.of<Users>(context, listen: false)
          .setAndGetCurrentUser();
      return Provider.of<Posts>(context, listen: false)
          .postsFeed(currentUser.toJson());
    } catch (err) {
      if (mounted) {
        showCustomSnackbar(
            context, "Si è verificato un'errore. Prova a ricaricare l'app.");
      }
    }
  }
}
