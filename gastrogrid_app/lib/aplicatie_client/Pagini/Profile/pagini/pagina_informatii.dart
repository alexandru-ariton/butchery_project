import 'package:flutter/material.dart';

class PaginaInformatii extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informații Aplicație'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versiune Aplicație',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('1.0.0'),
            SizedBox(height: 20),
            Text(
              'Dezvoltatori',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Nume Dezvoltator 1'),
            Text('Nume Dezvoltator 2'),
            // Adăugați mai mulți dezvoltatori dacă este necesar
          ],
        ),
      ),
    );
  }
}
