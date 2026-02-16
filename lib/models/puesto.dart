import 'dart:convert';

class Puesto {
  int? id;
  String nombre;
  Map<String, Map<String, dynamic>>
  dias; // clave: día, valor: {direccion, lat, lng}

  Puesto({this.id, required this.nombre, required this.dias});

  factory Puesto.fromMap(Map<String, dynamic> map) {
    // Si 'dias' viene como String (de SQLite), decodificarlo
    final diasRaw = map['dias'];
    Map<String, Map<String, dynamic>> diasMap;
    if (diasRaw is String) {
      final decoded = jsonDecode(diasRaw);
      diasMap = (decoded as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, Map<String, dynamic>.from(v)),
      );
    } else if (diasRaw is Map<String, dynamic>) {
      diasMap = diasRaw.map(
        (k, v) => MapEntry(k, Map<String, dynamic>.from(v)),
      );
    } else {
      diasMap = {};
    }
    return Puesto(id: map['id'], nombre: map['nombre'], dias: diasMap);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'nombre': nombre, 'dias': jsonEncode(dias)};
  }

  Map<String, dynamic> toMapForInsert() {
    return {'nombre': nombre, 'dias': jsonEncode(dias)};
  }

  Map<String, dynamic> toMapForUpdate() {
    return {'nombre': nombre, 'dias': jsonEncode(dias), 'id': id};
  }
}
