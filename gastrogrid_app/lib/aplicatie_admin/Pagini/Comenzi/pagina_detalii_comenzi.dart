import 'package:gastrogrid_app/aplicatie_admin/Pagini/Comenzi/componente/order_items.dart'; // Importă componenta pentru afișarea itemelor din comandă.
import 'package:gastrogrid_app/aplicatie_admin/Pagini/Comenzi/componente/pdf_generator.dart'; // Importă componenta pentru generarea și vizualizarea PDF-ului.
import 'package:gastrogrid_app/aplicatie_admin/Pagini/Comenzi/componente/user_details.dart'; // Importă componenta pentru afișarea detaliilor utilizatorului.
import 'package:flutter/material.dart'; // Importă biblioteca principală Flutter pentru utilizarea widget-urilor.

class OrderDetailsPage extends StatelessWidget {
  final String orderId; // ID-ul comenzii.
  final Map<String, dynamic> orderData; // Datele comenzii.

  const OrderDetailsPage({super.key, required this.orderId, required this.orderData}); // Constructorul clasei, care primește ID-ul comenzii și datele comenzii.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalii Comanda'), // Setează titlul AppBar-ului.
        leading: IconButton(
          icon: Icon(Icons.close), // Setează iconița butonului de închidere.
          onPressed: () {
            Navigator.pop(context); // Închide pagina curentă la apăsarea butonului.
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Adaugă padding de 16 pixeli la toate marginile.
        child: Card(
          elevation: 4.0, // Setează umbra cardului.
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Setează colțurile rotunjite ale cardului.
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Adaugă padding de 16 pixeli la toate marginile containerului interior.
            child: ListView(
              children: [
                _buildOrderDetailRow('ID comanda:', orderId), // Afișează ID-ul comenzii.
                _buildOrderDetailRow('Total:', '${orderData['total'] ?? 'Unknown'} lei'), // Afișează totalul comenzii.
                SizedBox(height: 16), // Adaugă un spațiu vertical de 16 pixeli.
                Text('Produse:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Afișează textul "Produse".
                OrderItems(orderItems: orderData['items'] ?? []), // Afișează itemele comenzii.
                SizedBox(height: 16), // Adaugă un spațiu vertical de 16 pixeli.
                _buildOrderDetailRow('Adresa:', orderData['address'] ?? 'No address provided'), // Afișează adresa comenzii.
                _buildOrderDetailRow('Modalitatea de plata:', orderData['paymentMethod'] ?? 'Unknown'), // Afișează modalitatea de plată.
                SizedBox(height: 16), // Adaugă un spațiu vertical de 16 pixeli.
                Text('Detalii client:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Afișează textul "Detalii Client".
                UserDetails(userId: orderData['userId']), // Afișează detaliile utilizatorului.
                SizedBox(height: 16), // Adaugă un spațiu vertical de 16 pixeli.
                Center(
                  child: ElevatedButton(
                    onPressed: () => generateAndViewPDF(context, orderId, orderData), // Generează și afișează PDF-ul la apăsarea butonului.
                    child: Text('Printeaza chitanta', style: TextStyle(fontSize: 18)), // Setează textul butonului.
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Adaugă padding vertical de 8 pixeli.
      child: Row(
        children: [
          Text('$label ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Setează stilul textului pentru etichetă.
          Expanded(child: Text(value, style: TextStyle(fontSize: 18))), // Setează stilul textului pentru valoare și extinde pe toată lățimea disponibilă.
        ],
      ),
    );
  }
}
