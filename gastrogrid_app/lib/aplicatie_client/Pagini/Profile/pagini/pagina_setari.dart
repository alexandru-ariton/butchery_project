import 'package:flutter/material.dart';
import 'package:gastrogrid_app/providers/provider_themes.dart';
import 'package:provider/provider.dart';

class PaginaSetari extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Setări Aplicație'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text('Mod Întunecat', style: TextStyle(fontSize: 16)),
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
            ),
            
          ],
        ),
      ),
    );
  }
}
