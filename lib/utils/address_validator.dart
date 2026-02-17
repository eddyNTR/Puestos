import 'package:geocoding/geocoding.dart';

/// Validador centralizado para direcciones y patrones
class AddressValidator {
  // Evita instanciacion
  AddressValidator._();

  // Patron para detectar codigos plus (ej: JR9R+55V)
  static final _plusPattern = RegExp(r'^[A-Z0-9]{2,4}\+[A-Z0-9]{2,4}$');

  /// Valida que una direccion no sea solo un codigo plus
  static bool isValidAddress(String? text) {
    if (text == null || text.isEmpty) return false;
    return !_plusPattern.hasMatch(text) && text.length > 2;
  }

  /// Filtra direcciones validas a partir de un Placemark
  static List<String> getValidAddresses(Placemark placemark) {
    final addresses = [
      placemark.thoroughfare,
      placemark.street,
      placemark.name,
      placemark.subLocality,
      placemark.locality,
    ];

    return addresses
        .where((addr) => isValidAddress(addr))
        .cast<String>()
        .toList();
  }

  /// Construye direccion formateada desde un Placemark
  static String buildAddress(Placemark placemark) {
    final validAddresses = getValidAddresses(placemark);

    if (validAddresses.length >= 2) {
      return '${validAddresses[0]} y ${validAddresses[1]}';
    } else if (validAddresses.length == 1) {
      return validAddresses[0];
    } else {
      return '${placemark.locality ?? 'Ubicacion'} ${placemark.postalCode ?? ''}'
          .trim();
    }
  }
}
