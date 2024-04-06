// ignore_for_file: unnecessary_import
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gastrogrid_app/aplicatie_admin/pagina_admin.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_LogIn/componente/my_button.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_LogIn/componente/my_textfield.dart';
import 'package:gastrogrid_app/aplicatie_client/bara_navigare.dart';

class PaginaLogIn extends StatefulWidget {

  final void Function()? onTap;

  const PaginaLogIn({super.key, required this.onTap});

  @override
  State<PaginaLogIn> createState() => _PaginaLogInState();
}

class _PaginaLogInState extends State<PaginaLogIn> {
  //controller-ul pentru editarea text-ului
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  //functia de login
  void login() {




    //navigarea catre pagina de home a clientului
  Navigator.push(
     context,
     MaterialPageRoute(
      builder: (context) =>  AdminPage(),
     ),
  );

  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //logo
            Icon(
              Icons.lock_open_rounded,
              size: 100,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),

            const SizedBox(height: 25),

            //titlul aplicatiei
            Text(
              "Gastro Grid",
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),

            const SizedBox(height: 25),

            //campul text pentru email
            MyTextField(
              conntroller: emailController, 
              hintText: "Email", 
              obscureText: false,
            ),

            const SizedBox(height: 10),

            //campul text pentru parola
             MyTextField(
              conntroller: passwordController, 
              hintText: "Parola", 
              obscureText: true,
            ),

            const SizedBox(height: 10),

            //buton logare
            MyButton(
              text: "Sign In", 
              onTap: login,
            ),

            const SizedBox(height: 10),

            //optiunea de inregistrare
            GestureDetector(
              onTap: widget.onTap,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [ 
                  Text("Inregistreaza-te", 
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}