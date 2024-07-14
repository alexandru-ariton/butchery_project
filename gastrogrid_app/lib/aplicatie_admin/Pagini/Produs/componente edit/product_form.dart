import 'package:flutter/material.dart';

// Widget-ul stateless ProductForm primește patru TextEditingController prin constructor.
class ProductForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController priceController;
  final TextEditingController descriptionController;
  final TextEditingController quantityController;

  // Constructorul const al widget-ului primește controller-ele ca parametri necesari.
  const ProductForm({
    super.key,
    required this.titleController,
    required this.priceController,
    required this.descriptionController,
    required this.quantityController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Câmpul de text pentru denumirea produsului.
        TextFormField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: 'Denumire produs',  // Eticheta câmpului
            border: OutlineInputBorder(),  // Bordura câmpului
            filled: true,  // Indică faptul că câmpul este umplut
            fillColor: Colors.grey[200],  // Culoarea de umplere a câmpului
          ),
          validator: (value) {  // Funcția de validare
            if (value == null || value.isEmpty) {
              return 'Introdu denumirea produsului';  // Mesaj de eroare dacă câmpul este gol
            }
            return null;  // Nicio eroare dacă câmpul nu este gol
          },
        ),
        SizedBox(height: 16),  // Spațiu vertical între câmpuri

        // Câmpul de text pentru prețul produsului.
        TextFormField(
          controller: priceController,
          decoration: InputDecoration(
            labelText: 'Pret',  // Eticheta câmpului
            border: OutlineInputBorder(),  // Bordura câmpului
            filled: true,  // Indică faptul că câmpul este umplut
            fillColor: Colors.grey[200],  // Culoarea de umplere a câmpului
          ),
          keyboardType: TextInputType.number,  // Setează tastatura numerică pentru introducerea prețului
          validator: (value) {  // Funcția de validare
            if (value == null || value.isEmpty) {
              return 'Introdu pretul';  // Mesaj de eroare dacă câmpul este gol
            }
            if (double.tryParse(value) == null) {
              return 'Valoare invalida';  // Mesaj de eroare dacă valoarea introdusă nu este un număr
            }
            return null;  // Nicio eroare dacă câmpul nu este gol și valoarea este validă
          },
        ),
        SizedBox(height: 16),  // Spațiu vertical între câmpuri

        // Câmpul de text pentru descrierea produsului.
        TextFormField(
          controller: descriptionController,
          decoration: InputDecoration(
            labelText: 'Descriere',  // Eticheta câmpului
            border: OutlineInputBorder(),  // Bordura câmpului
            filled: true,  // Indică faptul că câmpul este umplut
            fillColor: Colors.grey[200],  // Culoarea de umplere a câmpului
          ),
          maxLines: 4,  // Permite introducerea a până la patru linii de text
          validator: (value) {  // Funcția de validare
            if (value == null || value.isEmpty) {
              return 'Introdu o descriere';  // Mesaj de eroare dacă câmpul este gol
            }
            return null;  // Nicio eroare dacă câmpul nu este gol
          },
        ),
        SizedBox(height: 16),  // Spațiu vertical între câmpuri

        // Câmpul de text pentru cantitatea produsului.
        TextFormField(
          controller: quantityController,
          decoration: InputDecoration(
            labelText: 'Cantitate',  // Eticheta câmpului
            border: OutlineInputBorder(),  // Bordura câmpului
            filled: true,  // Indică faptul că câmpul este umplut
            fillColor: Colors.grey[200],  // Culoarea de umplere a câmpului
          ),
          keyboardType: TextInputType.number,  // Setează tastatura numerică pentru introducerea cantității
          validator: (value) {  // Funcția de validare
            if (value == null || value.isEmpty) {
              return 'Introdu cantitatea';  // Mesaj de eroare dacă câmpul este gol
            }
            if (int.tryParse(value) == null) {
              return 'Valoare invalida';  // Mesaj de eroare dacă valoarea introdusă nu este un număr
            }
            return null;  // Nicio eroare dacă câmpul nu este gol și valoarea este validă
          },
        ),
      ],
    );
  }
}
