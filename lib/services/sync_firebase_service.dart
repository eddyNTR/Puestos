import '../models/puesto.dart';
import 'puesto_firebase_service.dart';

/// Servicio de sincronizacion bidireccional SQLite-Firebase
class SyncFirebaseService {
  final PuestoFirebaseService _puestoService = PuestoFirebaseService();

  /// Sincroniza puestos locales (SQLite) con Firebase
  /// Agrega puestos nuevos y actualiza existentes
  Future<void> syncLocalToFirebase(List<Puesto> localPuestos) async {
    try {
      // Obtener IDs de Firestore
      final firebaseIds = await _puestoService.getAllIds();

      // Procesar cada puesto local
      for (final puesto in localPuestos) {
        if (!firebaseIds.contains(puesto.id)) {
          // Puesto nuevo - crear en Firebase
          await _puestoService.create(puesto);
        } else {
          // Puesto existente - actualizar
          await _actualizarSiCambio(puesto);
        }
      }

      print('OK - Sincronizacion completada: ${localPuestos.length} puestos');
    } catch (e) {
      throw Exception('Error al sincronizar: $e');
    }
  }

  /// Obtiene todos los puestos de Firebase
  Future<List<Puesto>> getFirebasePuestos() async {
    return await _puestoService.getAll();
  }

  /// Stream de cambios en tiempo real desde Firebase
  Stream<List<Puesto>> getChangesStream() {
    return _puestoService.getStream();
  }

  /// Helper privado: actualiza solo si el contenido cambio
  Future<void> _actualizarSiCambio(Puesto local) async {
    final remoto = await _puestoService.getById(local.id.toString());
    if (remoto != null && remoto.nombre != local.nombre) {
      await _puestoService.update(local);
    }
  }
}
