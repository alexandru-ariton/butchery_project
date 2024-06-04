import 'package:GastroGrid/aplicatie_client/Pagini/Cart/componente/cart_item.dart';
import 'package:GastroGrid/aplicatie_client/Pagini/Cart/componente/delivery_info_section.dart';
import 'package:GastroGrid/aplicatie_client/Pagini/Cart/componente/expandable_section.dart';
import 'package:GastroGrid/aplicatie_client/Pagini/Cart/componente/order_summary.dart';
import 'package:GastroGrid/aplicatie_client/Pagini/Cart/componente/payment_method_section.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:GastroGrid/aplicatie_client/Pagini/Card/Payment/pagina_payment.dart';
import 'package:GastroGrid/aplicatie_client/Pagini/Card/Select%20Card/pagina_select_card.dart';
import 'package:GastroGrid/aplicatie_client/Pagini/Profile/pagini/Adrese/pagina_adrese.dart';
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

  void _selectDeliveryAddress(BuildContext context) async {
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

  void _selectPaymentMethod(BuildContext context, String? method) async {
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
              itemBuilder: (context, index) => CartItemWidget(item: cart.items[index]),
            ),
          ),
          ExpandableSection(
            title: 'Selectați adresa de livrare',
            content: DeliveryInfoSection(
              deliveryInfo: deliveryInfo,
              optionsProvider: optionsProvider,
              onSelectDeliveryAddress: () => _selectDeliveryAddress(context),
            ),
          ),
          ExpandableSection(
            title: 'Selectați metoda de plată',
            content: PaymentMethodSection(
              optionsProvider: optionsProvider,
              onSelectPaymentMethod: (method) => _selectPaymentMethod(context, method),
            ),
          ),
          if (!_orderFinalized)
            OrderSummary(
              cart: cart,
              deliveryFee: deliveryFee,
              total: total,
              onFinalizeOrder: () {
                if (optionsProvider.selectedAddress != null && optionsProvider.selectedPaymentMethod != null) {
                  finalizeOrder(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please select an address and a payment method")),
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}

