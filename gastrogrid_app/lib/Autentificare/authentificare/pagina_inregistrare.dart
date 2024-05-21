import 'package:flutter/material.dart';
import 'package:gastrogrid_app/providers/provider_autentificare.dart';
import 'package:gastrogrid_app/Autentificare/authentificare/pagina_login.dart';
import 'package:provider/provider.dart';
import '../componente/my_button.dart';
import '../componente/my_textfield.dart';


class PaginaInregistrare extends StatefulWidget {
  final void Function()? onTap;

  const PaginaInregistrare({super.key, this.onTap});

  @override
  State<PaginaInregistrare> createState() => _PaginaInregistrareState();
}

class _PaginaInregistrareState extends State<PaginaInregistrare> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController = TextEditingController();

  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_open_rounded,
              size: 100,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            const SizedBox(height: 25),
            Text(
              "Inregistrare",
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            const SizedBox(height: 25),
            MyTextField(
              conntroller: emailController,
              hintText: "Email",
              obscureText: false,
            ),
            const SizedBox(height: 10),
            MyTextField(
              conntroller: passwordController,
              hintText: "Parola",
              obscureText: true,
            ),
            const SizedBox(height: 10),
            MyTextField(
              conntroller: confirmpasswordController,
              hintText: "Confirmare Parola",
              obscureText: true,
            ),
            const SizedBox(height: 25),
            MyButton(
              onTap: () async {
                if (passwordController.text == confirmpasswordController.text) {
                  try {
                    await Provider.of<AuthProvider>(context, listen: false)
                        .signUp(emailController.text, passwordController.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Înregistrare reușită")),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => PaginaLogin()), // Redirecționare către pagina principală
                    );
                  } catch (e) {
                    setState(() {
                      errorMessage = e.toString();
                    });
                  }
                } else {
                  setState(() {
                    errorMessage = "Parolele nu coincid";
                  });
                }
              },
              text: "Înregistrare",
            ),
            const SizedBox(height: 15),
            Text(
              errorMessage,
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 25),
            GestureDetector(
              onTap: widget.onTap,
              child: Text(
                "Ai deja un cont? Autentifică-te aici",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
