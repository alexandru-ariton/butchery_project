// Importă funcționalitatea de verificare a platformei web (desktop sau mobil).
import 'package:flutter/foundation.dart' show kIsWeb;

// Importă pachetul principal pentru construirea interfeței de utilizator în Flutter.
import 'package:flutter/material.dart';

// Importă pachetul Firestore pentru interacțiunea cu baza de date Firebase.
import 'package:cloud_firestore/cloud_firestore.dart';

// Importă pagina principală de acasă pentru administratori.
import 'package:gastrogrid_app/aplicatie_admin/Pagini/Home/pagina_home.dart';

// Importă provider-ul de autentificare personalizat.
import 'package:gastrogrid_app/providers/provider_autentificare.dart' as customAuth;

// Importă bara de navigare pentru utilizatorii clienți.
import 'package:gastrogrid_app/aplicatie_client/Pagini/Navigation/bara_navigare.dart';

// Importă provider-ul pentru gestionarea stării.
import 'package:provider/provider.dart';

// Importă componentele customizate pentru buton și textfield.
import '../componente/my_button.dart';
import '../componente/my_textfield.dart';

// Importă pagina de înregistrare.
import 'pagina_inregistrare.dart';

// Declarația unei clase Flutter pentru widget-ul PaginaLogin, care controlează afișarea paginii de autentificare.
class PaginaLogin extends StatefulWidget {
  // Funcție callback opțională pentru comutarea între paginile de login și înregistrare.
  final void Function()? onTap;

  // Constructorul widgetului PaginaLogin.
  const PaginaLogin({super.key, this.onTap});

  @override
  State<PaginaLogin> createState() => _PaginaLoginState();
}

// Declarația unei clase de stare pentru widget-ul PaginaLogin.
class _PaginaLoginState extends State<PaginaLogin> {
  // Controler pentru câmpul de text pentru email.
  final TextEditingController emailController = TextEditingController();
  
  // Controler pentru câmpul de text pentru parolă.
  final TextEditingController passwordController = TextEditingController();

  // Mesajul de eroare afișat în caz de eșec la autentificare.
  String errorMessage = '';

  // Metodă care inițializează starea widgetului. Se apelează când widgetul este creat.
  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn(); // Verifică dacă utilizatorul este deja autentificat.
  }

  // Metodă asincronă pentru verificarea autentificării utilizatorului.
  Future<void> _checkIfLoggedIn() async {
    bool isLoggedIn = await Provider.of<customAuth.AuthProvider>(context, listen: false).isLoggedIn();
    if (isLoggedIn) {
      await Provider.of<customAuth.AuthProvider>(context, listen: false).logout(context);
    }
  }

  // Metodă asincronă pentru verificarea existenței utilizatorului în baza de date.
  Future<bool> userExists(String email) async {
    // Caută în colecția 'users' dacă există un document cu email-ul specificat.
    final userQuerySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    // Caută în colecția 'admin_users' dacă există un document cu email-ul specificat.
    final adminQuerySnapshot = await FirebaseFirestore.instance
        .collection('admin_users')
        .where('email', isEqualTo: email)
        .get();

    // Returnează true dacă există un document în oricare dintre cele două colecții.
    return userQuerySnapshot.docs.isNotEmpty || adminQuerySnapshot.docs.isNotEmpty;
  }

  // Metodă care construiește interfața de utilizator a widgetului.
  @override
  Widget build(BuildContext context) {
    // Obține dimensiunea ecranului curent.
    final screenSize = MediaQuery.of(context).size;
    // Verifică dacă ecranul este mic (latime mai mică de 600 pixeli).
    final isSmallScreen = screenSize.width < 600;

    // Returnează un widget Scaffold care conține structura de bază a paginii.
    return Scaffold(
      // Setează culoarea de fundal a paginii.
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        // Widget pentru a permite derularea conținutului dacă ecranul este prea mic.
        child: SingleChildScrollView(
          // Container pentru a adăuga padding și constrângeri de dimensiune.
          child: Container(
            // Adaugă padding pe orizontală în funcție de dimensiunea ecranului.
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20 : 50),
            // Setează lățimea maximă a containerului.
            constraints: BoxConstraints(
              maxWidth: kIsWeb ? 600 : (isSmallScreen ? screenSize.width * 0.9 : 400),
            ),
            // Column pentru a aranja widgeturile vertical.
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon pentru a afișa o pictogramă de blocare.
                Icon(
                  Icons.lock_rounded,
                  size: kIsWeb ? 120 : (isSmallScreen ? 80 : 100),
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                // Adaugă spațiu vertical între elemente.
                const SizedBox(height: 25),
                // Text pentru titlul paginii.
                Text(
                  "Autentificare",
                  style: TextStyle(
                    fontSize: kIsWeb ? 32 : (isSmallScreen ? 24 : 32),
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                const SizedBox(height: 25),
                // Widget personalizat pentru câmpul de text pentru email.
                MyTextField(
                  conntroller: emailController,
                  hintText: "Email",
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                // Widget personalizat pentru câmpul de text pentru parolă.
                MyTextField(
                  conntroller: passwordController,
                  hintText: "Parola",
                  obscureText: true,
                ),
                const SizedBox(height: 25),
                // Widget personalizat pentru butonul de autentificare.
                MyButton(
                  onTap: () async {
                    try {
                      // Obține textul introdus în câmpurile de email și parolă.
                      String email = emailController.text;
                      String password = passwordController.text;

                      // Verifică dacă utilizatorul există în baza de date.
                      bool exists = await userExists(email);
                      if (!exists) {
                        setState(() {
                          errorMessage = 'Utilizatorul nu exista.';
                        });
                        return;
                      }

                      // Verifică dacă utilizatorul este admin.
                      bool isAdminUser = await Provider.of<customAuth.AuthProvider>(context, listen: false)
                          .isUserInCollection(email, 'admin_users');

                      // Autentifică utilizatorul.
                      await Provider.of<customAuth.AuthProvider>(context, listen: false)
                          .login(email, password);

                      // Verifică platforma și tipul de utilizator pentru a permite sau nu autentificarea.
                      if (isAdminUser && !kIsWeb) {
                        setState(() {
                          errorMessage = 'Adminii nu se pot inregistra pe telefon.';
                        });
                        await Provider.of<customAuth.AuthProvider>(context, listen: false).logout(context);
                      } else if (!isAdminUser && kIsWeb) {
                        setState(() {
                          errorMessage = 'Userii nu se pot inregistra pe web.';
                        });
                        await Provider.of<customAuth.AuthProvider>(context, listen: false).logout(context);
                      } else if (isAdminUser) {
                        // Navighează la pagina de acasă pentru administratori.
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => AdminHome()),
                        );
                      } else {
                        // Afișează un mesaj de succes și navighează la bara de navigare pentru utilizatori.
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Autentificare reusita")),
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
                // Text pentru afișarea mesajelor de eroare.
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 25),
                // Gestur pentru a permite navigarea la pagina de înregistrare.
                GestureDetector(
                  onTap: () {
                    if (!kIsWeb) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PaginaInregistrare()),
                      );
                    }
                  },
                  child: Text(
                    kIsWeb ? "" : "Nu ai un cont? Inregistreaza-te aici",
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
