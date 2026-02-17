import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../utils/address_validator.dart';

/// Servicio centralizado para operaciones de geocoding
class GeocodingService {
  // Evita instanciacion
  GeocodingService._();

  /// Obtiene la direccion de una coordenada
  static Future<String> getAddressFromCoordinates(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        return 'Direccion no encontrada';
      }

      return AddressValidator.buildAddress(placemarks.first);
    } catch (_) {
      return 'Direccion no encontrada';
    }
  }

  /// Obtiene coordenadas de una direccion
  static Future<LatLng?> getLocationFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isEmpty) return null;

      final location = locations.first;
      return LatLng(location.latitude, location.longitude);
    } catch (_) {
      return null;
    }
  }
}
