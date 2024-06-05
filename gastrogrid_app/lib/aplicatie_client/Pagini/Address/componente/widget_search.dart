import 'package:GastroGrid/providers/provider_themes.dart';
import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchWidget extends StatelessWidget {
  final GooglePlace googlePlace;
  final TextEditingController searchController;
  final TextEditingController manualAddressController;
  final List<AutocompletePrediction> predictions;
  final bool loading;
  final Function(String) onSearchChanged;
  final Function(LatLng, String) onPredictionSelected;

  const SearchWidget({super.key, 
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Material(
            elevation: 5.0,
            shadowColor: Colors.black54,
            borderRadius: BorderRadius.circular(15.0),
            child: TextFormField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by street, city, or state',
                prefixIcon: Icon(Icons.search, color: themeProvider.themeData.colorScheme.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: themeProvider.themeData.colorScheme.surface,
                contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                suffixIcon: loading 
                    ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(strokeWidth: 2.0),
                      )
                    : null,
              ),
              onChanged: onSearchChanged,
            ),
          ),
          SizedBox(height: 8.0),
          predictions.isNotEmpty
              ? Container(
                  constraints: BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: themeProvider.themeData.colorScheme.surface,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: predictions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        textColor: themeProvider.themeData.colorScheme.primary,
                        title: Text(predictions[index].description ?? ''),
                        onTap: () async {
                          var placeId = predictions[index].placeId!;
                          var details = await googlePlace.details.get(placeId);
                          if (details != null && details.result != null) {
                            var location = details.result!.geometry!.location!;
                            onPredictionSelected(
                              LatLng(location.lat!, location.lng!),
                              predictions[index].description ?? '',
                            );
                          }
                        },
                      );
                    },
                  ),
                )
              : Container(),
          SizedBox(height: 8.0),
        ],
      ),
    );
  }
}
