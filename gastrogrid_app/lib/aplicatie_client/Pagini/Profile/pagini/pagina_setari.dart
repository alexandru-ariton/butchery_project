import 'package:flutter/material.dart';
import 'package:GastroGrid/providers/provider_themes.dart';
import 'package:provider/provider.dart';

class PaginaSetari extends StatelessWidget {
  const PaginaSetari({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Setări Aplicație'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
              leading: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: themeProvider.isDarkMode ? Colors.amber : Colors.blue,
              ),
              title: Text(
                'Mod Întunecat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
              ),
              onTap: () {
                themeProvider.toggleTheme();
              },
            ),
          ),
         
        ],
      ),
    );
  }
}
