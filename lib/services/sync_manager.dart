import '../models/puesto.dart';
import 'firebase_service.dart';
import 'sync_strategy.dart';
import 'batch_sync_service.dart';
import 'firebase_sync_reader.dart';
import 'retry_manager.dart';

/// Orquestador centralizado de todas las operaciones de sincronización
/// Delega a servicios especializados siguiendo Facade pattern
class SyncManager {
  static final SyncManager _instance = SyncManager._internal();

  final _syncStrategy = SyncStrategy();
  final _batchSyncService = BatchSyncService();
  final _firebaseSyncReader = FirebaseSyncReader();
  final _retryManager = RetryManager();

  factory SyncManager() {
    return _instance;
  }

  SyncManager._internal();

  void initialize() {
    print('[SYNC] Manager inicializado');
  }

  /// Sincroniza un puesto a Firebase con reintentos automáticos
  Future<void> syncPuestoToFirebase(Puesto puesto) =>
      _syncStrategy.syncPuestoToFirebase(puesto);

  /// Sincroniza puestos desde Firebase a SQLite local
  Future<void> syncFirebaseToLocal() =>
      _firebaseSyncReader.syncFirebaseToLocal();

  /// Elimina un puesto de Firebase con reintentos
  Future<void> deletePuestoFromFirebase(int localId) =>
      _syncStrategy.deletePuestoFromFirebase(localId);

  /// Obtiene puestos de Firebase
  Future<List<Puesto>> getFirebasePuestos() =>
      _firebaseSyncReader.getFirebasePuestos();

  /// Sincroniza múltiples puestos (batch)
  Future<void> syncMultiplePuestosToFirebase(List<Puesto> puestos) =>
      _batchSyncService.syncMultiplePuestosToFirebase(puestos);

  /// Sincroniza todos los puestos locales a Firebase
  Future<bool> syncAllLocalToFirebase(List<Puesto> localPuestos) =>
      _batchSyncService.syncAllLocalToFirebase(localPuestos);

  /// Guarda un backup completo con toda la estructura
  Future<bool> saveFullBackupToFirebase(List<Puesto> puestos) async {
    try {
      print(
        '[BACKUP] Guardando backup completo de ${puestos.length} puestos...',
      );
      final firebaseService = FirebaseService();
      await firebaseService.saveCompleteBackup(puestos);
      return true;
    } catch (e) {
      print('[BACKUP] Error en backup: $e');
      return false;
    }
  }

  /// Limpia todos los timers de reintento (útil al cerrar app)
  void dispose() {
    _retryManager.disposeAll();
    _syncStrategy.clearActiveSyncs();
  }
}
