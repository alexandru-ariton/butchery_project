// ignore_for_file: prefer_const_constructors

// Importă pachetul principal pentru construirea interfeței de utilizator în Flutter.
import 'package:flutter/material.dart';

// Definirea unei clase stateless pentru butonul personalizat.
class MyButton extends StatelessWidget {
  // Declarația unei funcții opționale pentru gestiunea tap-urilor pe buton.
  final Function()? onTap;

  // Declarația unui text pentru afișarea pe buton.
  final String text;

  // Constructorul clasei MyButton.
  const MyButton({
    super.key, 
    this.onTap, 
    required this.text,
  });

  // Metodă care construiește interfața de utilizator a widgetului.
  @override
  Widget build(BuildContext context) {
    // Returnează un widget GestureDetector pentru gestiunea tap-urilor.
    return GestureDetector(
      // Setează funcția onTap pentru GestureDetector.
      onTap: onTap,
      // Container pentru stilizarea butonului.
      child: Container(
        // Setează padding-ul intern al containerului.
        padding: const EdgeInsets.all(25),
        // Setează marginile containerului.
        margin: EdgeInsets.symmetric(horizontal: 25),
        // BoxDecoration pentru stilizarea containerului.
        decoration: BoxDecoration(
          // Setează culoarea de fundal a containerului.
          color: Theme.of(context).colorScheme.secondary,
          // Setează bordurile rotunjite ale containerului.
          borderRadius: BorderRadius.circular(8),
        ),
        // Centrarea textului în container.
        child: Center(
          // Widget pentru afișarea textului pe buton.
          child: Text(
            text,
            // Stilizarea textului.
            style: TextStyle(
              // Setează greutatea fontului.
              fontWeight: FontWeight.bold,
              // Setează culoarea textului.
              color: Theme.of(context).colorScheme.inversePrimary,
              // Setează dimensiunea fontului.
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
