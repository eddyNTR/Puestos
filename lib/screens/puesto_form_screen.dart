import 'package:flutter/material.dart';
import '../models/puesto.dart';
import '../services/puesto_service.dart';
import '../components/puesto_form.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PuestoFormScreen extends StatefulWidget {
  final Puesto? puesto;
  const PuestoFormScreen({super.key, this.puesto});

  @override
  State<PuestoFormScreen> createState() => _PuestoFormScreenState();
}

class _PuestoFormScreenState extends State<PuestoFormScreen> {
  late TextEditingController nombreController;
  late Map<String, TextEditingController> direccionControllers;
  late Map<String, LatLng?> coordenadas;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.puesto?.nombre ?? '');
    direccionControllers = {};
    coordenadas = {};
    for (var dia in [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ]) {
      final data = widget.puesto?.dias[dia] ?? {};
      direccionControllers[dia] = TextEditingController(
        text: data['direccion'] ?? '',
      );
      if (data['lat'] != null && data['lng'] != null) {
        coordenadas[dia] = LatLng(data['lat'], data['lng']);
      } else {
        coordenadas[dia] = null;
      }
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    direccionControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  void _save() async {
    // Validar que el nombre no esté vacío
    if (nombreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre del puesto no puede estar vacío'),
          backgroundColor: Color(0xFFFF0054),
        ),
      );
      return;
    }

    final dias = <String, Map<String, dynamic>>{};
    for (var dia in direccionControllers.keys) {
      dias[dia] = {
        'direccion': direccionControllers[dia]?.text ?? '',
        'lat': (direccionControllers[dia]?.text.isNotEmpty ?? false)
            ? (coordenadas[dia]?.latitude)
            : null,
        'lng': (direccionControllers[dia]?.text.isNotEmpty ?? false)
            ? (coordenadas[dia]?.longitude)
            : null,
      };
    }
    final puesto = Puesto(
      id: widget.puesto?.id,
      nombre: nombreController.text,
      dias: dias,
    );

    try {
      if (puesto.id == null) {
        await PuestoService.insertPuesto(puesto);
      } else {
        await PuestoService.updatePuesto(puesto);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Puesto guardado correctamente'),
            backgroundColor: Color(0xFF388E3C),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
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
        title: Text(widget.puesto == null ? 'Nuevo Puesto' : 'Editar Puesto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PuestoForm(
          nombreController: nombreController,
          direccionControllers: direccionControllers,
          coordenadas: coordenadas,
          onSave: (coords) {
            setState(() {
              coordenadas = coords;
            });
            _save();
          },
        ),
      ),
    );
  }
}
