// Importă pachetul principal pentru construirea interfeței de utilizator în Flutter.
import 'package:flutter/material.dart';

// Importă provider-ul pentru gestionarea temelor.
import 'package:gastrogrid_app/providers/provider_themes.dart';

// Importă provider-ul pentru gestionarea stării.
import 'package:provider/provider.dart';

// Definirea unei clase stateless pentru pagina de setări.
class PaginaSetari extends StatelessWidget {
  // Constructorul clasei PaginaSetari.
  const PaginaSetari({super.key});

  // Metodă care construiește interfața de utilizator a widgetului.
  @override
  Widget build(BuildContext context) {
    // Obține instanța provider-ului de teme.
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Returnează un widget Scaffold care conține structura de bază a paginii.
    return Scaffold(
      // AppBar pentru afișarea titlului paginii.
      appBar: AppBar(
        title: Text('Setari aplicatie'),
      ),
      // ListView pentru afișarea opțiunilor de setări.
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Card pentru stilizarea opțiunii de mod întunecat.
          Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            // ListTile pentru afișarea opțiunii de mod întunecat.
            child: ListTile(
              // Pictogramă pentru mod întunecat sau mod luminos.
              leading: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: themeProvider.isDarkMode ? Colors.amber : Colors.blue,
              ),
              // Text pentru titlul opțiunii.
              title: Text(
                'Mod intunecat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              // Switch pentru activarea/dezactivarea modului întunecat.
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  // Comută tema când valoarea switch-ului este schimbată.
                  themeProvider.toggleTheme();
                },
              ),
              // Comportamentul la tap pe ListTile.
              onTap: () {
                // Comută tema când ListTile este tap-uit.
                themeProvider.toggleTheme();
              },
            ),
          ),
        ],
      ),
    );
  }
}
