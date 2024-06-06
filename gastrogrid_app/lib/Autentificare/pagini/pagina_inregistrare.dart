import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:GastroGrid/providers/provider_autentificare.dart';
import 'package:GastroGrid/Autentificare/pagini/pagina_login.dart';
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
  void initState() {
    super.initState();
    // Verifică dacă utilizatorul este admin și dacă este pe web
    if (kIsWeb) {
      checkIfAdmin();
    }
  }

  Future<void> checkIfAdmin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool isAdminUser = await authProvider.isUserInCollection(emailController.text, 'admin_users');
    if (isAdminUser) {
      setState(() {
        errorMessage = 'Adminii nu se pot inregistra pe web.';
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PaginaLogin()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20 : 50),
            constraints: BoxConstraints(
              maxWidth: isSmallScreen ? screenSize.width * 0.9 : 400,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_open_rounded,
                  size: isSmallScreen ? 80 : 100,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                const SizedBox(height: 25),
                Text(
                  "Inregistrare",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 24 : 32,
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
                            .signUp(emailController.text, passwordController.text); // Elimină rolul implicit
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Inregistrare reusita")),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => PaginaLogin()),
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
                  text: "Inregistrare",
                ),
                const SizedBox(height: 15),
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 25),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => PaginaLogin()),
                    );
                  },
                  child: Text(
                    "Ai deja un cont? Autentifica-te aici",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
