import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';
import 'app_config.dart';
import '../services/firebase_service.dart';
import '../services/sync_manager.dart';

class AppInitializer {
  static final AppInitializer _instance = AppInitializer._internal();

  factory AppInitializer() {
    return _instance;
  }

  AppInitializer._internal();

  /// Inicializa toda la aplicación (Firebase, Config, Sync)
  Future<void> initialize() async {
    await _loadAppConfig();
    await _initializeFirebase();
    await _initializeServices();
  }

  /// Carga configuración de la aplicación
  Future<void> _loadAppConfig() async {
    try {
      await AppConfig.load();
      print('[APP] AppConfig cargado');
    } catch (e) {
      print('[WARN] Error cargando AppConfig: $e');
    }
  }

  /// Inicializa Firebase y verifica conexión
  Future<void> _initializeFirebase() async {
    try {
      print('[APP] Inicializando Firebase...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('[APP] Firebase inicializado correctamente');

      // Verificar que Firestore está disponible
      final firestore = FirebaseFirestore.instance;
      print('[APP] Firestore instance obtenida: $firestore');
    } catch (e) {
      print('[ERROR] Error inicializando Firebase: $e');
      rethrow;
    }
  }

  /// Inicializa servicios (FirebaseService, SyncManager)
  Future<void> _initializeServices() async {
    try {
      FirebaseService().initialize();
      print('[APP] FirebaseService inicializado');

      SyncManager().initialize();
      print('[APP] SyncManager inicializado');

      // Sincronizar datos de Firebase a SQLite local
      print('[APP] Sincronizando puestos de Firebase a dispositivo...');
      await SyncManager().syncFirebaseToLocal();
      print('[APP] Sincronización completada');

      print('[APP] LISTO PARA SINCRONIZAR DATOS');
    } catch (e) {
      print('[ERROR] Error inicializando servicios: $e');
      rethrow;
    }
  }
}
