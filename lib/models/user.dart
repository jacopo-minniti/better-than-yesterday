import 'package:better_than_yesterday/utils/utils.dart';

class User {
  final int userId;
  final String firebaseUserId;
  final String username;
  final String profilePictureUrl;
  final String location;
  final String bio;
  String? token;
  final int numFollowings;
  final int numFollowers;
  final int numPosts;
  final double latitude;
  final double longitude;
  final bool isVerified;
  final bool f_manuale;
  final bool f_intellettuale;
  final bool f_individuale;
  final bool f_collaborativo;
  final bool f_senzaTetto;
  final bool f_ambiente;
  final bool f_donne;
  final bool f_bambini;
  final bool f_famiglie;
  final bool f_immigrati;
  final bool f_tossicoDipendenti;
  final bool f_mensaDeiPoveri;
  final bool f_doposcuola;
  final bool f_consulenza;
  final bool f_centroDiAscolto;
  final bool f_anziani;
  final bool f_diversamenteAbili;
  final bool f_comunita;
  final bool f_attivitaArtistica;
  final bool f_recuperoCitta;

  User({
    required this.userId,
    required this.firebaseUserId,
    required this.username,
    required this.profilePictureUrl,
    required this.location,
    required this.bio,
    required this.token,
    required this.numFollowings,
    required this.numFollowers,
    required this.numPosts,
    required this.latitude,
    required this.longitude,
    required this.isVerified,
    required this.f_manuale,
    required this.f_intellettuale,
    required this.f_individuale,
    required this.f_collaborativo,
    required this.f_senzaTetto,
    required this.f_ambiente,
    required this.f_donne,
    required this.f_bambini,
    required this.f_famiglie,
    required this.f_immigrati,
    required this.f_tossicoDipendenti,
    required this.f_mensaDeiPoveri,
    required this.f_doposcuola,
    required this.f_consulenza,
    required this.f_centroDiAscolto,
    required this.f_anziani,
    required this.f_diversamenteAbili,
    required this.f_comunita,
    required this.f_attivitaArtistica,
    required this.f_recuperoCitta,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'firebaseUserId': firebaseUserId,
      'username': username,
      'profilePictureUrl': profilePictureUrl,
      'location': location,
      'bio': bio,
      'token': token,
      'numFollowings': numFollowings,
      'numFollowers': numFollowers,
      'numPosts': numPosts,
      'latitude': latitude,
      'longitude': longitude,
      'isVerified': isVerified,
      'f_manuale': f_manuale,
      'f_intellettuale': f_intellettuale,
      'f_individuale': f_individuale,
      'f_collaborativo': f_collaborativo,
      'f_senzaTetto': f_senzaTetto,
      'f_ambiente': f_ambiente,
      'f_donne': f_donne,
      'f_bambini': f_bambini,
      'f_famiglie': f_famiglie,
      'f_immigrati': f_immigrati,
      'f_tossicoDipendenti': f_tossicoDipendenti,
      'f_mensaDeiPoveri': f_mensaDeiPoveri,
      'f_doposcuola': f_doposcuola,
      'f_consulenza': f_consulenza,
      'f_centroDiAscolto': f_centroDiAscolto,
      'f_anziani': f_anziani,
      'f_diversamenteAbili': f_diversamenteAbili,
      'f_comunita': f_comunita,
      'f_attivitaArtistica': f_attivitaArtistica,
      'f_recuperoCitta': f_recuperoCitta,
    };
  }

  static User fromMap(Map<String, dynamic> data) {
    //after being decoded from json, the data map contains only Strings,
    //and therfore some variables needs to be converted
    return User(
      userId: int.parse(data['userId']),
      firebaseUserId: data['firebaseUserId'],
      username: data['username'],
      profilePictureUrl: data['profilePictureUrl'],
      location: data['location'],
      bio: data['bio'],
      token: null,
      numFollowings: int.parse(data['numFollowings']),
      numFollowers: int.parse(data['numFollowers']),
      numPosts: int.parse(data['numPosts']),
      latitude: double.parse(data['latitude']),
      longitude: double.parse(data['longitude']),
      isVerified: fromStringToBool(data['isVerified']),
      f_manuale: fromStringToBool(data['f_manuale']),
      f_intellettuale: fromStringToBool(data['f_intellettuale']),
      f_individuale: fromStringToBool(data['f_individuale']),
      f_collaborativo: fromStringToBool(data['f_collaborativo']),
      f_senzaTetto: fromStringToBool(data['f_senzaTetto']),
      f_ambiente: fromStringToBool(data['f_ambiente']),
      f_donne: fromStringToBool(data['f_donne']),
      f_bambini: fromStringToBool(data['f_bambini']),
      f_famiglie: fromStringToBool(data['f_famiglie']),
      f_immigrati: fromStringToBool(data['f_immigrati']),
      f_tossicoDipendenti: fromStringToBool(data['f_tossicoDipendenti']),
      f_mensaDeiPoveri: fromStringToBool(data['f_mensaDeiPoveri']),
      f_doposcuola: fromStringToBool(data['f_doposcuola']),
      f_consulenza: fromStringToBool(data['f_consulenza']),
      f_centroDiAscolto: fromStringToBool(data['f_centroDiAscolto']),
      f_anziani: fromStringToBool(data['f_anziani']),
      f_diversamenteAbili: fromStringToBool(data['f_diversamenteAbili']),
      f_comunita: fromStringToBool(data['f_comunita']),
      f_attivitaArtistica: fromStringToBool(data['f_attivitaArtistica']),
      f_recuperoCitta: fromStringToBool(data['f_recuperoCitta']),
    );
  }
}
