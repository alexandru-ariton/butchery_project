import 'package:flutter/material.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Card/componente/card_form.dart';

class CardDetailsPage extends StatefulWidget {
  final Map<String, dynamic>? cardData;
  final String? cardId;

  const CardDetailsPage({Key? key, this.cardData, this.cardId}) : super(key: key);

  @override
  _CardDetailsPageState createState() => _CardDetailsPageState();
}

class _CardDetailsPageState extends State<CardDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cardId != null ? 'Editează card' : 'Adaugă card'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: CardForm(
          cardData: widget.cardData,
          cardId: widget.cardId,
        ),
      ),
    );
  }
}
