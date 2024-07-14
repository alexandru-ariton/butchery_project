// Importă pachetul principal pentru construirea UI-ului în Flutter.
import 'package:flutter/material.dart';

// Definirea unei teme pentru modul întunecat (dark mode) folosind ThemeData.
ThemeData darkMode = ThemeData(
  // Definirea schemei de culori pentru tema întunecată.
  colorScheme: ColorScheme.dark(
    // Culoarea de suprafață (background-ul pentru componentele de suprafață).
    surface: Colors.black, // Negru pentru suprafața componentelor UI.
    
    // Culoarea principală (accentul principal al temei).
    primary: Colors.grey, // Gri pentru accentul principal al temei.
    
    // Culoarea secundară (accent secundar, de obicei folosit pentru interacțiuni).
    secondary: Color.fromARGB(45, 241, 241, 241), // Alb transparent pentru accentul secundar.
    
    // Culoarea terțiară (o culoare adițională pentru accent).
    tertiary: const Color.fromARGB(66, 48, 47, 47), // Gri închis transparent pentru accente suplimentare.
    
    // Culoarea inversă principală (de obicei o culoare contrastantă cu cea principală).
    inversePrimary: Colors.grey.shade300, // Gri deschis pentru contraste puternice.
  )
);
