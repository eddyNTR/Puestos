import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'direction_field.dart';

class PuestoForm extends StatefulWidget {
  final TextEditingController nombreController;
  final Map<String, TextEditingController> direccionControllers;
  final Map<String, LatLng?> coordenadas;
  final void Function(Map<String, LatLng?>) onSave;

  const PuestoForm({
    super.key,
    required this.nombreController,
    required this.direccionControllers,
    required this.coordenadas,
    required this.onSave,
  });

  @override
  State<PuestoForm> createState() => _PuestoFormState();
}

class _PuestoFormState extends State<PuestoForm> {
  late Map<String, LatLng?> localCoords;

  @override
  void initState() {
    super.initState();
    localCoords = Map<String, LatLng?>.from(widget.coordenadas);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 12,
        color: const Color(0xFF1A1200),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFFF9800), width: 2),
        ),
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: widget.nombreController,
                style: const TextStyle(color: Color(0xFFF8D082)),
                decoration: const InputDecoration(
                  labelText: 'Nombre del puesto',
                  prefixIcon: Icon(Icons.badge, color: Color(0xFFFF9800)),
                ),
              ),
              const SizedBox(height: 16),
              ...widget.direccionControllers.entries
                  .map(
                    (entry) => DirectionField(
                      dia: entry.key,
                      controller: entry.value,
                      coords: localCoords[entry.key],
                      onMapSelected: (coords) {
                        setState(() {
                          localCoords[entry.key] = coords;
                        });
                      },
                      onAddressUpdated: (_) {
                        setState(() {});
                      },
                    ),
                  )
                  .toList(),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => widget.onSave(localCoords),
                icon: const Icon(Icons.save, color: Color(0xFFFF0054)),
                label: const Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  foregroundColor: const Color(0xFFF8D082),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  shadowColor: const Color(0xFFFF0054),
                  elevation: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
