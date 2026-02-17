import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static const LatLng defaultLocation = LatLng(-16.5, -68.1); // La Paz

  /// Obtiene la ubicación actual del usuario
  static Future<LatLng> getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        final result = await Geolocator.requestPermission();
        if (result == LocationPermission.denied) {
          return defaultLocation;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      return defaultLocation;
    }
  }

  /// Obtiene la dirección de una coordenada
  static Future<String> getAddressFromCoordinates(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        return 'Dirección no encontrada';
      }

      final p = placemarks.first;
      return _buildAddress(p);
    } catch (_) {
      return 'Dirección no encontrada';
    }
  }

  /// Obtiene coordenadas de una dirección
  static Future<LatLng?> getLocationFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isEmpty) return null;

      final loc = locations.first;
      return LatLng(loc.latitude, loc.longitude);
    } catch (_) {
      return null;
    }
  }

  /// Construye la dirección formateada a partir de los datos del Placemark
  static String _buildAddress(Placemark p) {
    final validAddresses = _getValidAddresses(p);

    if (validAddresses.length >= 2) {
      return '${validAddresses[0]} y ${validAddresses[1]}';
    } else if (validAddresses.length == 1) {
      return validAddresses[0];
    } else {
      return '${p.locality ?? 'Ubicación'} ${p.postalCode ?? ''}'.trim();
    }
  }

  /// Filtra direcciones válidas (evita códigos plus y valores vacíos)
  static List<String> _getValidAddresses(Placemark p) {
    final addresses = [
      p.thoroughfare,
      p.street,
      p.name,
      p.subLocality,
      p.locality,
    ];

    return addresses
        .where((addr) => _isValidAddress(addr))
        .cast<String>()
        .toList();
  }

  /// Valida que una dirección no sea solo un código plus
  static bool _isValidAddress(String? text) {
    if (text == null || text.isEmpty) return false;

    final plusPattern = RegExp(r'^[A-Z0-9]{2,4}\+[A-Z0-9]{2,4}$');
    return !plusPattern.hasMatch(text) && text.length > 2;
  }
}
