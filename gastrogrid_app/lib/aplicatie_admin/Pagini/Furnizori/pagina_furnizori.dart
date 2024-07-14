import 'package:flutter/material.dart'; // Importă biblioteca principală Flutter pentru utilizarea widget-urilor.
import 'package:cloud_firestore/cloud_firestore.dart'; // Importă biblioteca Cloud Firestore pentru accesul la baza de date Firestore.

class SupplierManagementPage extends StatefulWidget {
  const SupplierManagementPage({super.key}); // Constructorul clasei, care folosește o cheie opțională.

  @override
  _SupplierManagementPageState createState() => _SupplierManagementPageState(); // Creează starea pentru widget-ul de management al furnizorilor.
}

class _SupplierManagementPageState extends State<SupplierManagementPage> {
  final TextEditingController _nameController = TextEditingController(); // Controller pentru câmpul de text al numelui furnizorului.
  final TextEditingController _emailController = TextEditingController(); // Controller pentru câmpul de text al emailului furnizorului.

  Future<void> _addSupplier() async {
    if (_nameController.text.isNotEmpty && _emailController.text.isNotEmpty) { // Verifică dacă ambele câmpuri de text sunt completate.
      await FirebaseFirestore.instance.collection('suppliers').add({
        'name': _nameController.text, // Adaugă numele furnizorului în baza de date.
        'email': _emailController.text, // Adaugă emailul furnizorului în baza de date.
      });
      _nameController.clear(); // Curăță câmpul de text pentru nume.
      _emailController.clear(); // Curăță câmpul de text pentru email.
    }
  }

  Future<void> _deleteSupplier(String supplierId) async {
    await FirebaseFirestore.instance.collection('suppliers').doc(supplierId).delete(); // Șterge furnizorul din baza de date.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Adaugă padding de 16 pixeli la toate marginile containerului.
        child: Column(
          children: [
            Card(
              elevation: 4, // Setează umbra cardului.
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Setează colțurile rotunjite ale cardului.
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0), // Adaugă padding de 16 pixeli la toate marginile containerului interior.
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController, // Asociază controllerul pentru câmpul de text al numelui.
                      decoration: InputDecoration(
                        labelText: 'Nume furnizor', // Setează eticheta câmpului de text.
                        border: OutlineInputBorder(), // Setează o margine pentru câmpul de text.
                      ),
                    ),
                    SizedBox(height: 16), // Adaugă un spațiu vertical de 16 pixeli între câmpurile de text.
                    TextField(
                      controller: _emailController, // Asociază controllerul pentru câmpul de text al emailului.
                      decoration: InputDecoration(
                        labelText: 'Email', // Setează eticheta câmpului de text.
                        border: OutlineInputBorder(), // Setează o margine pentru câmpul de text.
                      ),
                      keyboardType: TextInputType.emailAddress, // Setează tastatura specifică pentru introducerea adreselor de email.
                    ),
                    SizedBox(height: 16), // Adaugă un spațiu vertical de 16 pixeli între câmpul de text și buton.
                    ElevatedButton(
                      onPressed: _addSupplier, // Setează funcția care se apelează la apăsarea butonului.
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Setează culoarea de fundal a butonului.
                        minimumSize: Size(double.infinity, 50), // Setează dimensiunea minimă a butonului.
                      ),
                      child: Text('Adauga furnizor'), // Textul afișat pe buton.
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16), // Adaugă un spațiu vertical de 16 pixeli între carduri.
            Expanded(
              child: Card(
                elevation: 4, // Setează umbra cardului.
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Setează colțurile rotunjite ale cardului.
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // Adaugă padding de 16 pixeli la toate marginile containerului interior.
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('suppliers').snapshots(), // Creează un stream de instantanee din colecția 'suppliers'.
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator()); // Afișează un indicator de încărcare dacă nu sunt date disponibile.
                      }

                      var suppliers = snapshot.data!.docs.map((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(data['name']), // Afișează numele furnizorului.
                          subtitle: Text(data['email']), // Afișează emailul furnizorului.
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red), // Buton pentru ștergerea furnizorului, cu o iconiță roșie.
                            onPressed: () => _deleteSupplier(doc.id), // Setează funcția de ștergere la apăsarea butonului.
                          ),
                        );
                      }).toList();

                      if (suppliers.isEmpty) {
                        return Center(
                          child: Text(
                            'No suppliers found', // Afișează un mesaj dacă nu există furnizori.
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        );
                      }

                      return ListView(children: suppliers); // Afișează lista de furnizori.
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
