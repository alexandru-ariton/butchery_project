import 'package:flutter/material.dart'; // Importă biblioteca principală Flutter pentru utilizarea widget-urilor.
import 'package:gastrogrid_app/Autentificare/pagini/pagina_login.dart'; // Importă pagina de login din aplicație.
import 'package:gastrogrid_app/aplicatie_admin/Pagini/Furnizori/pagina_furnizori.dart'; // Importă pagina furnizorilor din aplicație.
import 'package:gastrogrid_app/aplicatie_admin/Pagini/Notificari/pagina_notificari.dart'; // Importă pagina notificărilor din aplicație.
import '../Produs/pagina_produse.dart'; // Importă pagina produselor din aplicație.
import '../Comenzi/pagina_comenzi.dart'; // Importă pagina comenzilor din aplicație.
import '../Dashboard/pagina_dashboard.dart'; // Importă pagina dashboard-ului din aplicație.

class AdminHome extends StatelessWidget {
  const AdminHome({super.key}); // Constructorul clasei, care folosește o cheie opțională.

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // Setează numărul de tab-uri.
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal, // Setează culoarea de fundal a AppBar-ului.
          actions: [
            PopupMenuButton<String>(
              onSelected: (String result) { // Funcție callback pentru acțiunea selectată.
                if (result == 'Logout') {
                  _logout(context); // Apel la funcția de logout.
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'Logout',
                  child: Text('Logout'), // Textul din meniul popup.
                ),
              ],
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight), // Setează înălțimea preferată a TabBar-ului.
            child: Container(
              alignment: Alignment.center,
              child: TabBar(
                indicatorColor: Colors.white, // Setează culoarea indicatorului tab-ului selectat.
                labelColor: Colors.white, // Setează culoarea textului tab-ului selectat.
                unselectedLabelColor: Colors.white70, // Setează culoarea textului tab-ului ne-selectat.
                tabs: const [
                  Tab(icon: Icon(Icons.dashboard, size: 28), text: 'Dashboard'), // Tab-ul pentru Dashboard.
                  Tab(icon: Icon(Icons.shopping_bag, size: 28), text: 'Produse'), // Tab-ul pentru Produse.
                  Tab(icon: Icon(Icons.receipt, size: 28), text: 'Comenzi'), // Tab-ul pentru Comenzi.
                  Tab(icon: Icon(Icons.notifications, size: 28), text: 'Notificari'), // Tab-ul pentru Notificări.
                  Tab(icon: Icon(Icons.public_rounded, size: 28), text: 'Furnizori'), // Tab-ul pentru Furnizori.
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            Dashboard(), // Widget-ul pentru pagina de Dashboard.
            ProductManagement(), // Widget-ul pentru pagina de Management al Produselor.
            OrderManagement(), // Widget-ul pentru pagina de Management al Comenzilor.
            LowStockNotificationPage(), // Widget-ul pentru pagina de Notificări de Stoc Mic.
            SupplierManagementPage(), // Widget-ul pentru pagina de Management al Furnizorilor.
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PaginaLogin()), // Navighează la pagina de Login.
    );
  }
}
