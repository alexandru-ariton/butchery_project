import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatelessWidget {
  final File? image;
  final String? photoUrl;
  final Function(XFile?) onImagePicked;

  ImagePickerWidget({this.image, this.photoUrl, required this.onImagePicked});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (image != null)
          Image.file(image!)
        else if (photoUrl != null)
          Image.network(photoUrl!, errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.error);
          })
        else
          Icon(Icons.person, size: 100),
        ElevatedButton(
          onPressed: () async {
            final picker = ImagePicker();
            final pickedFile = await picker.pickImage(source: ImageSource.gallery);
            onImagePicked(pickedFile);
          },
          child: Text('Change Image'),
        ),
      ],
    );
  }
}
