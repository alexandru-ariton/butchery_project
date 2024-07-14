// Importă biblioteca Dart pentru funcționalități legate de sistemul de fișiere.
import 'dart:io';

// Importă pachetul principal pentru construirea interfeței de utilizator în Flutter.
import 'package:flutter/material.dart';

// Importă biblioteca ImagePicker pentru a selecta imagini.
import 'package:image_picker/image_picker.dart';

// Definirea unei clase stateless pentru widgetul ImagePicker.
class ImagePickerWidget extends StatelessWidget {
  // Declarația variabilelor pentru imagine, URL-ul pozei și funcția de callback pentru selectarea imaginii.
  final File? image;
  final String? photoUrl;
  final Function(XFile?) onImagePicked;

  // Constructorul clasei ImagePickerWidget.
  const ImagePickerWidget({
    super.key, 
    this.image, 
    this.photoUrl, 
    required this.onImagePicked,
  });

  // Metodă care construiește interfața de utilizator a widgetului.
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Verifică dacă există o imagine selectată local.
        if (image != null)
          // Afișează imaginea selectată local.
          Image.file(image!)
        // Verifică dacă există un URL pentru poza de profil.
        else if (photoUrl != null)
          // Afișează imaginea din URL.
          Image.network(photoUrl!, errorBuilder: (context, error, stackTrace) {
            // Afișează o pictogramă de eroare dacă imaginea nu poate fi încărcată.
            return Icon(Icons.error);
          })
        // Afișează o pictogramă implicită dacă nu există o imagine sau un URL.
        else
          Icon(Icons.person, size: 100),

        // Buton pentru schimbarea imaginii.
        ElevatedButton(
          onPressed: () async {
            // Instanțiază un picker pentru imagini.
            final picker = ImagePicker();
            // Așteaptă ca utilizatorul să selecteze o imagine din galerie.
            final pickedFile = await picker.pickImage(source: ImageSource.gallery);
            // Apelează funcția de callback cu imaginea selectată.
            onImagePicked(pickedFile);
          },
          child: Text('Schimba imaginea'),
        ),
      ],
    );
  }
}
