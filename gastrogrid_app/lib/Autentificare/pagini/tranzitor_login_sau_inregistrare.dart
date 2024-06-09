import 'package:flutter/material.dart';
import 'package:gastrogrid_app/Autentificare/pagini/pagina_inregistrare.dart';
import 'package:gastrogrid_app/Autentificare/pagini/pagina_login.dart';


class LoginSauInregistrare extends StatefulWidget {
  const LoginSauInregistrare({super.key});

  @override
  State<LoginSauInregistrare> createState() => _LoginSauInregistrareState();
}

class _LoginSauInregistrareState extends State<LoginSauInregistrare> {
  bool showLogin = true;

  void toggleView() {
    setState(() {
      showLogin = !showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLogin) {
      return PaginaLogin(onTap: toggleView);
    } else {
      return PaginaInregistrare(onTap: toggleView);
    }
  }
}
