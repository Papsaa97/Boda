import 'package:flutter/material.dart';

/// Ikona zóny z nabídky; vlastní zóny mají obecnou ikonu.
IconData zoneIcon(String zoneId) {
  switch (zoneId) {
    case 'Z1':
      return Icons.eco;
    case 'Z2':
      return Icons.local_florist;
    case 'Z3':
      return Icons.park;
    case 'Z4':
      return Icons.grass;
    case 'Z5':
      return Icons.house_siding;
    case 'Z6':
      return Icons.spa;
    case 'Z7':
      return Icons.water;
    default:
      return Icons.yard;
  }
}
