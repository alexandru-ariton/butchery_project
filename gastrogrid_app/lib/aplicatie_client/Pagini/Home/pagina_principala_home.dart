// Importă componentele necesare pentru pagina principală (HomePage).
import 'package:gastrogrid_app/aplicatie_client/Pagini/Home/componente/product_list.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Home/componente/sliver_app_bar_delegate.dart';
import 'package:flutter/material.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Home/componente/butoane_livrare.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Address/pagina_selectare_adresa.dart';
import 'package:gastrogrid_app/providers/provider_themes.dart';
import 'package:provider/provider.dart';

// Declarația unei clase stateful pentru pagina principală.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

// Declarația stării pentru clasa HomePage.
class _HomePageState extends State<HomePage> {
  // Controller pentru câmpul de căutare.
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Metodă pentru selectarea adresei.
  void _selectAddress(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddressSelector(),
      ),
    );
  }

  // Metodă care construiește interfața de utilizator a widgetului.
  @override
  Widget build(BuildContext context) {
    // Obține tema curentă folosind providerul.
    final themeProvider = Provider.of<ThemeProvider>(context);
    // Obține dimensiunea ecranului.
    final screenSize = MediaQuery.of(context).size;
    // Verifică dacă ecranul este mic.
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      // Setează culoarea de fundal a paginii.
      backgroundColor: themeProvider.themeData.colorScheme.surface,
      // Construiește corpul paginii folosind un CustomScrollView.
      body: CustomScrollView(
        slivers: <Widget>[
          // Adaugă un container cu stilizare personalizată.
          SliverToBoxAdapter(
            child: Container(
              color: Theme.of(context).primaryColor,
              padding: EdgeInsets.only(top: isSmallScreen ? 30 : 50, bottom: 23),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(19.0),
                    child: GestureDetector(
                      onTap: () => _selectAddress(context),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 4,
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.pin_drop_outlined,
                                color: Theme.of(context).colorScheme.secondary,
                                size: isSmallScreen ? 30 : 40,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Adaugă butoane pentru opțiunile de livrare.
                  DeliveryToggleButtons(),
                ],
              ),
            ),
          ),
          // Adaugă un header persistent cu un câmp de căutare.
          SliverPersistentHeader(
            delegate: SliverAppBarDelegate(
              minHeight: 80.0,
              maxHeight: 80.0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                alignment: Alignment.center,
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(30.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
                      hintText: 'Cauta produse',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                      filled: true,
                      fillColor: themeProvider.themeData.colorScheme.surface,
                    ),
                    onChanged: (query) {
                      setState(() {
                        _searchQuery = query;
                      });
                    },
                  ),
                ),
              ),
            ),
            pinned: false,
          ),
          // Adaugă lista de produse, filtrată după interogarea de căutare.
          ProductList(searchQuery: _searchQuery),
        ],
      ),
    );
  }
}
