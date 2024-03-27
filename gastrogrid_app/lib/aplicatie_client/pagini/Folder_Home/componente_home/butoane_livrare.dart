import 'package:flutter/material.dart';

class DeliveryToggleButtons extends StatefulWidget {
  @override
  _DeliveryToggleButtonsState createState() => _DeliveryToggleButtonsState();
}

class _DeliveryToggleButtonsState extends State<DeliveryToggleButtons> {
  bool isDeliverySelected = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40, // Înălțimea container-ului pentru butoane
      child: Padding(
        padding: const EdgeInsets.only(left: 110),
        child: Row(
          mainAxisSize:MainAxisSize.min, // Face ca Row să fie cât mai mic posibil
          children: <Widget>[
            AnimatedContainer(
              height: 30,
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
                     fontSize: 12
                  ),
                ),
              ),
            ),
             // Spațiu între butoane
            AnimatedContainer(
              height: 30,
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
                    fontSize: 12
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
