// Importă pachetul necesar.
import 'package:flutter/material.dart'; // Importă pachetul Flutter Material pentru UI.

// Declarația unui widget stateless pentru afișarea unei secțiuni extensibile.
class ExpandableSection extends StatelessWidget {
  final String title; // Variabilă finală pentru a stoca titlul secțiunii.
  final Widget content; // Variabilă finală pentru a stoca conținutul secțiunii.

  // Constructorul widget-ului.
  const ExpandableSection({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        title, // Titlul secțiunii.
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Stilul textului pentru titlu.
      ),
      children: [content], // Conținutul secțiunii care va fi extins.
    );
  }
}
