// Importă funcționalitatea de verificare a platformei web (desktop sau mobil).
import 'package:flutter/foundation.dart' show kIsWeb;

// Importă pachetul principal pentru construirea interfeței de utilizator în Flutter.
import 'package:flutter/material.dart';

// Importă provider-ul de autentificare personalizat.
import 'package:gastrogrid_app/providers/provider_autentificare.dart';

// Importă pagina de autentificare.
import 'package:gastrogrid_app/Autentificare/pagini/pagina_login.dart';

// Importă provider-ul pentru gestionarea stării.
import 'package:provider/provider.dart';

// Importă componentele personalizate pentru buton și textfield.
import '../componente/my_button.dart';
import '../componente/my_textfield.dart';

// Declarația unei clase Flutter pentru widget-ul PaginaInregistrare, care controlează afișarea paginii de înregistrare.
class PaginaInregistrare extends StatefulWidget {
  // Funcție callback opțională pentru comutarea între paginile de login și înregistrare.
  final void Function()? onTap;

  // Constructorul widgetului PaginaInregistrare.
  const PaginaInregistrare({super.key, this.onTap});

  @override
  State<PaginaInregistrare> createState() => _PaginaInregistrareState();
}

// Declarația unei clase de stare pentru widget-ul PaginaInregistrare.
class _PaginaInregistrareState extends State<PaginaInregistrare> {
  // Controler pentru câmpul de text pentru email.
  final TextEditingController emailController = TextEditingController();
  
  // Controler pentru câmpul de text pentru parolă.
  final TextEditingController passwordController = TextEditingController();
  
  // Controler pentru câmpul de text pentru confirmarea parolei.
  final TextEditingController confirmpasswordController = TextEditingController();

  // Mesajul de eroare afișat în caz de eșec la înregistrare.
  String errorMessage = '';

  // Metodă care inițializează starea widgetului. Se apelează când widgetul este creat.
  @override
  void initState() {
    super.initState();
    // Verifică dacă utilizatorul este admin și dacă este pe web
    if (kIsWeb) {
      checkIfAdmin();
    }
  }

  // Metodă asincronă pentru verificarea dacă utilizatorul este admin.
  Future<void> checkIfAdmin() async {
    // Obține instanța provider-ului de autentificare.
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Verifică dacă utilizatorul este în colecția de administratori.
    bool isAdminUser = await authProvider.isUserInCollection(emailController.text, 'admin_users');
    if (isAdminUser) {
      // Setează mesajul de eroare.
      setState(() {
        errorMessage = 'Adminii nu se pot inregistra pe web.';
      });
      // Redirecționează la pagina de autentificare.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PaginaLogin()),
      );
    }
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
              maxWidth: isSmallScreen ? screenSize.width * 0.9 : 400,
            ),
            // Column pentru a aranja widgeturile vertical.
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon pentru a afișa o pictogramă de blocare deschisă.
                Icon(
                  Icons.lock_open_rounded,
                  size: isSmallScreen ? 80 : 100,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                // Adaugă spațiu vertical între elemente.
                const SizedBox(height: 25),
                // Text pentru titlul paginii.
                Text(
                  "Inregistrare",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 24 : 32,
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
                const SizedBox(height: 10),
                // Widget personalizat pentru câmpul de text pentru confirmarea parolei.
                MyTextField(
                  conntroller: confirmpasswordController,
                  hintText: "Confirmare parola",
                  obscureText: true,
                ),
                const SizedBox(height: 25),
                // Widget personalizat pentru butonul de înregistrare.
                MyButton(
                  onTap: () async {
                    // Verifică dacă parola și confirmarea parolei sunt identice.
                    if (passwordController.text == confirmpasswordController.text) {
                      try {
                        // Apelează metoda de înregistrare a provider-ului de autentificare.
                        await Provider.of<AuthProvider>(context, listen: false)
                            .signUp(emailController.text, passwordController.text);
                        // Afișează un mesaj de succes.
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Inregistrare reusita")),
                        );
                        // Redirecționează la pagina de autentificare.
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => PaginaLogin()),
                        );
                      } catch (e) {
                        // Setează mesajul de eroare.
                        setState(() {
                          errorMessage = e.toString();
                        });
                      }
                    } else {
                      // Setează mesajul de eroare dacă parolele nu coincid.
                      setState(() {
                        errorMessage = "Parolele nu coincid";
                      });
                    }
                  },
                  text: "Inregistrare",
                ),
                const SizedBox(height: 15),
                // Text pentru afișarea mesajelor de eroare.
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 25),
                // Gestur pentru a permite navigarea la pagina de autentificare.
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
