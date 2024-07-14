import 'package:flutter/material.dart'; // Importă biblioteca principală Flutter pentru utilizarea widget-urilor.
import 'package:cloud_firestore/cloud_firestore.dart'; // Importă biblioteca Cloud Firestore pentru accesul la baza de date Firestore.
import 'package:gastrogrid_app/aplicatie_admin/Pagini/Comenzi/pagina_detalii_comenzi.dart'; // Importă pagina de detalii comenzi.

class OrderManagement extends StatelessWidget {
  const OrderManagement({super.key}); // Constructorul clasei, care folosește o cheie opțională.

  void _deleteOrder(String id) async {
    await FirebaseFirestore.instance.collection('orders').doc(id).delete(); // Șterge comanda cu ID-ul specificat din colecția 'orders'.
  }

  void _updateOrderStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({'status': newStatus}); // Actualizează statusul comenzii în baza de date.
  }

  void _updatePreparationStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({'preparationStatus': newStatus}); // Actualizează statusul de preparare al comenzii în baza de date.
  }

  void _updatePaymentStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({'paymentStatus': newStatus}); // Actualizează statusul de plată al comenzii în baza de date.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Setează culoarea de fundal a paginii.
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(), // Creează un stream de instantanee din colecția 'orders'.
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator()); // Afișează un indicator de încărcare dacă nu sunt date disponibile.
          }

          var orders = snapshot.data!.docs; // Obține documentele comenzii.
          return Padding(
            padding: const EdgeInsets.all(16.0), // Adaugă padding de 16 pixeli la toate marginile.
            child: ListView.builder(
              itemCount: orders.length, // Setează numărul de elemente din ListView.
              itemBuilder: (context, index) {
                var order = orders[index];
                var orderId = order.id; // Obține ID-ul comenzii.
                var orderData = order.data() as Map<String, dynamic>; // Obține datele comenzii.

                String currentPreparationStatus = orderData['preparationStatus'] ?? 'Receptionata'; // Obține statusul de preparare al comenzii.
                String currentPaymentStatus = orderData['paymentStatus'] ?? 'Neplatit'; // Obține statusul de plată al comenzii.

                // Verifică dacă statusul de preparare este valid.
                if (!['Receptionata', 'In curs de procesare', 'In curs de livrare', 'Finalizata'].contains(currentPreparationStatus)) {
                  currentPreparationStatus = 'Receptionata';
                }

                // Verifică dacă statusul de plată este valid.
                if (!['Platit', 'Neplatit'].contains(currentPaymentStatus)) {
                  currentPaymentStatus = 'Neplatit';
                }

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0), // Adaugă o margine verticală de 8 pixeli.
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Setează colțurile rotunjite ale cardului.
                  ),
                  elevation: 5, // Setează umbra cardului.
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15), // Setează colțurile rotunjite ale efectului de apăsare.
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => OrderDetailsPage(orderId: orderId, orderData: orderData), // Navighează la pagina de detalii comenzi la apăsarea cardului.
                      ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0), // Adaugă padding de 16 pixeli la toate marginile containerului interior.
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Comanda $orderId',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8), // Adaugă un spațiu vertical de 8 pixeli.
                          Text(
                            'Status preparare: $currentPreparationStatus',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Status plata: $currentPaymentStatus',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 16), // Adaugă un spațiu vertical de 16 pixeli.
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: currentPreparationStatus,
                                  decoration: InputDecoration(
                                    labelText: 'Status preparare',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8), // Setează colțurile rotunjite ale câmpului de text.
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  items: ['Receptionata', 'In curs de procesare', 'In curs de livrare', 'Finalizata']
                                      .map((status) => DropdownMenuItem(
                                            value: status,
                                            child: Text(status, style: TextStyle(fontSize: 16)),
                                          ))
                                      .toList(),
                                  onChanged: (String? value) {
                                    if (value != null) {
                                      _updatePreparationStatus(orderId, value); // Actualizează statusul de preparare la schimbarea valorii.
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: 8), // Adaugă un spațiu orizontal de 8 pixeli.
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: currentPaymentStatus,
                                  decoration: InputDecoration(
                                    labelText: 'Status plata',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8), // Setează colțurile rotunjite ale câmpului de text.
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  items: currentPaymentStatus == 'Platit'
                                      ? [
                                          DropdownMenuItem(
                                            value: 'Platit',
                                            child: Text('Platit', style: TextStyle(fontSize: 16)),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Neplatit',
                                            child: Text('Neplatit', style: TextStyle(fontSize: 16)),
                                          ),
                                        ]
                                      : ['Platit', 'Neplatit']
                                          .map((status) => DropdownMenuItem(
                                                value: status,
                                                child: Text(status, style: TextStyle(fontSize: 16)),
                                              ))
                                          .toList(),
                                  onChanged: currentPaymentStatus == 'Platit'
                                      ? null
                                      : (String? value) {
                                          if (value != null) {
                                            _updatePaymentStatus(orderId, value); // Actualizează statusul de plată la schimbarea valorii.
                                          }
                                        },
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, size: 24, color: Colors.red), // Setează iconița butonului de ștergere.
                                onPressed: () => _deleteOrder(orderId), // Șterge comanda la apăsarea butonului.
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
