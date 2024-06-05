import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:GastroGrid/aplicatie_admin/Pagini/Home/pagina_home.dart';
import 'package:GastroGrid/providers/provider_autentificare.dart' as customAuth;
import 'package:GastroGrid/aplicatie_client/Pagini/Navigation/bara_navigare.dart';
import 'package:provider/provider.dart';
import '../componente/my_button.dart';
import '../componente/my_textfield.dart';
import 'pagina_inregistrare.dart';

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

  Future<bool> userExists(String email) async {
    final userQuerySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    final adminQuerySnapshot = await FirebaseFirestore.instance
        .collection('admin_users')
        .where('email', isEqualTo: email)
        .get();

    return userQuerySnapshot.docs.isNotEmpty || adminQuerySnapshot.docs.isNotEmpty;
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
              maxWidth: kIsWeb ? 600 : (isSmallScreen ? screenSize.width * 0.9 : 400),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_rounded,
                  size: kIsWeb ? 120 : (isSmallScreen ? 80 : 100),
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                const SizedBox(height: 25),
                Text(
                  "Autentificare",
                  style: TextStyle(
                    fontSize: kIsWeb ? 32 : (isSmallScreen ? 24 : 32),
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
                      String email = emailController.text;
                      String password = passwordController.text;

                      bool exists = await userExists(email);
                      if (!exists) {
                        setState(() {
                          errorMessage = 'Utilizatorul nu există.';
                        });
                        return;
                      }

                      bool isAdminUser = await Provider.of<customAuth.AuthProvider>(context, listen: false)
                          .isUserInCollection(email, 'admin_users');

                      await Provider.of<customAuth.AuthProvider>(context, listen: false)
                          .login(email, password);

                      if (isAdminUser && !kIsWeb) {
                        // Admin trying to log in on mobile
                        setState(() {
                          errorMessage = 'Admin login is not allowed on mobile devices.';
                        });
                        await Provider.of<customAuth.AuthProvider>(context, listen: false).logout(context);
                      } else if (!isAdminUser && kIsWeb) {
                        // User trying to log in on web
                        setState(() {
                          errorMessage = 'User login is not allowed on web.';
                        });
                        await Provider.of<customAuth.AuthProvider>(context, listen: false).logout(context);
                      } else if (isAdminUser) {
                        // Navigate to AdminPage if the user is an admin
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => AdminHome()),
                        );
                      } else {
                        // Regular user login
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Autentificare reușită")),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => BaraNavigare()),
                        );
                      }
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
                  onTap: () {
                    // Do not show registration page link for admin
                    if (!kIsWeb) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PaginaInregistrare()),
                      );
                    }
                  },
                  child: Text(
                    kIsWeb ? "" : "Nu ai un cont? Înregistrează-te aici",
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
