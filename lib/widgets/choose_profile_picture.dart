import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/colors.dart';

class ChooseProfilePicture extends StatefulWidget {
  File? _image;
  ImageProvider
      startingImage; //the image viewed before the user interact with the widget
  Function(File)
      retrieveImage; // a callBack needed to set the screen's image variable equal to the local _image variable defined above
  ChooseProfilePicture(this._image, this.retrieveImage, this.startingImage);

  @override
  State<ChooseProfilePicture> createState() => _ChooseProfilePictureState();
}

class _ChooseProfilePictureState extends State<ChooseProfilePicture> {
  @override
  Widget build(BuildContext context) {
    final imageToDisplay = widget._image == null
        ? widget.startingImage
        : FileImage(widget._image!);
    return SizedBox(
      height: 115,
      width: 115,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          CircleAvatar(
            backgroundImage: imageToDisplay,
            backgroundColor: Colors.white,
          ),
          Positioned(
              bottom: -5,
              right: -25,
              child: RawMaterialButton(
                onPressed: _pickImage,
                elevation: 2.0,
                fillColor: Colors.white,
                child: Icon(
                  widget.startingImage.runtimeType == NetworkImage
                      ? Icons.edit
                      : Icons.add_a_photo,
                  color: darkBlueColor,
                ),
                padding: const EdgeInsets.all(8.0),
                shape: const CircleBorder(),
              )),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    //the logic of the class is contained in this method
    final _picker = ImagePicker(); //object from the image_picker package
    showDialog(
        context: context,
        builder: ((context) => AlertDialog(
              title: const Text('Come vuoi scegliere la foto?'),
              actions: [
                //these two TextButton basically do the same. One is for gallery, the other for when the user chooses the camera
                TextButton(
                    onPressed: () async {
                      final im =
                          await _picker.pickImage(source: ImageSource.gallery);
                      if (im != null) {
                        setState(() {
                          //update the state of the object with the new image
                          widget._image = File(im.path);
                        });
                        widget.retrieveImage(File(im.path));
                      }

                      Navigator.of(context).pop(); //close the Dialog
                    },
                    child: const Text('Galleria')),
                TextButton(
                    onPressed: () async {
                      final im =
                          await _picker.pickImage(source: ImageSource.camera);
                      if (im != null) {
                        setState(() {
                          widget._image = File(im.path);
                        });
                        widget.retrieveImage(File(im.path));
                      }

                      Navigator.of(context).pop();
                    },
                    child: const Text('Fotocamera')),
              ],
            )));
  }
}
