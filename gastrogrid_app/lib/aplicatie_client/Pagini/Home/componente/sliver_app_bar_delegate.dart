// Importă biblioteca Flutter pentru a crea interfețe de utilizator.
import 'package:flutter/material.dart';

// Declară o clasă SliverAppBarDelegate care extinde SliverPersistentHeaderDelegate.
class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  // Constructorul pentru SliverAppBarDelegate care primește înălțimea minimă, înălțimea maximă și un widget copil.
  SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  // Variabile finale pentru înălțimea minimă, înălțimea maximă și widget-ul copil.
  final double minHeight;
  final double maxHeight;
  final Widget child;

  // Getter pentru extinderea minimă, returnează înălțimea minimă.
  @override
  double get minExtent => minHeight;

  // Getter pentru extinderea maximă, returnează înălțimea maximă sau minimă, oricare este mai mare.
  @override
  double get maxExtent => maxHeight > minHeight ? maxHeight : minHeight;

  // Metoda build construiește widget-ul în funcție de context, shrinkOffset și overlapsContent.
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Returnează un widget SizedBox care se extinde pentru a ocupa tot spațiul disponibil și conține widget-ul copil.
    return SizedBox.expand(child: child);
  }

  // Metoda shouldRebuild decide dacă delegatul ar trebui reconstruit.
  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    // Returnează true dacă înălțimea maximă, înălțimea minimă sau widget-ul copil diferă de cele ale delegatului vechi.
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
