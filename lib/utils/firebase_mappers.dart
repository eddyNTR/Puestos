import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/puesto.dart';

/// Convierte documentos Firestore en objetos Puesto
/// Centraliza la logica de mapeo para evitar duplicacion
class FirebaseMappers {
  FirebaseMappers._();

  /// Convierte un DocumentSnapshot en Puesto
  static Puesto documentToPuesto(DocumentSnapshot<Map<String, dynamic>> doc) {
    final diasRaw = doc['dias'] ?? {};
    final diasMap = (diasRaw as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, Map<String, dynamic>.from(v ?? {})),
    );

    return Puesto(
      id: int.tryParse(doc.id),
      nombre: doc['nombre'] ?? 'Sin nombre',
      dias: diasMap,
    );
  }

  /// Convierte una lista de QueryDocumentSnapshot en lista de Puestos
  static List<Puesto> documentsToList(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs.map((doc) => documentToPuesto(doc)).toList();
  }

  /// Convierte un Puesto en Map para guardar en Firestore
  static Map<String, dynamic> puestoToMap(Puesto puesto) {
    return {
      'nombre': puesto.nombre,
      'dias': puesto.dias,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Convierte un Puesto en Map con timestamp de creacion
  static Map<String, dynamic> puestoToMapWithCreatedAt(Puesto puesto) {
    return {...puestoToMap(puesto), 'createdAt': FieldValue.serverTimestamp()};
  }
}
