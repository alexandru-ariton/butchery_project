import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:GastroGrid/aplicatie_client/Pagini/Card/pagina_payment.dart';
import 'package:GastroGrid/aplicatie_client/Pagini/Card/pagina_select_card.dart';
import 'package:GastroGrid/aplicatie_client/Pagini/Profile/pagini/pagina_adrese.dart';
import 'package:GastroGrid/aplicatie_client/clase/cart.dart';
import 'package:provider/provider.dart';
import 'package:GastroGrid/providers/provider_adresa_plata_cart.dart';
import 'package:GastroGrid/providers/provider_cart.dart';
import 'package:GastroGrid/providers/provider_livrare.dart';
import 'package:GastroGrid/providers/provider_themes.dart';

class ShoppingCartPage extends StatefulWidget {
  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  bool _orderFinalized = false;

  void _selectDeliveryAddress() async {
    final selectedAddress = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SavedAddressesPage(),
      ),
    );

    if (selectedAddress != null) {
      Provider.of<SelectedOptionsProvider>(context, listen: false).setSelectedAddress(selectedAddress);
      setState(() {
        _orderFinalized = false;
      });
    }
  }

  void _selectPaymentMethod(String? method) async {
    final optionsProvider = Provider.of<SelectedOptionsProvider>(context, listen: false);
    optionsProvider.setSelectedPaymentMethod(method!);

    if (method == 'Card') {
      final cardDetails = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SelectCardPage(),
        ),
      );

      if (cardDetails != null) {
        optionsProvider.setSelectedPaymentMethod(method, cardDetails);
        setState(() {
          _orderFinalized = false;
        });
      }
    }
  }

  void finalizeOrder(BuildContext context) async {
    final optionsProvider = Provider.of<SelectedOptionsProvider>(context, listen: false);

    if (optionsProvider.selectedAddress == null || optionsProvider.selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select an address and a payment method")),
      );
      return;
    }

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
        'address': optionsProvider.selectedAddress ?? 'No address selected',
        'paymentMethod': optionsProvider.selectedPaymentMethod ?? 'No payment method selected',
        'total': cart.total + (deliveryInfo.isDelivery ? deliveryInfo.deliveryFee : 0),
        'timestamp': FieldValue.serverTimestamp(),
      };

      try {
        DocumentReference orderRef = await orders.add(orderData);

        if (optionsProvider.selectedPaymentMethod == 'Card' && optionsProvider.selectedCardDetails != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PaymentPage(
                cardDetails: optionsProvider.selectedCardDetails!,
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
              optionsProvider.clear();
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
          optionsProvider.clear();
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
    final optionsProvider = Provider.of<SelectedOptionsProvider>(context);
    double deliveryFee = cart.items.isEmpty ? 0.0 : (deliveryInfo.isDelivery ? deliveryInfo.deliveryFee : 0);
    double total = cart.total + deliveryFee;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.themeData.colorScheme.background,
      appBar: AppBar(
        title: Center(child: Text('Shopping Cart')),
       
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) => _buildCartItem(cart.items[index]),
            ),
          ),
          _buildExpandableSection(
            title: 'Selectați adresa de livrare',
            content: _buildDeliveryInfoSection(deliveryInfo, optionsProvider),
          ),
          _buildExpandableSection(
            title: 'Selectați metoda de plată',
            content: _buildPaymentMethodSection(optionsProvider),
          ),
          if (!_orderFinalized) _buildTotalSection(cart, deliveryFee, total),
        ],
      ),
    );
  }

  Widget _buildExpandableSection({required String title, required Widget content}) {
    return ExpansionTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      children: [content],
    );
  }

  Widget _buildDeliveryInfoSection(DeliveryProvider deliveryInfo, SelectedOptionsProvider optionsProvider) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: themeProvider.themeData.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: deliveryInfo.isDelivery
          ? ListTile(
              title: Text('Adresa selectată'),
              subtitle: Text(optionsProvider.selectedAddress ?? 'Nu a fost selectată nicio adresă'),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: _selectDeliveryAddress,
            )
          : ListTile(
              title: Text('Ridicare personală activată'),
              subtitle: Text('Produsele vor fi ridicate de la magazin'),
            ),
    );
  }

  Widget _buildPaymentMethodSection(SelectedOptionsProvider optionsProvider) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: themeProvider.themeData.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         
          _buildPaymentOption(
            'Cash',
            optionsProvider.selectedPaymentMethod == 'Cash',
            Icons.money,
            () {
              _selectPaymentMethod('Cash');
            },
          ),
          _buildPaymentOption(
            'Card',
            optionsProvider.selectedPaymentMethod == 'Card',
            Icons.credit_card,
            () {
              _selectPaymentMethod('Card');
            },
          ),
          if (optionsProvider.selectedPaymentMethod == 'Card' && optionsProvider.selectedCardDetails != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Icon(Icons.credit_card, color: themeProvider.themeData.colorScheme.primary),
                  SizedBox(width: 8),
                  Text(
                    'Card selectat: ${optionsProvider.selectedCardDetails!['last4']}',
                    style: TextStyle(
                      fontSize: 16,
                      color: themeProvider.themeData.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String title, bool selected, IconData icon, VoidCallback onTap) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? themeProvider.themeData.colorScheme.primary.withOpacity(0.1) : themeProvider.themeData.colorScheme.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? themeProvider.themeData.colorScheme.primary : themeProvider.themeData.colorScheme.onBackground.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? themeProvider.themeData.colorScheme.primary : themeProvider.themeData.colorScheme.onBackground),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: selected ? themeProvider.themeData.colorScheme.primary : themeProvider.themeData.colorScheme.onBackground,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildCartItem(CartItem item) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  return Card(
    elevation: 4.0,
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          if (item.product.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                item.product.imageUrl!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.image, size: 50, color: Colors.grey[400]),
            ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.product.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: themeProvider.themeData.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Price: ${item.product.price.toStringAsFixed(2)}\ lei',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
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
          _buildQuantityControls(item),
        ],
      ),
    ),
  );
}

Widget _buildQuantityControls(CartItem item) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        icon: Icon(Icons.remove),
        color: themeProvider.themeData.colorScheme.primary,
        onPressed: () {
          if (item.quantity > 1) {
            Provider.of<CartProvider>(context, listen: false).updateProductQuantity(item, item.quantity - 1);
          } else {
            Provider.of<CartProvider>(context, listen: false).removeProduct(item);
          }
        },
      ),
      Text(
        item.quantity.toString(),
        style: TextStyle(
          fontSize: 16,
          color: themeProvider.themeData.colorScheme.onSurface,
        ),
      ),
      IconButton(
        icon: Icon(Icons.add),
        color: themeProvider.themeData.colorScheme.primary,
        onPressed: () {
          Provider.of<CartProvider>(context, listen: false).updateProductQuantity(item, item.quantity + 1);
        },
      ),
    ],
  );
}


  Widget _buildTotalSection(CartProvider cart, double deliveryFee, double total) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final optionsProvider = Provider.of<SelectedOptionsProvider>(context, listen: false);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: themeProvider.themeData.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
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
                  if (optionsProvider.selectedAddress != null && optionsProvider.selectedPaymentMethod != null) {
                    finalizeOrder(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please select an address and a payment method")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'FINALIZEAZĂ COMANDA',
                  style: TextStyle(color: themeProvider.themeData.colorScheme.onSurface, fontSize: 16),
                ),
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
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              color: isTotal ? themeProvider.themeData.colorScheme.primary : themeProvider.themeData.colorScheme.onSurface,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: themeProvider.themeData.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
