// Importă pachetele necesare pentru funcționalitatea widget-ului.
import 'package:gastrogrid_app/providers/provider_themes.dart'; // Importă furnizorul pentru temele aplicației.
import 'package:flutter/material.dart'; // Pachetul principal pentru Flutter.
import 'package:google_place/google_place.dart'; // Pentru utilizarea API-ului Google Place.
import 'package:provider/provider.dart'; // Pentru gestionarea stării aplicației.
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Pentru integrarea Google Maps.

// Definirea unui widget Stateless pentru widget-ul de căutare.
class SearchWidget extends StatelessWidget {
  final GooglePlace googlePlace; // Instanță pentru Google Place API.
  final TextEditingController searchController; // Controler pentru câmpul de căutare.
  final TextEditingController manualAddressController; // Controler pentru adresa manuală.
  final List<AutocompletePrediction> predictions; // Lista predicțiilor autocomplete.
  final bool loading; // Stare de încărcare.
  final Function(String) onSearchChanged; // Funcție apelată la schimbarea căutării.
  final Function(LatLng, String) onPredictionSelected; // Funcție apelată la selectarea unei predicții.

  // Constructor pentru widget-ul SearchWidget.
  const SearchWidget({
    super.key,
    required this.googlePlace,
    required this.searchController,
    required this.manualAddressController,
    required this.predictions,
    required this.loading,
    required this.onSearchChanged,
    required this.onPredictionSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Obține tema curentă utilizată în aplicație.
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0), // Padding-ul pentru containerul principal.
      child: Column(
        children: [
          Material(
            elevation: 5.0, // Înălțimea umbrei pentru efectul de ridicare.
            shadowColor: Colors.black54, // Culoarea umbrei.
            borderRadius: BorderRadius.circular(15.0), // Colțurile rotunjite ale containerului.
            child: TextFormField(
              controller: searchController, // Asociază controlerul câmpului de căutare.
              decoration: InputDecoration(
                hintText: 'Cauta adresa', // Textul de hint pentru câmpul de căutare.
                prefixIcon: Icon(
                  Icons.search, // Iconița de căutare.
                  color: themeProvider.themeData.colorScheme.primary, // Culoarea iconiței.
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15), // Colțurile rotunjite ale câmpului de căutare.
                  borderSide: BorderSide.none, // Fără margine.
                ),
                filled: true, // Activează culoarea de fundal.
                fillColor: themeProvider.themeData.colorScheme.surface, // Culoarea de fundal a câmpului de căutare.
                contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0), // Padding-ul intern al câmpului de căutare.
                suffixIcon: loading
                    ? Padding(
                        padding: const EdgeInsets.all(12.0), // Padding-ul pentru indicatorul de încărcare.
                        child: CircularProgressIndicator(strokeWidth: 2.0), // Indicator de încărcare.
                      )
                    : null,
              ),
              onChanged: onSearchChanged, // Asociază funcția apelată la schimbarea căutării.
            ),
          ),
          SizedBox(height: 8.0), // Spațiere verticală.

          // Afișează lista predicțiilor dacă există.
          predictions.isNotEmpty
              ? Container(
                  constraints: BoxConstraints(maxHeight: 200), // Constrângeri de înălțime pentru container.
                  decoration: BoxDecoration(
                    color: themeProvider.themeData.colorScheme.surface, // Culoarea de fundal a containerului.
                    borderRadius: BorderRadius.circular(15), // Colțurile rotunjite ale containerului.
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), // Culoarea și opacitatea umbrei.
                        spreadRadius: 3, // Răspândirea umbrei.
                        blurRadius: 5, // Estomparea umbrei.
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true, // Constrângerea listei la înălțimea conținutului.
                    itemCount: predictions.length, // Numărul de elemente din listă.
                    itemBuilder: (context, index) {
                      return ListTile(
                        textColor: themeProvider.themeData.colorScheme.primary, // Culoarea textului.
                        title: Text(predictions[index].description ?? ''), // Descrierea predicției.
                        onTap: () async {
                          var placeId = predictions[index].placeId!; // Obține ID-ul locului.
                          var details = await googlePlace.details.get(placeId); // Obține detaliile locului.
                          if (details != null && details.result != null) {
                            var location = details.result!.geometry!.location!;
                            onPredictionSelected(
                              LatLng(location.lat!, location.lng!), // Coordonatele locației.
                              predictions[index].description ?? '', // Descrierea locului.
                            );
                          }
                        },
                      );
                    },
                  ),
                )
              : Container(), // Container gol dacă nu există predicții.
          SizedBox(height: 8.0), // Spațiere verticală.
        ],
      ),
    );
  }
}
