import 'package:flutter/material.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_LogIn/authentificare/auth_provider.dart';
import 'package:gastrogrid_app/aplicatie_client/bara_navigare.dart';
import 'package:provider/provider.dart';
import 'componente/my_button.dart';
import 'componente/my_textfield.dart';

class PaginaLogin extends StatefulWidget {
  final void Function()? onTap;

  const PaginaLogin({super.key, this.onTap});

  @override
  State<PaginaLogin> createState() => _PaginaLoginState();
}

class _PaginaLoginState extends State<PaginaLogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
              Icons.lock_rounded,
              size: 100,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            const SizedBox(height: 25),
            Text(
              "Autentificare",
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
            const SizedBox(height: 25),
            MyButton(
              onTap: () async {
                try {
                  await Provider.of<AuthProvider>(context, listen: false)
                      .login(emailController.text, passwordController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Autentificare reușită")),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => BaraNavigare()), // Redirecționare către BaraNavigare
                  );
                } catch (e) {
                  setState(() {
                    errorMessage = e.toString();
                  });
                }
              },
              text: "Autentificare",
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
                "Nu ai un cont? Înregistrează-te aici",
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
