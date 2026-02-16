import 'package:flutter/material.dart';
import '../models/puesto.dart';
import '../services/puesto_service.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Puestos de Trabajo')),
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
