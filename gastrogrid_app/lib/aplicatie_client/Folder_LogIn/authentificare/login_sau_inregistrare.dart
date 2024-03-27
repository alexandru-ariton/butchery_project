import 'package:flutter/material.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_LogIn/pagina_inregistrare.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_LogIn/pagina_login.dart';

class LoginSauInregistrare extends StatefulWidget {
  const LoginSauInregistrare({super.key});

  @override
  State<LoginSauInregistrare> createState() => _LoginSauInregistrareState();
}

class _LoginSauInregistrareState extends State<LoginSauInregistrare> {

  //afisarea paginii de login

  bool showLoginPage = true;


  //mutarea intre cele 2 pagini
  void schimbarePagini(){
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
      if(showLoginPage) {
        return PaginaLogIn(onTap: schimbarePagini);
      } else {
        return PaginaInregistrare(onTap: schimbarePagini);
      }
  }
}