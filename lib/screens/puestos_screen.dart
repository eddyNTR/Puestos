import 'package:flutter/material.dart';
import '../models/puesto.dart';
import '../services/puesto_service.dart';
import '../services/sync_manager.dart';
import '../services/export_service.dart';
import '../components/puesto_list.dart';
import '../components/confirmation_dialog.dart';
import '../utils/ui_helper.dart';
import 'puesto_form_screen.dart';

class PuestosScreen extends StatefulWidget {
  const PuestosScreen({super.key});

  @override
  State<PuestosScreen> createState() => _PuestosScreenState();
}

class _PuestosScreenState extends State<PuestosScreen> {
  // Lista de puestos cargados
  List<Puesto> puestos = [];

  @override
  void initState() {
    super.initState();
    _loadPuestos();
  }

  // Carga puestos desde BD
  Future<void> _loadPuestos() async {
    final data = await PuestoService.getPuestos();
    setState(() {
      puestos = data;
    });
  }

  // Elimina un puesto con confirmación
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
        UIHelper.showSuccess(context, 'Puesto eliminado correctamente');
      }
    }
  }

  // Navega a formulario (crear o editar), recarga después
  void _goToForm([Puesto? puesto]) async {
    // Mostrar confirmación si es nuevo
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
    _loadPuestos(); // Recarga lista después de crear/editar
  }

  // Exporta puestos a JSON usando ExportService
  Future<void> _exportToJSON() async {
    try {
      final file = await ExportService.exportPuestosToJSON(puestos);
      if (mounted) {
        UIHelper.showSnackBar(
          context,
          'Datos exportados a: ${file.path.split('/').last}',
          const Color(0xFF388E3C),
          actionLabel: 'Abrir',
          onAction: () => ExportService.openExportFile(file.path),
        );
      }
    } catch (e) {
      if (mounted) {
        UIHelper.showError(context, 'Error al exportar: $e');
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
