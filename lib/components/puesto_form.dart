import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_picker_screen.dart';
import 'animated_address_text.dart';
import 'package:geocoding/geocoding.dart';

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

  Future<void> _setDireccionFromCoords(String dia, LatLng coords) async {
    try {
      if (!mounted) return;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        coords.latitude,
        coords.longitude,
      );

      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        String direccion = '';

        // Función para validar si el texto NO es solo un código plus
        bool isValidAddress(String? text) {
          if (text == null || text.isEmpty) return false;
          // Rechazar solo si es SOLO código plus (ej: JR9R+55V)
          final plusPattern = RegExp(r'^[A-Z0-9]{2,4}\+[A-Z0-9]{2,4}$');
          return !plusPattern.hasMatch(text) && text.length > 2;
        }

        // Recolectar todas las direcciones válidas disponibles
        List<String> validAddresses = [];

        if (isValidAddress(p.thoroughfare)) validAddresses.add(p.thoroughfare!);
        if (isValidAddress(p.street)) validAddresses.add(p.street!);
        if (isValidAddress(p.name)) validAddresses.add(p.name!);
        if (isValidAddress(p.subLocality)) validAddresses.add(p.subLocality!);
        if (isValidAddress(p.locality)) validAddresses.add(p.locality!);

        // Construir la dirección con la mejor combinación
        if (validAddresses.length >= 2) {
          direccion = '${validAddresses[0]} y ${validAddresses[1]}';
        } else if (validAddresses.length == 1) {
          direccion = validAddresses[0];
        } else {
          if ((p.thoroughfare ?? '').isNotEmpty) {
            direccion = p.thoroughfare!;
          } else if ((p.street ?? '').isNotEmpty) {
            direccion = p.street!;
          } else if ((p.name ?? '').isNotEmpty) {
            direccion = p.name!;
          } else {
            direccion = '${p.locality ?? 'Ubicación'} ${p.postalCode ?? ''}'
                .trim();
          }
        }

        if (mounted) {
          widget.direccionControllers[dia]?.text = direccion;
          setState(() {
            // Limpiar y reasignar para forzar que AnimatedAddressText recontruya
          });
        }
      } else {
        if (mounted) {
          widget.direccionControllers[dia]?.text = 'Dirección no encontrada';
        }
      }
    } catch (e) {
      if (mounted) {
        widget.direccionControllers[dia]?.text = 'Dirección no encontrada';
      }
    }
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
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Campo de dirección + botón de mapa en la misma fila
                          Row(
                            children: [
                              Expanded(
                                child:
                                    entry.value.text.isNotEmpty &&
                                        localCoords[entry.key] != null
                                    ? GestureDetector(
                                        onTap: () {
                                          // Mostrar TextField al hacer tap
                                          final tempController =
                                              TextEditingController(
                                                text: entry.value.text,
                                              );
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: Text(
                                                '${entry.key} - Dirección',
                                              ),
                                              content: TextField(
                                                controller: tempController,
                                                decoration: InputDecoration(
                                                  hintText: 'Editar dirección',
                                                  border: OutlineInputBorder(),
                                                ),
                                                maxLines: null,
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx),
                                                  child: const Text('Cancelar'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    // Actualizar el controller original con los cambios
                                                    entry.value.text =
                                                        tempController.text;
                                                    setState(() {
                                                      // Forzar reconstrucción
                                                    });
                                                    Navigator.pop(ctx);
                                                  },
                                                  child: const Text('Guardar'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color(0xFFFF9800),
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: AnimatedAddressText(
                                            key: ValueKey(
                                              '${entry.key}_${entry.value.text}',
                                            ),
                                            address:
                                                '${entry.key}: ${entry.value.text}',
                                            style: const TextStyle(
                                              color: Color(0xFFF8D082),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      )
                                    : TextField(
                                        controller: entry.value,
                                        style: const TextStyle(
                                          color: Color(0xFFF8D082),
                                        ),
                                        decoration: InputDecoration(
                                          labelText: '${entry.key} (Dirección)',
                                          prefixIcon: const Icon(
                                            Icons.location_on,
                                            color: Color(0xFFF8D082),
                                          ),
                                        ),
                                      ),
                              ),
                              // Botón de mapa pequeño al lado
                              IconButton(
                                icon: Icon(
                                  localCoords[entry.key] != null
                                      ? Icons.map
                                      : Icons.map_outlined,
                                  color: const Color(0xFFFF9800),
                                  size: 24,
                                ),
                                tooltip: 'Seleccionar en mapa',
                                onPressed: () async {
                                  final result = await Navigator.push<LatLng?>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MapPickerScreen(
                                        initialPosition: localCoords[entry.key],
                                      ),
                                    ),
                                  );
                                  if (result != null) {
                                    setState(() {
                                      localCoords[entry.key] = result;
                                    });
                                    await _setDireccionFromCoords(
                                      entry.key,
                                      result,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
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
