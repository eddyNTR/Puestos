import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/puesto.dart';

/// Servicio centralizado para exportación de datos
/// Separa lógica de I/O de la UI
class ExportService {
  // Evita instancias
  ExportService._();

  /// Convierte puestos a mapa JSON con metadata
  static Map<String, dynamic> convertPuestosToJSON(List<Puesto> puestos) {
    return {
      'exportDate': DateTime.now().toIso8601String(),
      'totalPuestos': puestos.length,
      'puestos': puestos
          .map((p) => {'id': p.id, 'nombre': p.nombre, 'dias': p.dias})
          .toList(),
    };
  }

  /// Obtiene directorio para guardar archivo
  /// Intenta acceder a Downloads, fallback a documentos de la app
  static Future<Directory> getExportDirectory() async {
    try {
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        // Acceso a carpeta pública Downloads en Android
        return Directory(
          externalDir.path.replaceAll(
            'Android/data/com.example.horarios_emsa/files',
            'Download',
          ),
        );
      }
      throw Exception('No external storage');
    } catch (e) {
      // Fallback: documentos de la app
      return await getApplicationDocumentsDirectory();
    }
  }

  /// Guarda JSON en archivo y retorna ruta
  static Future<File> saveExportFile(
    Map<String, dynamic> jsonData,
    Directory directory,
  ) async {
    // Crear directorio si no existe
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    // Generar nombre con timestamp
    final timestamp = DateTime.now()
        .toString()
        .replaceAll(' ', '_')
        .replaceAll(':', '-');
    final fileName = 'puestos_export_$timestamp.json';
    final file = File('${directory.path}/$fileName');

    // Guardar contenido
    await file.writeAsString(jsonEncode(jsonData), mode: FileMode.write);
    return file;
  }

  /// Flujo completo: exporta puestos a JSON
  /// Retorna ruta del archivo generado o arroja excepción
  static Future<File> exportPuestosToJSON(List<Puesto> puestos) async {
    if (puestos.isEmpty) {
      throw Exception('No hay puestos para exportar');
    }

    final jsonData = convertPuestosToJSON(puestos);
    final directory = await getExportDirectory();
    return await saveExportFile(jsonData, directory);
  }

  /// Abre el archivo con la app predeterminada del dispositivo
  static Future<void> openExportFile(String filePath) async {
    await OpenFile.open(filePath);
  }
}
