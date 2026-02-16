import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/puesto.dart';
import '../services/puesto_service.dart';
import '../services/sync_manager.dart';
import '../components/puesto_list.dart';
import '../components/confirmation_dialog.dart';
import 'puesto_form_screen.dart';

class PuestosScreen extends StatefulWidget {
  const PuestosScreen({super.key});

  @override
  State<PuestosScreen> createState() => _PuestosScreenState();
}

class _PuestosScreenState extends State<PuestosScreen> {
  Future<void> _deletePuesto(Puesto puesto) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: '¿Eliminar puesto?',
      message:
          '¿Estás seguro de que deseas eliminar "${puesto.nombre}"? Esta acción no se puede deshacer.',
      confirmText: 'Eliminar',
      confirmColor: const Color(0xFFFF0054),
    );

    if (confirmed) {
      await PuestoService.deletePuesto(puesto.id!);
      _loadPuestos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Puesto eliminado correctamente'),
            backgroundColor: Color(0xFF388E3C),
          ),
        );
      }
    }
  }

  List<Puesto> puestos = [];

  @override
  void initState() {
    super.initState();
    _loadPuestos();
  }

  Future<void> _loadPuestos() async {
    final data = await PuestoService.getPuestos();
    setState(() {
      puestos = data;
    });
  }

  void _goToForm([Puesto? puesto]) async {
    // Si es un nuevo puesto, mostrar confirmación
    if (puesto == null) {
      final confirmed = await ConfirmationDialog.show(
        context: context,
        title: 'Crear nuevo puesto',
        message: '¿Deseas crear un nuevo puesto de trabajo?',
        confirmText: 'Crear',
      );

      if (!confirmed) return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PuestoFormScreen(puesto: puesto)),
    );
    _loadPuestos();
  }

  Future<void> _exportToJSON() async {
    try {
      // Obtener lista de puestos
      final listaPuestos = puestos;

      if (listaPuestos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay puestos para exportar'),
            backgroundColor: Color(0xFFFF9800),
          ),
        );
        return;
      }

      // Convertir puestos a mapa
      final jsonData = {
        'exportDate': DateTime.now().toIso8601String(),
        'totalPuestos': listaPuestos.length,
        'puestos': listaPuestos
            .map((p) => {'id': p.id, 'nombre': p.nombre, 'dias': p.dias})
            .toList(),
      };

      // Obtener directorio de descargas (pública)
      Directory directory;
      try {
        // Intentar obtener la carpeta pública de Descargas
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          // Construir ruta a Descargas: /storage/emulated/0/Download
          directory = Directory(
            externalDir.path.replaceAll(
              'Android/data/com.example.horarios_emsa/files',
              'Download',
            ),
          );
        } else {
          throw Exception('No se acceder a almacenamiento externo');
        }
      } catch (e) {
        // Fallback a documentos de la app
        final appDocDir = await getApplicationDocumentsDirectory();
        directory = appDocDir;
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Crear nombre de archivo
      final timestamp = DateTime.now()
          .toString()
          .replaceAll(' ', '_')
          .replaceAll(':', '-');
      final fileName = 'puestos_export_$timestamp.json';
      final file = File('${directory.path}/$fileName');

      // Escribir archivo
      await file.writeAsString(jsonEncode(jsonData), mode: FileMode.write);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Datos exportados a: $fileName'),
            backgroundColor: const Color(0xFF388E3C),
            action: SnackBarAction(
              label: 'Abrir',
              textColor: Colors.white,
              onPressed: () {
                // Abrir el archivo con la app predeterminada
                OpenFile.open(file.path);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar: $e'),
            backgroundColor: Color(0xFFFF0054),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puestos de Trabajo'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'export') {
                _exportToJSON();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 8),
                    Text('Exportar datos'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: PuestoList(
        puestos: puestos,
        onTap: (puesto) => _goToForm(puesto),
        onDelete: _deletePuesto,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goToForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
