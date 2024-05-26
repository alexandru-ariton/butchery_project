import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingPage extends StatefulWidget {
  final String orderId;
  final String userId;

  RatingPage({required this.orderId, required this.userId});

  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  double _rating = 0.0;

  void _submitRating() async {
    try {
      await FirebaseFirestore.instance.collection('ratings').add({
        'orderId': widget.orderId,
        'userId': widget.userId,
        'rating': _rating,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Thank you for your feedback!')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit rating: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rate Our Services')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Please rate our services:'),
            SizedBox(height: 16),
            Slider(
              value: _rating,
              onChanged: (newRating) {
                setState(() {
                  _rating = newRating;
                });
              },
              min: 0,
              max: 5,
              divisions: 5,
              label: _rating.toString(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitRating,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
