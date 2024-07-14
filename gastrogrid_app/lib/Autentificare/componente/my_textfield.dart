// ignore_for_file: prefer_const_constructors_in_immutables

// Importă pachetul principal pentru construirea interfeței de utilizator în Flutter.
import 'package:flutter/material.dart';

// Definirea unei clase stateless pentru câmpul de text personalizat.
class MyTextField extends StatelessWidget {
  // Declarația unui controler pentru câmpul de text.
  final TextEditingController conntroller;

  // Declarația unui text pentru afișarea hint-ului în câmpul de text.
  final String hintText;

  // Declarația unui bool pentru setarea caracterului de text ascuns (parolă).
  final bool obscureText;

  // Constructorul clasei MyTextField.
  MyTextField({
    super.key, 
    required this.conntroller, 
    required this.hintText, 
    required this.obscureText
  });

  // Metodă care construiește interfața de utilizator a widgetului.
  @override
  Widget build(BuildContext context) {
    // Returnează un widget Padding pentru adăugarea spațiului în jurul câmpului de text.
    return Padding(
      // Setează padding-ul pe orizontală.
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      // Widget TextField pentru afișarea câmpului de text.
      child: TextField(
        // Setează controlerul pentru TextField.
        controller: conntroller,
        // Setează dacă textul este ascuns sau nu.
        obscureText: obscureText,
        // Setează decorația pentru TextField.
        decoration: InputDecoration(
          // Stilizează bordura când TextField nu este focusat.
          enabledBorder: OutlineInputBorder(
            // Setează culoarea bordurii când TextField nu este focusat.
            borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
          ),
          // Stilizează bordura când TextField este focusat.
          focusedBorder: OutlineInputBorder(
            // Setează culoarea bordurii când TextField este focusat.
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          // Setează textul hint în TextField.
          hintText: hintText,
          // Stilizează textul hint în TextField.
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}
