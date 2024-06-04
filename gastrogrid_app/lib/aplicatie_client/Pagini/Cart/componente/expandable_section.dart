import 'package:flutter/material.dart';

class ExpandableSection extends StatelessWidget {
  final String title;
  final Widget content;

  ExpandableSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      children: [content],
    );
  }
}
