import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/puesto.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  late FirebaseFirestore _firestore;
  late CollectionReference<Map<String, dynamic>> _puestosCollection;

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  void initialize() {
    _firestore = FirebaseFirestore.instance;
    _puestosCollection = _firestore.collection('puestos');
  }

  // Crear nuevo puesto en Firestore
  Future<String> createPuesto(Puesto puesto) async {
    try {
      final docRef = await _puestosCollection.add({
        'nombre': puesto.nombre,
        'dias': puesto.dias,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear puesto en Firebase: $e');
    }
  }

  // Obtener todos los puestos
  Future<List<Puesto>> getAllPuestos() async {
    try {
      final snapshot = await _puestosCollection
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final diasRaw = doc['dias'] ?? {};
        final diasMap = (diasRaw as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, Map<String, dynamic>.from(v ?? {})),
        );
        return Puesto(
          id: int.tryParse(doc.id),
          nombre: doc['nombre'],
          dias: diasMap,
        );
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener puestos de Firebase: $e');
    }
  }

  // Obtener puesto por ID
  Future<Puesto?> getPuestoById(String id) async {
    try {
      final doc = await _puestosCollection.doc(id).get();
      if (!doc.exists) return null;

      final diasRaw = doc['dias'] ?? {};
      final diasMap = (diasRaw as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, Map<String, dynamic>.from(v ?? {})),
      );

      return Puesto(
        id: int.tryParse(doc.id),
        nombre: doc['nombre'],
        dias: diasMap,
      );
    } catch (e) {
      throw Exception('Error al obtener puesto: $e');
    }
  }

  // Actualizar puesto
  Future<void> updatePuesto(Puesto puesto) async {
    try {
      await _puestosCollection.doc(puesto.id.toString()).update({
        'nombre': puesto.nombre,
        'dias': puesto.dias,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al actualizar puesto en Firebase: $e');
    }
  }

  // Eliminar puesto
  Future<void> deletePuesto(String id) async {
    try {
      await _puestosCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar puesto de Firebase: $e');
    }
  }

  // Stream de puestos en tiempo real
  Stream<List<Puesto>> getPuestosStream() {
    return _puestosCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final diasRaw = doc['dias'] ?? {};
            final diasMap = (diasRaw as Map<String, dynamic>).map(
              (k, v) => MapEntry(k, Map<String, dynamic>.from(v ?? {})),
            );
            return Puesto(
              id: int.tryParse(doc.id),
              nombre: doc['nombre'],
              dias: diasMap,
            );
          }).toList(),
        );
  }

  // Sincronizar datos locales (SQLite) con Firestore
  Future<void> syncLocalDataToFirebase(List<Puesto> localPuestos) async {
    try {
      // Obtener IDs de Firestore actuales
      final firebasePuestos = await getAllPuestos();
      final firebaseIds = firebasePuestos.map((p) => p.id).toSet();

      // Agregar puestos locales que no están en Firebase
      for (final puesto in localPuestos) {
        if (!firebaseIds.contains(puesto.id)) {
          await createPuesto(puesto);
        } else {
          // Actualizar si existe
          final existente = await getPuestoById(puesto.id.toString());
          if (existente != null && existente.nombre != puesto.nombre) {
            await updatePuesto(puesto);
          }
        }
      }
    } catch (e) {
      throw Exception('Error al sincronizar datos: $e');
    }
  }

  /// Guarda un backup completo de todos los puestos en Firestore
  Future<void> saveCompleteBackup(List<Puesto> puestos) async {
    try {
      final backupDate = DateTime.now().toIso8601String();

      // Estructura completa como en tu JSON
      final backupData = {
        'exportDate': backupDate,
        'totalPuestos': puestos.length,
        'puestos': puestos
            .map((p) => {'id': p.id, 'nombre': p.nombre, 'dias': p.dias})
            .toList(),
      };

      // Guardar en colección "backups" con timestamp en el ID
      final backupId = 'backup_${DateTime.now().millisecondsSinceEpoch}';
      await _firestore.collection('backups').doc(backupId).set(backupData);

      // También guardar el backup más reciente en un documento fijo para fácil acceso
      await _firestore.collection('backups').doc('latest').set({
        'exportDate': backupDate,
        'totalPuestos': puestos.length,
        'timestamp': FieldValue.serverTimestamp(),
        'backupId': backupId,
      });

      print('✓ Backup completo guardado: $backupId');
    } catch (e) {
      throw Exception('Error al guardar backup: $e');
    }
  }

  /// Obtiene el backup más reciente
  Future<Map<String, dynamic>?> getLatestBackup() async {
    try {
      final doc = await _firestore.collection('backups').doc('latest').get();
      return doc.data();
    } catch (e) {
      print('Error obteniendo backup: $e');
      return null;
    }
  }

  /// Obtiene un backup específico por ID
  Future<Map<String, dynamic>?> getBackupById(String backupId) async {
    try {
      final doc = await _firestore.collection('backups').doc(backupId).get();
      return doc.data();
    } catch (e) {
      print('Error obteniendo backup: $e');
      return null;
    }
  }

  /// Lista todos los backups disponibles
  Future<List<Map<String, dynamic>>> getAllBackups() async {
    try {
      final snapshot = await _firestore
          .collection('backups')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .where((doc) => doc.id != 'latest')
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      print('Error listando backups: $e');
      return [];
    }
  }
}
