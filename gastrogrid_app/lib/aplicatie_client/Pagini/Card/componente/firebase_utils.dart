// Importă pachetul necesar pentru Cloud Firestore.
import 'package:cloud_firestore/cloud_firestore.dart';

// Funcție asincronă care salvează detaliile cardului în Firestore și returnează un DocumentReference.
Future<DocumentReference> saveCardDetailsToFirestore(Map<String, dynamic> cardData) {
  // Obține referința către colecția 'cards' din Firestore.
  CollectionReference cards = FirebaseFirestore.instance.collection('cards');

  // Adaugă datele cardului în colecția 'cards' și returnează referința către documentul creat.
  return cards.add(cardData);
}
