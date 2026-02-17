import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/puesto.dart';
import 'puesto_service.dart';

class FirebaseSyncReader {
  static final FirebaseSyncReader _instance = FirebaseSyncReader._internal();

  factory FirebaseSyncReader() {
    return _instance;
  }

  FirebaseSyncReader._internal();

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
      print('[SYNC] Error obteniendo puestos de Firebase: $e');
      return [];
    }
  }

  /// Sincroniza puestos desde Firebase a SQLite local
  /// Útil para traer datos existentes en la nube al dispositivo
  Future<void> syncFirebaseToLocal() async {
    try {
      print('[SYNC] Iniciando descarga de puestos desde Firebase...');

      final firebasePuestos = await getFirebasePuestos();

      if (firebasePuestos.isEmpty) {
        print('[SYNC] No hay puestos en Firebase para descargar');
        return;
      }

      print('[SYNC] Descargados ${firebasePuestos.length} puestos de Firebase');

      // Obtener puestos locales para detectar cambios
      final localPuestos = await PuestoService.getAllPuestos();
      final localIds = {for (var p in localPuestos) p.id};

      // Guardar/actualizar puestos de Firebase en SQLite
      for (final firebasePuesto in firebasePuestos) {
        if (firebasePuesto.id != null) {
          if (localIds.contains(firebasePuesto.id)) {
            // Actualizar puesto existente
            print('[SYNC] Actualizando puesto ${firebasePuesto.id}...');
            await PuestoService.updatePuesto(firebasePuesto);
          } else {
            // Insertar nuevo puesto
            print('[SYNC] Insertando nuevo puesto ${firebasePuesto.id}...');
            await PuestoService.insertPuestoWithId(firebasePuesto);
          }
        }
      }

      print('[SYNC] Sincronización Firebase-SQLite completada');
    } catch (e) {
      print('[SYNC] Error sincronizando desde Firebase: $e');
    }
  }
}
