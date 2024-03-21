// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';




class PaymentPage extends StatefulWidget {
  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
  
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bolt balance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'LEI 0', 
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    // Handle "What is Bolt balance?" button press
                  },
                  child: Text('What is Bolt balance?'),
                ),
                TextButton(
                  onPressed: () {
                    // Handle "See Bolt balance transactions" button press
                  },
                  child: Text('See Bolt balance transactions'),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              'Payment methods',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Apple Pay'),
                Switch(
                  value: true, // Replace with actual value
                  onChanged: (newValue) {
                    // Handle switch toggle
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                // Handle "Add debit/credit card" tap
              },
              child: Row(
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text('Add debit/credit card'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
