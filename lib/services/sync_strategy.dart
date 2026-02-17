import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/puesto.dart';
import 'retry_manager.dart';

class SyncStrategy {
  static final SyncStrategy _instance = SyncStrategy._internal();
  final _retryManager = RetryManager();
  final Set<int> _syncingPuestos = {};

  factory SyncStrategy() {
    return _instance;
  }

  SyncStrategy._internal();

  /// Sincroniza un puesto a Firebase con reintentos automáticos
  Future<void> syncPuestoToFirebase(Puesto puesto) async {
    // Evitar sincronizaciones duplicadas
    if (_syncingPuestos.contains(puesto.id)) {
      return;
    }

    _syncingPuestos.add(puesto.id!);
    _retryManager.cancelRetryTimer(puesto.id!);

    try {
      print('[SYNC] Iniciando sincronización de puesto: ${puesto.id}');

      final firestoreId = puesto.id.toString();
      final firestoreRef = FirebaseFirestore.instance
          .collection('puestos')
          .doc(firestoreId);

      print('[SYNC] Guardando en Firestore: $firestoreId');

      await firestoreRef
          .set({
            'nombre': puesto.nombre,
            'dias': puesto.dias,
            'localId': puesto.id,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException(
                'Timeout sincronizando puesto ${puesto.id}',
              );
            },
          );

      print('[SYNC] Puesto ${puesto.id} sincronizado correctamente');
      _syncingPuestos.remove(puesto.id);
      _retryManager.clearRetry(puesto.id!);
    } catch (e) {
      print('[SYNC] Error sincronizando puesto ${puesto.id}: $e');

      // Reintentar con retry manager
      _retryManager.scheduleRetry(puesto.id!, () {
        syncPuestoToFirebase(puesto);
      });

      _syncingPuestos.remove(puesto.id);
    }
  }

  /// Elimina un puesto de Firebase con reintentos
  Future<void> deletePuestoFromFirebase(int localId) async {
    try {
      print('[SYNC] Eliminando puesto $localId de Firebase');
      await FirebaseFirestore.instance
          .collection('puestos')
          .doc(localId.toString())
          .delete()
          .timeout(const Duration(seconds: 10));

      print('[SYNC] Puesto $localId eliminado correctamente');
      _syncingPuestos.remove(localId);
      _retryManager.clearRetry(localId);
    } catch (e) {
      print('[SYNC] Error eliminando puesto de Firebase: $e');

      // Reintentar eliminacion
      _retryManager.scheduleRetry(localId, () {
        deletePuestoFromFirebase(localId);
      });
    }
  }

  /// Obtiene cantidad de puestos sincronizándose actualmente
  int get activeSyncs => _syncingPuestos.length;

  /// Limpia estado de sincronización
  void clearActiveSyncs() {
    _syncingPuestos.clear();
  }
}
