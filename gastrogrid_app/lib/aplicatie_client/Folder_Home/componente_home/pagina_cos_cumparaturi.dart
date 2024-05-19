// ignore_for_file: unused_field, unused_element, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_Home/componente_home/butoane_livrare.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_Home/componente_home/pagina_cart.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_Profile/pagini/pagina_adrese.dart';
import 'package:gastrogrid_app/aplicatie_client/clase/cart.dart';
import 'package:gastrogrid_app/aplicatie_client/clase/info_livrare.dart';
import 'package:gastrogrid_app/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class ShoppingCartPage extends StatefulWidget {
  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {

  String? _selectedAddress;

   void _selectDeliveryAddress() async {
    // Open the SavedAddressesPage and await the selected address
    final selectedAddress = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SavedAddressesPage(),
      ),
    );

    // If an address is selected, update the state
    if (selectedAddress != null) {
      setState(() {
        _selectedAddress = selectedAddress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);
    final deliveryInfo = Provider.of<DeliveryInfo>(context);
    

    // Setăm costul de livrare la 0 dacă nu există produse în coș
    double deliveryFee = cart.items.isEmpty ? 0.0 : (deliveryInfo.isDelivery ? deliveryInfo.deliveryFee : 0);
    double total = cart.total + deliveryFee;
    final themeProvider = Provider.of<ThemeProvider>(context);
  
     return Scaffold(
      backgroundColor: themeProvider.themeData.colorScheme.background,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            automaticallyImplyLeading: false,
            backgroundColor: themeProvider.themeData.colorScheme.background,
            floating: false,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              
              title: Text('Coș cumpărături', style: TextStyle(color:themeProvider.themeData.colorScheme.primary)),
              
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildCartItem(cart.items[index]),
              childCount: cart.items.length,
            ),
          ),
          SliverToBoxAdapter(
            child: _buildDeliveryInfoSection(deliveryInfo),
          ),
          SliverToBoxAdapter(
            child: _buildTotalSection(cart,deliveryFee,total),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoSection(DeliveryInfo deliveryInfo) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: themeProvider.themeData.colorScheme.background,
        borderRadius:BorderRadius.circular(12.0),
      ),
      child: deliveryInfo.isDelivery
          ? ListTile(
              title: Text('Selectați adresa de livrare'),
              subtitle: Text(deliveryInfo.selectedAddress ?? 'Nu a fost selectată nicio adresă'),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: _selectDeliveryAddress,
            )
          : ListTile(
              title: Text('Ridicare personală activată'),
              subtitle: Text('Produsele vor fi ridicate de la magazin'),
            ),
    );
  }

 Widget _buildCartItem(CartItem item) {
  return Card(
    elevation: 2.0,
    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    child: Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          // Use a placeholder image for now, replace with item.image later
         
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Price: \$${item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Quantity: ${item.quantity}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildQuantityControls(item),
        ],
      ),
    ),
  );
}


  Widget _buildQuantityControls(CartItem item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.remove),
         onPressed: () {
                if (item.quantity > 1) {
                  // Decrement the quantity for the specific item
                  Provider.of<CartModel>(context, listen: false).updateProductQuantity(item, item.quantity - 1);
                } else {
                  // Remove the item completely if quantity is 1
                  Provider.of<CartModel>(context, listen: false).removeProduct(item);
                }
              },
        ),
        Text(item.quantity.toString()),
        IconButton(
          icon: Icon(Icons.add),
         onPressed: () {
                // Increment the quantity for the specific item
                Provider.of<CartModel>(context, listen: false).updateProductQuantity(item, item.quantity + 1);
              },
        ),
      ],
    );
  }

  Widget _buildTotalSection(CartModel cart, double deliveryFee, double total) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: themeProvider.themeData.colorScheme.background,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummaryLine('Produse în coș:', '${cart.totalItemsQuantity}'),
            _buildSummaryLine('Subtotal:', '${cart.total.toStringAsFixed(2)} lei'),
            _buildSummaryLine('Livrare:', cart.items.isEmpty ? '0 lei' : '${deliveryFee.toStringAsFixed(2)} lei'),
            Divider(),
            _buildSummaryLine('Total:', '${total.toStringAsFixed(2)} lei', isTotal: true),
            SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(30)),
              onPressed: () {
                // Logică pentru finalizarea comenzii
              },
              child: Text('FINALIZEAZĂ COMANDA',style: TextStyle(color: themeProvider.themeData.colorScheme.primary),),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryLine(String title, String value, {bool isTotal = false}) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: isTotal ? 18 : 16, color: isTotal ? themeProvider.themeData.colorScheme.primary : themeProvider.themeData.colorScheme.primary,)),
          Text(value, style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}


