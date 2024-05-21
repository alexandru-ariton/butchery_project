import 'package:flutter/material.dart';
import 'package:gastrogrid_app/providers/theme_provider.dart';
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
              title: Text('Mod Întunecat', style: TextStyle(fontSize: themeProvider.textSize)),
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
            ),
            SizedBox(height: 20),
            Text(
              'Limbă',
              style: TextStyle(fontSize: themeProvider.textSize, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: themeProvider.selectedLanguage,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  themeProvider.changeLanguage(newValue);
                }
              },
              items: <String>['English', 'Română']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(fontSize: themeProvider.textSize)),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text(
              'Dimensiune text',
              style: TextStyle(fontSize: themeProvider.textSize, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: themeProvider.textSize,
              min: 12.0,
              max: 24.0,
              divisions: 6,
              label: themeProvider.textSize.toString(),
              onChanged: (double newValue) {
                themeProvider.changeTextSize(newValue);
              },
            ),
            SizedBox(height: 20),
            SwitchListTile(
              title: Text('Notificări', style: TextStyle(fontSize: themeProvider.textSize)),
              value: themeProvider.notificationsEnabled,
              onChanged: (value) {
                themeProvider.toggleNotifications();
              },
            ),
          ],
        ),
      ),
    );
  }
}
