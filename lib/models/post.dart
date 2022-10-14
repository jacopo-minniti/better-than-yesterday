//the model used for every post.
//while a post on the database is described by more fields, some of them have no use on the client and would only decrement performances.
//For example, filters are only used to sort posts, and ca not be modified after post creation,
//therefore, there is no need to pass more data than that used.

class Post {
  final int postId;
  final int userId;
  int likes;
  int partecipations;
  int partecipationStatus;
  final String title;
  final String thumbnail;
  String? location;
  final String description;
  String? requirements;
  final String username;
  final String profilePictureUrl;
  final int maxPartecipants;
  final String date;
  bool isLiked;
  bool isShared;

  Post({
    required this.postId,
    required this.userId,
    required this.username,
    required this.profilePictureUrl,
    required this.title,
    required this.description,
    required this.partecipationStatus,
    required this.thumbnail,
    this.requirements,
    required this.date,
    required this.likes,
    required this.isShared,
    required this.maxPartecipants,
    required this.partecipations,
    this.location,
    required this.isLiked,
  });

  static Post fromMap(Map<String, dynamic> data) {
    return Post(
      postId: int.parse(data['postId']),
      userId: int.parse(data['userId']),
      title: data['title'],
      thumbnail: data['thumbnail'],
      location: data['location'],
      description: data['description'],
      requirements: data['requirements'],
      maxPartecipants: int.parse(data['maxPartecipants']),
      date: data['postDate'],
      isLiked: data['isLiked'] == '1' ? true : false,
      isShared: data['isShared'] == '1' ? true : false,
      partecipationStatus: data['partecipationStatus'] != null
          ? int.parse(data['partecipationStatus'])
          : 0,
      likes: int.parse(data['likes']),
      partecipations: int.parse(data['partecipations']),
      username: data['username'],
      profilePictureUrl: data['profilePictureUrl'],
    );
  }
}
