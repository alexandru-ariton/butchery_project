import 'package:GastroGrid/aplicatie_client/Pagini/Card/componente/card_form.dart';
import 'package:flutter/material.dart';

class CardDetailsPage extends StatefulWidget {
  @override
  _CardDetailsPageState createState() => _CardDetailsPageState();
}

class _CardDetailsPageState extends State<CardDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalii card'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: CardForm(),
      ),
    );
  }
}
