// Importă pachetul principal pentru construirea UI-ului în Flutter.
import 'package:flutter/material.dart';

// Definirea unei teme pentru modul de zi (light mode) folosind ThemeData.
ThemeData lightMode = ThemeData(
  // Definirea schemei de culori pentru tema de zi.
  colorScheme: ColorScheme.light(
    // Culoarea de suprafață (background-ul pentru componentele de suprafață).
    surface: const Color.fromARGB(255, 8, 8, 8), // Un gri închis.
    
    // Culoarea principală (accentul principal al temei).
    primary: Color.fromARGB(0, 251, 251, 251), // Alb complet, dar transparent din cauza canalului alfa 0.
    
    // Culoarea secundară (accent secundar, de obicei folosit pentru interacțiuni).
    secondary: Color.fromARGB(255, 236, 13, 13), // Roșu intens.
    
    // Culoarea terțiară (o culoare adițională pentru accent).
    tertiary: Colors.white, // Alb.
    
    // Culoarea inversă principală (de obicei o culoare contrastantă cu cea principală).
    inversePrimary: const Color.fromARGB(255, 255, 253, 253), // Aproape alb complet.
  )
);
