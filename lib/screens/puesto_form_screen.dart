import 'package:flutter/material.dart';
import '../models/puesto.dart';
import '../services/puesto_service.dart';
import '../components/puesto_form.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Lista de días usada para validar y crear campos dinámicos
const _daysOfWeek = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];

class PuestoFormScreen extends StatefulWidget {
  final Puesto? puesto;
  const PuestoFormScreen({super.key, this.puesto});

  @override
  State<PuestoFormScreen> createState() => _PuestoFormScreenState();
}

class _PuestoFormScreenState extends State<PuestoFormScreen> {
  // Controllers para entrada de usuario
  late TextEditingController nombreController;
  late Map<String, TextEditingController>
  direccionControllers; // Un controller por día
  late Map<String, LatLng?> coordenadas; // Coordenadas lat/lng por día

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.puesto?.nombre ?? '');
    _initializeDays(); // Prepara los campos para cada día
  }

  /// Inicializa los controllers y coordenadas para cada día de la semana
  /// Si es edición: carga datos existentes del puesto
  /// Si es creación: campos vacíos listos para llenar
  void _initializeDays() {
    direccionControllers = {};
    coordenadas = {};
    for (var dia in _daysOfWeek) {
      final data =
          widget.puesto?.dias[dia] ?? {}; // Obtiene datos del día o vacío
      direccionControllers[dia] = TextEditingController(
        text: data['direccion'] ?? '',
      );
      // Carga coordenadas si existen
      if (data['lat'] != null && data['lng'] != null) {
        coordenadas[dia] = LatLng(data['lat'], data['lng']);
      } else {
        coordenadas[dia] = null;
      }
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  // Libera recursos de los controllers cuando la pantalla se cierra
  void _disposeControllers() {
    nombreController.dispose();
    direccionControllers.values.forEach(
      (c) => c.dispose(),
    ); // Limpia cada controller
  }

  // Muestra notificación (éxito, error, validación)
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  // Convierte los controllers en un mapa de datos para guardar
  // Solo guarda coordenadas si hay dirección (validación)
  Map<String, Map<String, dynamic>> _buildDaysMap() {
    final dias = <String, Map<String, dynamic>>{};
    for (var dia in direccionControllers.keys) {
      final direccion = direccionControllers[dia]?.text ?? '';
      dias[dia] = {
        'direccion': direccion,
        'lat': direccion.isNotEmpty
            ? coordenadas[dia]?.latitude
            : null, // Solo si hay dirección
        'lng': direccion.isNotEmpty ? coordenadas[dia]?.longitude : null,
      };
    }
    return dias;
  }

  // Valida datos y guarda en BD (inserción o actualización)
  Future<void> _validateAndSave() async {
    // Validación básica
    if (nombreController.text.isEmpty) {
      _showSnackBar(
        'El nombre del puesto no puede estar vacío',
        const Color(0xFFFF0054),
      );
      return;
    }

    // Construye objeto Puesto con datos actuales
    final puesto = Puesto(
      id: widget.puesto?.id, // Mantiene ID si es edición
      nombre: nombreController.text,
      dias: _buildDaysMap(), // Convierte controllers a mapa
    );

    try {
      // Insert si es nuevo, Update si existe
      if (puesto.id == null) {
        await PuestoService.insertPuesto(puesto);
      } else {
        await PuestoService.updatePuesto(puesto);
      }

      if (mounted) {
        _showSnackBar('Puesto guardado correctamente', const Color(0xFF388E3C));
        Navigator.pop(context); // Cierra la pantalla
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error al guardar: $e', const Color(0xFFFF0054));
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
              coordenadas =
                  coords; // Actualiza coordenadas cuando usuario selecciona en mapa
            });
            _validateAndSave(); // Inicia guardado validado
          },
        ),
      ),
    );
  }
}
