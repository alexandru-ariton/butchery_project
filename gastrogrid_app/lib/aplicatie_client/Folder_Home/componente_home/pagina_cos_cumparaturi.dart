// ignore_for_file: unused_field, unused_element

import 'package:flutter/material.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_Home/componente_home/butoane_livrare.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_Home/componente_home/pagina_cart.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_Profile/pagini/pagina_adrese.dart';
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
  
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text('Coș cumpărături')),
       
      ),
      body: Column(
        children: [
           
          Expanded(
            child: cart.items.isEmpty
                ? Center(child: Text("Nu există produse în coș", style: TextStyle(fontSize: 18)))
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      return _buildCartItem(cart.items[index]);
                    },
                  ),
          ),
          if (deliveryInfo.isDelivery)// Check if delivery is selected
            Container(
              // If an address is selected, display it
              padding: EdgeInsets.all(16),
              color: Colors.grey[200],
              width: double.infinity,
              child: deliveryInfo.selectedAddress != null
                  ? Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Adresa de livrare: ${deliveryInfo.selectedAddress}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () async {
                            final selectedAddress = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SavedAddressesPage(),
                              ),
                            );
                            if (selectedAddress != null) {
                              setState(() {
                                _selectedAddress = selectedAddress;
                              });
                            }
                          },
                        ),
                      ],
                    )
                  : ElevatedButton(
                      child: Text("Selectează o adresă de livrare"),
                      onPressed: () async {
                        final selectedAddress = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SavedAddressesPage(),
                          ),
                        );
                        if (selectedAddress != null) {
                          setState(() {
                            deliveryInfo.setSelectedAddress(selectedAddress as String);
                          });
                        }
                      },
                    ),
            ),
          
          _buildTotalSection(cart, deliveryFee, total),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return ListTile(
       // Înlocuiește cu o imagine reală
      title: Text(item.title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${item.price} x ${item.quantity}'),
      trailing: _buildQuantityControls(item),
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
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50)),
              onPressed: () {
                // Logică pentru finalizarea comenzii
              },
              child: Text('FINALIZEAZĂ COMANDA'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryLine(String title, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: isTotal ? 18 : 16, color: isTotal ? Colors.black : Colors.grey[600])),
          Text(value, style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}


