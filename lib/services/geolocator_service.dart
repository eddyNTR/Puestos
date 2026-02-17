import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

/// Servicio centralizado para obtencion de ubicacion del usuario
class GeolocatorService {
  // Evita instanciacion
  GeolocatorService._();

  // Ubicacion por defecto (La Paz, Bolivia)
  static const defaultLocation = LatLng(-16.5, -68.1);

  /// Obtiene la ubicacion actual del usuario
  /// Solicita permisos si es necesario
  /// Retorna ubicacion por defecto si hay error
  static Future<LatLng> getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();

      // Solicitar permiso si fue denegado
      if (permission == LocationPermission.denied) {
        final result = await Geolocator.requestPermission();
        if (result == LocationPermission.denied) {
          return defaultLocation;
        }
      }

      // Obtener posicion actual con alta precision
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      return defaultLocation;
    }
  }
}
