import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:uuid/uuid.dart';

class Storage {
  //the storage class contains only static methods to intercat with Firebase Storage Service.
  // While it is inclluded in the services folder, it is not a provider, as it does not store any data.

  static Future<String> uploadProfilePicture(File image, String userId) async {
    //every profile picture is stored in the folder profilePictures.
    //The name of the file is simply the userId of the corresponding user.

    final filePath = image.absolute.path;
    //from the path we remove the extension (.jpeg or .jpg). Then, we create another path called outPath, which will be used by the resized image.
    final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
    //since profile pictures are always visualized ina farily low circle, the quallity does not need to be particularly high to give a good image.
    // Rememebr that 30% does not mean that the resolution of the image is lowered by 70%.
    final imageResized = await FlutterImageCompress.compressAndGetFile(
      filePath,
      outPath,
      quality: 30,
    );
    //the path to which upload the image is created, and the image uploaded.
    final path = 'profilePictures/$userId';
    final reference = FirebaseStorage.instance.ref().child(path);
    final uploadTask = reference.putFile(imageResized!);
    final snapshot = await uploadTask.whenComplete(() => null);
    final url = await snapshot.ref.getDownloadURL();
    //the url is returned, and eventually will be uploaded on the database
    return url;
  }

  static Future<List<String>> uploadPostImages(
      {required List<File?> photos, required String userId}) async {
    //photos is a list containing the thumbnail and the additional images of a post
    var imagesUrl = <String>[];
    for (var photo in photos) {
      //for every image, we basically repeat the process described in the uploadProfilePicture method
      var imageId = const Uuid().v1();
      final path = 'posts/$userId/$imageId';
      final reference = FirebaseStorage.instance.ref().child(path);
      final filePath = photo!.absolute.path;
      final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
      final splitted = filePath.substring(0, (lastIndex));
      final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
      //here the quality of the image is a bit higher as it will be viewed a bigger size
      final resizedPhoto = await FlutterImageCompress.compressAndGetFile(
        filePath,
        outPath,
        quality: 45,
      );
      final uploadTask = reference.putFile(resizedPhoto!);
      final snapshot = await uploadTask.whenComplete(() => null);
      final url = await snapshot.ref.getDownloadURL();
      //the image is added to the empty list declared above
      imagesUrl.add(url);
    }
    //imagesUrl now contains, at index 0, the URL of the thumbnail, and the URL of all the additional images
    return imagesUrl;
  }

  static Future<void> deleteAccount(
      List photos, String profilePictureUrl) async {
    //when the account is deleted, all the images belonging to the user have to be deleted as well.
    //This function first retrieves all the images of the posts using their URLs
    final storage = FirebaseStorage.instance;
    for (var photo in photos) {
      final storageRef = storage.refFromURL(photo['photo']);
      await storageRef.delete();
    }
    //then, it repeates the same process for the profile picture
    final profilePictureRef = storage.refFromURL(profilePictureUrl);
    await profilePictureRef.delete();
  }

  static Future<void> deleteProfilePicture(String userId) async {
    //when the user changes his profile picture, there is no need to store the previous one,
    // and thus it is deleted from the storage
    final pictureRef =
        FirebaseStorage.instance.ref().child('profilePictures/$userId');
    await pictureRef.delete();
  }
}
