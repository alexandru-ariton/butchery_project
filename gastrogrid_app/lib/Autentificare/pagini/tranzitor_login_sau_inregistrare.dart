// Importă pachetul principal pentru construirea UI-ului în Flutter.
import 'package:flutter/material.dart';
// Importă pagina de înregistrare.
import 'package:gastrogrid_app/Autentificare/pagini/pagina_inregistrare.dart';
// Importă pagina de login.
import 'package:gastrogrid_app/Autentificare/pagini/pagina_login.dart';

// Widget stateless care controlează afișarea paginilor de login și înregistrare.
class LoginSauInregistrare extends StatefulWidget {
  const LoginSauInregistrare({super.key});

  @override
  State<LoginSauInregistrare> createState() => _LoginSauInregistrareState();
}

// Starea asociată cu widgetul LoginSauInregistrare.
class _LoginSauInregistrareState extends State<LoginSauInregistrare> {
  // Variabilă privată care controlează afișarea paginii de login sau înregistrare.
  bool showLogin = true;

  // Metodă pentru comutarea între afișarea paginii de login și cea de înregistrare.
  void toggleView() {
    setState(() {
      showLogin = !showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Afișează pagina de login sau înregistrare în funcție de valoarea lui showLogin.
    if (showLogin) {
      return PaginaLogin(onTap: toggleView); // Afișează pagina de login și transmite funcția toggleView.
    } else {
      return PaginaInregistrare(onTap: toggleView); // Afișează pagina de înregistrare și transmite funcția toggleView.
    }
  }
}
