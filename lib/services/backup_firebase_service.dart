import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/puesto.dart';

/// Servicio para gestion de backups en Firestore
class BackupFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _backupsCollection = 'backups';
  static const String _latestDocId = 'latest';

  /// Guarda un backup completo de todos los puestos
  Future<void> saveBackup(List<Puesto> puestos) async {
    try {
      final backupDate = DateTime.now().toIso8601String();
      final backupId = 'backup_${DateTime.now().millisecondsSinceEpoch}';

      // Estructura completa del backup
      final backupData = {
        'exportDate': backupDate,
        'totalPuestos': puestos.length,
        'puestos': puestos
            .map((p) => {'id': p.id, 'nombre': p.nombre, 'dias': p.dias})
            .toList(),
      };

      // Guardar backup con ID especifico
      await _firestore
          .collection(_backupsCollection)
          .doc(backupId)
          .set(backupData);

      // Guardar referencia al backup mas reciente
      await _firestore.collection(_backupsCollection).doc(_latestDocId).set({
        'exportDate': backupDate,
        'totalPuestos': puestos.length,
        'timestamp': FieldValue.serverTimestamp(),
        'backupId': backupId,
      });

      print('OK - Backup guardado: $backupId');
    } catch (e) {
      throw Exception('Error al guardar backup: $e');
    }
  }

  /// Obtiene el backup mas reciente
  Future<Map<String, dynamic>?> getLatest() async {
    try {
      final doc = await _firestore
          .collection(_backupsCollection)
          .doc(_latestDocId)
          .get();
      return doc.data();
    } catch (e) {
      print('Error obteniendo backup: $e');
      return null;
    }
  }

  /// Obtiene un backup especifico por ID
  Future<Map<String, dynamic>?> getById(String backupId) async {
    try {
      final doc = await _firestore
          .collection(_backupsCollection)
          .doc(backupId)
          .get();
      return doc.data();
    } catch (e) {
      print('Error obteniendo backup: $e');
      return null;
    }
  }

  /// Lista todos los backups disponibles (sin 'latest')
  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      final snapshot = await _firestore
          .collection(_backupsCollection)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .where((doc) => doc.id != _latestDocId)
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      print('Error listando backups: $e');
      return [];
    }
  }

  /// Elimina un backup especifico
  Future<void> deleteBackup(String backupId) async {
    try {
      await _firestore.collection(_backupsCollection).doc(backupId).delete();
    } catch (e) {
      throw Exception('Error al eliminar backup: $e');
    }
  }
}
