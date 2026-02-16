import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/puesto.dart';
import 'firebase_service.dart';

class SyncManager {
  static final SyncManager _instance = SyncManager._internal();

  // Control de reintentos
  final Map<int, Timer?> _retryTimers = {};
  final Set<int> _syncingPuestos = {};

  factory SyncManager() {
    return _instance;
  }

  SyncManager._internal();

  void initialize() {
    // Inicialización completada
  }

  /// Cancela timer de reintento si existe
  void _cancelRetryTimer(int puestoId) {
    _retryTimers[puestoId]?.cancel();
    _retryTimers.remove(puestoId);
  }

  /// Sincroniza un puesto a Firebase con reintentos automáticos
  Future<void> syncPuestoToFirebase(Puesto puesto) async {
    // Evitar sincronizaciones duplicadas
    if (_syncingPuestos.contains(puesto.id)) {
      return;
    }

    _syncingPuestos.add(puesto.id!);
    _cancelRetryTimer(puesto.id!);

    try {
      print('🔄 [SYNC] Iniciando sincronización de puesto: ${puesto.id}');

      final firestoreId = puesto.id.toString();
      final firestoreRef = FirebaseFirestore.instance
          .collection('puestos')
          .doc(firestoreId);

      print('🔄 [SYNC] Guardando en Firestore: $firestoreId');

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

      print('✓ [SYNC] Puesto ${puesto.id} sincronizado correctamente');
      _syncingPuestos.remove(puesto.id);
    } catch (e) {
      print('❌ [SYNC] Error sincronizando puesto ${puesto.id}: $e');

      // Reintentar cada 30 segundos
      _retryTimers[puesto.id!] = Timer(const Duration(seconds: 30), () {
        print('🔄 [RETRY] Reintentando puesto ${puesto.id}...');
        syncPuestoToFirebase(puesto);
      });

      _syncingPuestos.remove(puesto.id);
    }
  }

  /// Elimina un puesto de Firebase con reintentos
  Future<void> deletePuestoFromFirebase(int localId) async {
    try {
      print('🗑️ [SYNC] Eliminando puesto $localId de Firebase');
      await FirebaseFirestore.instance
          .collection('puestos')
          .doc(localId.toString())
          .delete()
          .timeout(const Duration(seconds: 10));

      print('✓ [SYNC] Puesto $localId eliminado correctamente');
      _syncingPuestos.remove(localId);
    } catch (e) {
      print('❌ [SYNC] Error eliminando puesto de Firebase: $e');

      // Reintentar eliminación
      _retryTimers[localId] = Timer(const Duration(seconds: 30), () {
        print('🔄 [RETRY] Reintentando eliminar puesto $localId...');
        deletePuestoFromFirebase(localId);
      });
    }
  }

  /// Obtiene puestos de Firebase (para sincronización inversa)
  Future<List<Puesto>> getFirebasePuestos() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('puestos')
          .get()
          .timeout(const Duration(seconds: 10));

      return snapshot.docs.map((doc) {
        final diasRaw = doc['dias'] ?? {};
        final diasMap = (diasRaw as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, Map<String, dynamic>.from(v ?? {})),
        );
        return Puesto(
          id: int.tryParse(doc.id),
          nombre: doc['nombre'] ?? '',
          dias: diasMap,
        );
      }).toList();
    } catch (e) {
      print('❌ [SYNC] Error obteniendo puestos de Firebase: $e');
      return [];
    }
  }

  /// Sincroniza múltiples puestos (batch)
  Future<void> syncMultiplePuestosToFirebase(List<Puesto> puestos) async {
    try {
      print('🔄 [SYNC] Sincronizando batch de ${puestos.length} puestos...');

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
      print('✓ [SYNC] Sincronización de ${puestos.length} puestos completada');
    } catch (e) {
      print('❌ [SYNC] Error en sincronización batch: $e');
    }
  }

  /// Sincroniza todos los puestos locales a Firebase
  Future<bool> syncAllLocalToFirebase(List<Puesto> localPuestos) async {
    try {
      print(
        '🔄 [SYNC] Iniciando sincronización de ${localPuestos.length} puestos...',
      );
      await syncMultiplePuestosToFirebase(localPuestos);
      return true;
    } catch (e) {
      print('❌ [SYNC] Error en sincronización general: $e');
      return false;
    }
  }

  /// Guarda un backup completo con toda la estructura
  Future<bool> saveFullBackupToFirebase(List<Puesto> puestos) async {
    try {
      print(
        '💾 [BACKUP] Guardando backup completo de ${puestos.length} puestos...',
      );
      final firebaseService = FirebaseService();
      await firebaseService.saveCompleteBackup(puestos);
      return true;
    } catch (e) {
      print('❌ [BACKUP] Error en backup: $e');
      return false;
    }
  }

  /// Limpia todos los timers de reintento (útil al cerrar app)
  void dispose() {
    print('🧹 [SYNC] Limpiando timers de sincronización...');
    for (final timer in _retryTimers.values) {
      timer?.cancel();
    }
    _retryTimers.clear();
    _syncingPuestos.clear();
  }
}
