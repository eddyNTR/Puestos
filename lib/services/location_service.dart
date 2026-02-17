import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'geolocator_service.dart';
import 'geocoding_service.dart';

/// Servicio unificado de ubicacion y geocoding
/// Orquesta GeolocatorService y GeocodingService
class LocationService {
  // Evita instanciacion
  LocationService._();

  // Ubicacion por defecto
  static LatLng get defaultLocation => GeolocatorService.defaultLocation;

  /// Obtiene ubicacion actual del usuario
  static Future<LatLng> getCurrentLocation() =>
      GeolocatorService.getCurrentLocation();

  /// Obtiene direccion a partir de coodenadas
  static Future<String> getAddressFromCoordinates(LatLng position) =>
      GeocodingService.getAddressFromCoordinates(position);

  /// Obtiene coordenadas a partir de direccion
  static Future<LatLng?> getLocationFromAddress(String address) =>
      GeocodingService.getLocationFromAddress(address);
}
