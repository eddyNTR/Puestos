import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/puesto.dart';

class BatchSyncService {
  static final BatchSyncService _instance = BatchSyncService._internal();

  factory BatchSyncService() {
    return _instance;
  }

  BatchSyncService._internal();

  /// Sincroniza múltiples puestos en un batch
  Future<void> syncMultiplePuestosToFirebase(List<Puesto> puestos) async {
    if (puestos.isEmpty) {
      print('[SYNC] Batch vacío, sin cambios');
      return;
    }

    try {
      print('[SYNC] Sincronizando batch de ${puestos.length} puestos...');

      final batch = FirebaseFirestore.instance.batch();

      for (final puesto in puestos) {
        final firestoreId = puesto.id.toString();
        final docRef = FirebaseFirestore.instance
            .collection('puestos')
            .doc(firestoreId);

        batch.set(docRef, {
          'nombre': puesto.nombre,
          'dias': puesto.dias,
          'localId': puesto.id,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await batch.commit();
      print('[SYNC] Sincronización de ${puestos.length} puestos completada');
    } catch (e) {
      print('[SYNC] Error en sincronización batch: $e');
      rethrow;
    }
  }

  /// Sincroniza todos los puestos locales a Firebase
  Future<bool> syncAllLocalToFirebase(List<Puesto> localPuestos) async {
    try {
      print(
        '[SYNC] Iniciando sincronización de ${localPuestos.length} puestos...',
      );
      await syncMultiplePuestosToFirebase(localPuestos);
      return true;
    } catch (e) {
      print('[SYNC] Error en sincronización general: $e');
      return false;
    }
  }
}
