import 'package:cloud_firestore/cloud_firestore.dart';

Future<DocumentReference> saveCardDetailsToFirestore(Map<String, dynamic> cardData) {
  CollectionReference cards = FirebaseFirestore.instance.collection('cards');
  return cards.add(cardData);
}
