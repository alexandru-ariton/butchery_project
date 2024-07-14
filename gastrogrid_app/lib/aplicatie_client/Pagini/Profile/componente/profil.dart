// Importă biblioteca principală Flutter pentru a crea interfețe de utilizator.
import 'package:flutter/material.dart';

// Importă providerul pentru temă.
import 'package:gastrogrid_app/providers/provider_themes.dart';

// Importă pachetul provider pentru gestionarea stării.
import 'package:provider/provider.dart';

// Declarația unei clase stateless pentru opțiunea de profil.
class ProfileOption extends StatelessWidget {
  // Declarația câmpurilor pentru pictogramă, text și funcția de apelare la apăsare.
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  // Constructorul clasei ProfileOption.
  const ProfileOption({
    super.key, 
    required this.icon,
    required this.text,
    required this.onTap,
  });

  // Metodă care construiește interfața de utilizator a widgetului.
  @override
  Widget build(BuildContext context) {
    // Obține tema curentă de la provider.
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        // Setează funcția de apelare la apăsare.
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: themeProvider.themeData.colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Creează un avatar circular pentru pictogramă.
              CircleAvatar(
                backgroundColor: themeProvider.themeData.colorScheme.primary.withOpacity(0.2),
                child: Icon(icon, color: themeProvider.themeData.colorScheme.primary, size: 24),
              ),
              SizedBox(width: 16),
              // Creează un widget Expanded pentru a afișa textul.
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: themeProvider.themeData.colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: themeProvider.themeData.colorScheme.onSurface),
            ],
          ),
        ),
      ),
    );
  }
}
