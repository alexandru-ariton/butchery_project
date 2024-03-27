// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:flutter/material.dart';

class DeliveryToggleButtons extends StatefulWidget {
  @override
  _DeliveryToggleButtonsState createState() => _DeliveryToggleButtonsState();
}

class _DeliveryToggleButtonsState extends State<DeliveryToggleButtons> {
  bool isDeliverySelected = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min, // Face ca Row să fie cât mai mic posibil
            children: <Widget>[
              _buildDeliveryButton(),
              _buildPickupButton(),
            ],
          ),
        ),
        if (isDeliverySelected) ...[
          SizedBox(height: 10),
         
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [ 
            
            Icon(Icons.timelapse_outlined,size: 15,),
            Text('60 min', style: TextStyle(fontSize: 12)),
            SizedBox(width: 8),
            Icon(Icons.delivery_dining_outlined,size: 15,),
            Text('5 lei', style: TextStyle(fontSize: 12)),
            ],
                    ),
          ),
          
        ] else ...[
          SizedBox(height: 10),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [ 
            
            Icon(Icons.timelapse_outlined,size: 15,),
            Text('20 min', style: TextStyle(fontSize: 12)),
         
            ],
                    ),
          ),
        ],
      ],
    );
  }

  Widget _buildDeliveryButton() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isDeliverySelected ? Colors.blue : Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: () {
          setState(() {
            isDeliverySelected = true;
          });
        },
        child: Text(
          'Livrare',
          style: TextStyle(
            color: isDeliverySelected ? Colors.white : Colors.black,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildPickupButton() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: !isDeliverySelected ? Colors.blue : Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: () {
          setState(() {
            isDeliverySelected = false;
          });
        },
        child: Text(
          'Ridicare',
          style: TextStyle(
            color: !isDeliverySelected ? Colors.white : Colors.black,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}