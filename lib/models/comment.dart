//the model used for every comment.

class Comment {
  final int postId; //the postId of the post in which this comment is written
  final int commentId;
  final int userId; //the userId of the author
  final String username;
  final String body;
  final String profilePictureUrl;
  int likes;
  final String createdAt;
  bool isLiked; //true if the current user liked the comment, false otherwise

  Comment(
      {required this.username,
      required this.postId,
      required this.commentId,
      required this.userId,
      required this.body,
      required this.profilePictureUrl,
      required this.createdAt,
      required this.isLiked,
      required this.likes});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'body': body,
      'commentId': commentId,
      'postId': postId,
      'likes': likes,
      'userId': userId,
      'isLiked': isLiked,
      'profilePictureUrl': profilePictureUrl,
      'createdAt': createdAt,
    };
  }

  static Comment fromMap(Map<String, dynamic> data) {
    return Comment(
      //when decoding a json object everything is a String,
      //and so integers need to be converted
      likes: int.parse(data['likes']),
      createdAt: data['createdAt'],
      username: data['username'],
      userId: int.parse(data['userId']),
      profilePictureUrl: data['profilePictureUrl'],
      isLiked: data['isLiked'] == '1' ? true : false,
      commentId: int.parse(data['commentId']),
      postId: int.parse(data['postId']),
      body: data['body'],
    );
  }
}
