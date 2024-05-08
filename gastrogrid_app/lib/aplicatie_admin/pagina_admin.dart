import 'package:flutter/material.dart';
import 'package:gastrogrid_app/aplicatie_admin/pagina_adaugare_produs.dart';
import 'package:gastrogrid_app/aplicatie_admin/pagina_gestionare_produse.dart';

void main() => runApp(MaterialApp(home: AdminPage()));

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;

  // Pages for navigation
  final _pages = [
    DashboardPage(),
    //ProductFormPage(),
    ManageCustomersPage(),
    ManageEmployeesPage(),
  ];

  void _onItemTapped(int index) {
    Navigator.of(context).pop(); // Close the drawer if it's open
    setState(() {
      _selectedIndex = index;
    });
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text("Admin Name"),
            accountEmail: Text("admin@example.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                'A',
                style: TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          _buildDrawerOption(Icons.dashboard, 'Dashboard', 0),
          _buildDrawerOption(Icons.shopping_cart, 'Manage Products', 1),
          _buildDrawerOption(Icons.people, 'Manage Customers', 2),
          _buildDrawerOption(Icons.work, 'Manage Employees', 3),
        ],
      ),
    );
  }

  ListTile _buildDrawerOption(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: _selectedIndex == index ? Colors.blue : null),
      title: Text(
        title,
        style: TextStyle(color: _selectedIndex == index ? Colors.blue : null),
      ),
      selected: _selectedIndex == index,
      onTap: () => _onItemTapped(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      drawer: _buildDrawer(),
      body: _pages.elementAt(_selectedIndex),
    );
  }
}

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Dashboard'));
  }
}

class ManageCustomersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Manage Customers'));
  }
}

class ManageEmployeesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Manage Employees'));
  }
}
