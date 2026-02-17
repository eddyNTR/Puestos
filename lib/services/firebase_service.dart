import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/puesto.dart';
import 'puesto_firebase_service.dart';
import 'backup_firebase_service.dart';
import 'sync_firebase_service.dart';

/// Servicio principal de Firebase
/// Inicializa Firestore y proporciona acceso a servicios especializados
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  late FirebaseFirestore _firestore;
  late PuestoFirebaseService puestoService;
  late BackupFirebaseService backupService;
  late SyncFirebaseService syncService;

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  /// Inicializa Firebase y todos los servicios
  void initialize() {
    _firestore = FirebaseFirestore.instance;
    puestoService = PuestoFirebaseService();
    backupService = BackupFirebaseService();
    syncService = SyncFirebaseService();
  }

  FirebaseFirestore get firestore => _firestore;

  // === METODOS DELEGADOS (compatibilidad hacia atras) ===

  /// Crear nuevo puesto
  Future<String> createPuesto(Puesto puesto) => puestoService.create(puesto);

  /// Obtener todos los puestos
  Future<List<Puesto>> getAllPuestos() => puestoService.getAll();

  /// Obtener puesto por ID
  Future<Puesto?> getPuestoById(String id) => puestoService.getById(id);

  /// Actualizar puesto
  Future<void> updatePuesto(Puesto puesto) => puestoService.update(puesto);

  /// Eliminar puesto
  Future<void> deletePuesto(String id) => puestoService.delete(id);

  /// Stream de puestos en tiempo real
  Stream<List<Puesto>> getPuestosStream() => puestoService.getStream();

  /// Sincronizar datos locales con Firebase
  Future<void> syncLocalDataToFirebase(List<Puesto> localPuestos) =>
      syncService.syncLocalToFirebase(localPuestos);

  /// Guardar backup completo
  Future<void> saveCompleteBackup(List<Puesto> puestos) =>
      backupService.saveBackup(puestos);

  /// Obtener backup mas reciente
  Future<Map<String, dynamic>?> getLatestBackup() => backupService.getLatest();

  /// Obtener backup por ID
  Future<Map<String, dynamic>?> getBackupById(String backupId) =>
      backupService.getById(backupId);

  /// Listar todos los backups
  Future<List<Map<String, dynamic>>> getAllBackups() => backupService.getAll();
}
