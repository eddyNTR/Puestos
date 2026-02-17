import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/puesto.dart';
import '../utils/firebase_mappers.dart';

/// Servicio para operaciones CRUD de puestos en Firestore
class PuestoFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference<Map<String, dynamic>> _puestosCollection;

  PuestoFirebaseService() {
    _puestosCollection = _firestore.collection('puestos');
  }

  /// Crear nuevo puesto en Firestore
  Future<String> create(Puesto puesto) async {
    try {
      final docRef = await _puestosCollection.add(
        FirebaseMappers.puestoToMapWithCreatedAt(puesto),
      );
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear puesto: $e');
    }
  }

  /// Obtener todos los puestos ordenados por fecha
  Future<List<Puesto>> getAll() async {
    try {
      final snapshot = await _puestosCollection
          .orderBy('createdAt', descending: true)
          .get();
      return FirebaseMappers.documentsToList(snapshot.docs);
    } catch (e) {
      throw Exception('Error al obtener puestos: $e');
    }
  }

  /// Obtener puesto por ID
  Future<Puesto?> getById(String id) async {
    try {
      final doc = await _puestosCollection.doc(id).get();
      if (!doc.exists) return null;
      return FirebaseMappers.documentToPuesto(doc);
    } catch (e) {
      throw Exception('Error al obtener puesto: $e');
    }
  }

  /// Actualizar puesto existente
  Future<void> update(Puesto puesto) async {
    try {
      await _puestosCollection
          .doc(puesto.id.toString())
          .update(FirebaseMappers.puestoToMap(puesto));
    } catch (e) {
      throw Exception('Error al actualizar puesto: $e');
    }
  }

  /// Eliminar un puesto
  Future<void> delete(String id) async {
    try {
      await _puestosCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar puesto: $e');
    }
  }

  /// Stream en tiempo real de todos los puestos
  Stream<List<Puesto>> getStream() {
    return _puestosCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => FirebaseMappers.documentsToList(snapshot.docs));
  }

  /// Obtiene los IDs de todos los puestos (validar duplicados)
  Future<Set<int?>> getAllIds() async {
    try {
      final snapshot = await _puestosCollection.get();
      return snapshot.docs.map((doc) => int.tryParse(doc.id)).toSet();
    } catch (e) {
      throw Exception('Error al obtener IDs: $e');
    }
  }
}
