// ignore_for_file: unused_import, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, unnecessary_string_interpolations, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_Home/componente_home/butoane_livrare.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_Home/componente_home/pagina_cart.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_Home/componente_home/pagina_produs.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_Home/componente_home/pagina_selectare_adresa.dart';
import 'package:gastrogrid_app/aplicatie_client/Folder_Home/pagina_home.dart';
import 'package:provider/provider.dart';



class ShoppingCartPage extends StatefulWidget {
  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
 

  @override
  Widget build(BuildContext context) {
     final cart = Provider.of<CartModel>(context);
    final deliveryInfo = Provider.of<DeliveryInfo>(context);

    // Setăm costul de livrare la 0 dacă nu există produse în coș
    double deliveryFee = cart.items.isEmpty ? 0.0 : (deliveryInfo.isDelivery ? deliveryInfo.deliveryFee : 0);
    double total = cart.total + deliveryFee;
  
    return Scaffold(
      appBar: AppBar(
        title: Text('Coș cumpărături'),
        leading: Builder(
    builder: (BuildContext context) {
      return IconButton(
        icon: const Icon(Icons.arrow_back_outlined),
        onPressed: () {  Navigator.of(context).pop(
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ),
                      ); },
       
      );
    },
  ),
      ),
      body: Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? Center(child: Text("Nu exista produse in cos")) // Afișăm mesajul când coșul este gol
                : ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                var item = cart.items[index];
                return Card(
                  child: ListTile(
                     // Replace with your image provider
                    title: Text(item.title),
                    subtitle: Text('${item.price.toStringAsFixed(2)} Lei x ${item.quantity}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                        onPressed: () => cart.removeProduct(item),
                        ),
                        Text(item.quantity.toString()),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () => cart.addProduct(item),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Produse în coș:'),
                      Text('${cart.items.length}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal:'),
                      Text('${cart.total} lei'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Livrare:'),
                      Text(cart.items.isEmpty ? "0 lei" : '${deliveryInfo.isDelivery ? "$deliveryFee lei" : "Ridicare"}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total: '),
                     Text(cart.items.isEmpty ? "0 lei" : '$total lei'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Add your ToggleButtons or SwitchListTile for customer type here
          // Add your TextField for additional order information here
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50)),
              onPressed: () {
                // Finalize order logic
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('FINALIZEAZĂ COMANDA'),
                  Icon(Icons.arrow_forward)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}


