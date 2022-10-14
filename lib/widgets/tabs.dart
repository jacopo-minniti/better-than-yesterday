import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart'
    show pushNewScreen, PageTransitionAnimation;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/post.dart';
import '../services/posts.dart';
import '../services/users.dart';
import '../screens/category_selected_screen.dart';
import '../screens/details_screen.dart';
import '../utils/circle_tab_indicator.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import 'small_post_card.dart';

class Tabs extends StatefulWidget {
  @override
  State<Tabs> createState() => _TabsState();
}

//the logic behind the Tabs class is the same as the one explained in ProfilePostView.
//The Tabs class is used to display trend posts and categories, instead of published and shared posts.
class _TabsState extends State<Tabs> with TickerProviderStateMixin {
  //categoriesImages is the list containing all the references for the images used as thumbnails
  final categoriesImages = [
    'assets/images/manuale.jpg',
    'assets/images/intellettuale.jpg',
    'assets/images/individuale.jpg',
    'assets/images/collaborativo.jpg',
    'assets/images/senzaTetto.jpg',
    'assets/images/ambiente.jpg',
    'assets/images/donne.jpg',
    'assets/images/bambini.jpg',
    'assets/images/famiglie.jpg',
    'assets/images/immigrazione.jpg',
    'assets/images/tossicoDipendeza.jpeg',
    'assets/images/mensaDeiPoveri.jpg',
    'assets/images/doposcuola.jpg',
    'assets/images/consulenza.jpg',
    'assets/images/centroDiAscolto.jpg',
    'assets/images/anziani.jpg',
    'assets/images/diversamenteAbili.jpg',
    'assets/images/comunita.jpg',
    'assets/images/arte.jpg',
    'assets/images/recuperoCitta.jpg',
  ];

  //categories groups all the ids of the filters
  final categories = [
    'f_manuale',
    'f_intellettuale',
    'f_individuale',
    'f_collaborativo',
    'f_senzaTetto',
    'f_ambiente',
    'f_donne',
    'f_bambini',
    'f_famiglie',
    'f_immigrati',
    'f_tossicoDipententi',
    'f_mensaDeiPoveri',
    'f_doposcuola',
    'f_consulenza',
    'f_centroDiAscolto',
    'f_anziani',
    'f_diversamenteAbili',
    'f_comunita',
    'f_attivitaArtistica',
    'f_recuperoCitta',
  ];
  late final List<Post> trendPosts;
  late final double boxHeight;
  late final TabController tabController;
  var _isInit = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      //trend posts are retrieved. They were set together with the other feeds when the app started
      trendPosts = Provider.of<Posts>(context, listen: false).trendPosts;
      boxHeight = MediaQuery.of(context).size.height * 0.35;
      tabController = TabController(length: 2, vsync: this);
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TabBar(
        controller: tabController,
        labelColor: Colors.black,
        isScrollable: true,
        labelPadding: const EdgeInsets.symmetric(horizontal: 50),
        indicator:
            const CircleTabIndicator(color: electricBlueColor, radius: 4),
        indicatorSize: TabBarIndicatorSize.label,
        unselectedLabelColor: Colors.grey,
        overlayColor:
            MaterialStateProperty.all(electricBlueColor.withOpacity(0.2)),
        //the names of the two tabs are Trend and Categories
        tabs: const [Tab(text: 'Trend'), Tab(text: 'Categorie')],
      ),
      Container(
        height: boxHeight,
        width: double.maxFinite,
        padding: const EdgeInsets.only(left: 20),
        child: TabBarView(
          controller: tabController,
          //both ListViews in this case are to be scrolled horizontally
          children: [
            ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: trendPosts.length,
                itemBuilder: ((context, index) {
                  final trendPost = trendPosts[index];
                  //a unique id for the hero animation is defined using an Uuid
                  final heroTag = const Uuid().v1();
                  return SmallPostCard(
                      heroTag: heroTag,
                      action: () async {
                        //if the thumbnail is clicked, the user navigates to the DetailsScreen of the given post
                        final currentUserId =
                            Provider.of<Users>(context, listen: false).userId;
                        pushNewScreen(context,
                            screen: DetailsScreen(
                              currentUserId: currentUserId,
                              post: trendPost,
                              heroTag: heroTag,
                            ),
                            pageTransitionAnimation:
                                PageTransitionAnimation.slideUp);
                      },
                      image: NetworkImage(trendPost.thumbnail),
                      title: trendPost.title);
                })),
            ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: ((context, index) {
                //when clicked the Small Post Card for categories returns a new CategoryScreen, which displays the posts of the given category.
                return SmallPostCard(
                    heroTag: '',
                    action: () => pushNewScreen(context,
                        screen: CategorySelectedScreen(categories[index])),
                    image: AssetImage(categoriesImages[index]),
                    title: createCategoryNameFromString(categories[index]));
              }),
            )
          ],
        ),
      )
    ]);
  }
}
