import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Card/pagina_payment.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Card/pagina_select_card.dart';
import 'package:gastrogrid_app/aplicatie_client/clase/cart.dart';
import 'package:provider/provider.dart';
import 'package:gastrogrid_app/providers/provider_cart.dart';
import 'package:gastrogrid_app/providers/provider_livrare.dart';
import 'package:gastrogrid_app/providers/theme_provider.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Profile/pagini/pagina_adrese.dart';

class ShoppingCartPage extends StatefulWidget {
  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  String? _selectedAddress;
  String? _selectedPaymentMethod;
  Map<String, dynamic>? _selectedCardDetails;
  bool _orderFinalized = false;

  void _selectDeliveryAddress() async {
    final selectedAddress = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SavedAddressesPage(),
      ),
    );

    if (selectedAddress != null) {
      setState(() {
        _selectedAddress = selectedAddress;
        _orderFinalized = false;
      });
    }
  }

  void _selectPaymentMethod(String? method) async {
    setState(() {
      _selectedPaymentMethod = method;
    });

    if (method == 'Card') {
      final cardDetails = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SelectCardPage(),
        ),
      );

      if (cardDetails != null) {
        setState(() {
          _selectedCardDetails = cardDetails;
          _orderFinalized = false;
        });
      }
    }
  }

  void finalizeOrder(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      CollectionReference orders = FirebaseFirestore.instance.collection('orders');

      final cart = Provider.of<CartProvider>(context, listen: false);
      final deliveryInfo = Provider.of<DeliveryProvider>(context, listen: false);

      List<Map<String, dynamic>> items = cart.items.map((item) => item.toMap()).toList();
      Map<String, dynamic> orderData = {
        'userId': userId,
        'items': items,
        'status': 'Pending',
        'address': _selectedAddress ?? 'No address selected',
        'paymentMethod': _selectedPaymentMethod ?? 'No payment method selected',
        'total': cart.total + (deliveryInfo.isDelivery ? deliveryInfo.deliveryFee : 0),
        'timestamp': FieldValue.serverTimestamp(),
      };

      try {
        DocumentReference orderRef = await orders.add(orderData);

        if (_selectedPaymentMethod == 'Card' && _selectedCardDetails != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PaymentPage(
                cardDetails: _selectedCardDetails!,
                amount: orderData['total'],
                orderId: orderRef.id,
              ),
            ),
          ).then((paymentSuccess) async {
            if (paymentSuccess == true) {
              await orderRef.update({'status': 'Paid'});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Plata a fost efectuată cu succes")),
              );
              cart.clear();
              setState(() {
                _orderFinalized = true;
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Plata a eșuat")),
              );
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Order finalized successfully")),
          );
          cart.clear();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to finalize order: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You must be logged in to finalize an order")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final deliveryInfo = Provider.of<DeliveryProvider>(context);
    double deliveryFee = cart.items.isEmpty ? 0.0 : (deliveryInfo.isDelivery ? deliveryInfo.deliveryFee : 0);
    double total = cart.total + deliveryFee;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.themeData.colorScheme.background,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Column(
              children: [
                Flexible(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) => _buildCartItem(cart.items[index]),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDeliveryInfoSection(deliveryInfo),
                _buildPaymentMethodSection(),
                if (!_orderFinalized) _buildTotalSection(cart, deliveryFee, total),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoSection(DeliveryProvider deliveryInfo) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: themeProvider.themeData.colorScheme.background,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: deliveryInfo.isDelivery
          ? ListTile(
              title: Text('Selectați adresa de livrare'),
              subtitle: Text(_selectedAddress ?? 'Nu a fost selectată nicio adresă'),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: _selectDeliveryAddress,
            )
          : ListTile(
              title: Text('Ridicare personală activată'),
              subtitle: Text('Produsele vor fi ridicate de la magazin'),
            ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      children: [
        ListTile(
          title: Text('Selectați metoda de plată'),
          trailing: DropdownButton<String>(
            value: _selectedPaymentMethod,
            items: [
              DropdownMenuItem(child: Text('Cash'), value: 'Cash'),
              DropdownMenuItem(child: Text('Card'), value: 'Card'),
            ],
            onChanged: (value) {
              _selectPaymentMethod(value);
            },
          ),
        ),
        if (_selectedPaymentMethod == 'Card' && _selectedCardDetails != null)
          ListTile(
            title: Text('Card selectat: ${_selectedCardDetails!['last4']}'),
          ),
      ],
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.product.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Price: \$${item.product.price.toStringAsFixed(2)}',
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
              Provider.of<CartProvider>(context, listen: false).updateProductQuantity(item, item.quantity - 1);
            } else {
              Provider.of<CartProvider>(context, listen: false).removeProduct(item);
            }
          },
        ),
        Text(item.quantity.toString()),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            Provider.of<CartProvider>(context, listen: false).updateProductQuantity(item, item.quantity + 1);
          },
        ),
      ],
    );
  }

  Widget _buildTotalSection(CartProvider cart, double deliveryFee, double total) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: EdgeInsets.only(top: 0, left: 15, right: 15),
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
            SizedBox(height: 20),
            if (!_orderFinalized && !cart.items.isEmpty)
              ElevatedButton(
                onPressed: () {
                  finalizeOrder(context);
                },
                child: Text('FINALIZEAZA COMANDA', style: TextStyle(color: themeProvider.themeData.colorScheme.primary)),
              ),
            SizedBox(height: 40),
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
          Text(title, style: TextStyle(fontSize: isTotal ? 18 : 16, color: isTotal ? themeProvider.themeData.colorScheme.primary : themeProvider.themeData.colorScheme.primary)),
          Text(value, style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
