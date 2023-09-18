import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  const ImageInput({super.key, required this.onGetImage});

  final void Function(File image) onGetImage;

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File? _selectedImage;

  void _takePicture() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _selectedImage = File(pickedImage.path);
      /*  widget.onGetImage(_selectedImage!);*/
    });
  }

  void _pickFromGallery() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _selectedImage = File(pickedImage.path);
      /*   widget.onGetImage(_selectedImage!);*/
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton.icon(
          onPressed: _takePicture,
          icon: const Icon(Icons.camera_alt_outlined),
          label: const Text("Take a picture"),
        ),
        const SizedBox(height: 20.0),
        TextButton.icon(
          onPressed: _pickFromGallery,
          icon: const Icon(Icons.image),
          label: const Text("Pick from gallery"),
        ),
      ],
    );

    if (_selectedImage != null) {
      content = SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _takePicture,
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 300.0,
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onGetImage(_selectedImage!);
              },
              icon: const Icon(Icons.check),
              label: const Text("Ok"),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          alignment: Alignment.center,
          height: double.infinity,
          width: double.infinity,
          child: content,
        ),
      ),
    );
  }
}
