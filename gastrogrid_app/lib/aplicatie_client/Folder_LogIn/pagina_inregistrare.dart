import 'package:flutter/material.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_LogIn/componente/my_button.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_LogIn/componente/my_textfield.dart';


class PaginaInregistrare extends StatefulWidget {

    final void Function()? onTap;

  const PaginaInregistrare({
    super.key, 
    this.onTap
  });

  @override
  State<PaginaInregistrare> createState() => _PaginaInregistrareState();
}



class _PaginaInregistrareState extends State<PaginaInregistrare> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController = TextEditingController();


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
              "Inregistrare",
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

            //campul text pentru confirmare parola
             MyTextField(
              conntroller: confirmpasswordController, 
              hintText: "Confirmare Parola", 
              obscureText: true,
            ),

            const SizedBox(height: 10),

            //buton logare
            MyButton(
              text: "Sign Up", 
              onTap:() {},
            ),

            const SizedBox(height: 10),

            //optiunea de logare
            GestureDetector(
              onTap: widget.onTap,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [ 
                  Text("Logheaza-te", 
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