import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_picker_screen.dart';
import 'animated_address_text.dart';
import 'edit_direction_dialog.dart';
import 'package:geocoding/geocoding.dart';

class DirectionField extends StatelessWidget {
  final String dia;
  final TextEditingController controller;
  final LatLng? coords;
  final Function(LatLng) onMapSelected;
  final Function(String) onAddressUpdated;

  const DirectionField({
    super.key,
    required this.dia,
    required this.controller,
    required this.coords,
    required this.onMapSelected,
    required this.onAddressUpdated,
  });

  Future<void> _setDireccionFromCoords(BuildContext context) async {
    try {
      if (coords == null) return;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        coords!.latitude,
        coords!.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        String direccion = _buildAddress(p);
        controller.text = direccion;
        onAddressUpdated(direccion);
      } else {
        controller.text = 'Dirección no encontrada';
      }
    } catch (e) {
      controller.text = 'Dirección no encontrada';
    }
  }

  String _buildAddress(Placemark p) {
    bool isValidAddress(String? text) {
      if (text == null || text.isEmpty) return false;
      final plusPattern = RegExp(r'^[A-Z0-9]{2,4}\+[A-Z0-9]{2,4}$');
      return !plusPattern.hasMatch(text) && text.length > 2;
    }

    List<String> validAddresses = [];
    if (isValidAddress(p.thoroughfare)) validAddresses.add(p.thoroughfare!);
    if (isValidAddress(p.street)) validAddresses.add(p.street!);
    if (isValidAddress(p.name)) validAddresses.add(p.name!);
    if (isValidAddress(p.subLocality)) validAddresses.add(p.subLocality!);
    if (isValidAddress(p.locality)) validAddresses.add(p.locality!);

    if (validAddresses.length >= 2) {
      return '${validAddresses[0]} y ${validAddresses[1]}';
    } else if (validAddresses.length == 1) {
      return validAddresses[0];
    } else {
      if ((p.thoroughfare ?? '').isNotEmpty) {
        return p.thoroughfare!;
      } else if ((p.street ?? '').isNotEmpty) {
        return p.street!;
      } else if ((p.name ?? '').isNotEmpty) {
        return p.name!;
      } else {
        return '${p.locality ?? 'Ubicación'} ${p.postalCode ?? ''}'.trim();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: controller.text.isNotEmpty && coords != null
                ? GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => EditDirectionDialog(
                          dia: dia,
                          initialAddress: controller.text,
                          onSave: (newAddress) {
                            controller.text = newAddress;
                            onAddressUpdated(newAddress);
                          },
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFFF9800)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AnimatedAddressText(
                        key: ValueKey('${dia}_${controller.text}'),
                        address: '$dia: ${controller.text}',
                        style: const TextStyle(
                          color: Color(0xFFF8D082),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                : TextField(
                    controller: controller,
                    style: const TextStyle(color: Color(0xFFF8D082)),
                    decoration: InputDecoration(
                      labelText: '$dia (Dirección)',
                      prefixIcon: const Icon(
                        Icons.location_on,
                        color: Color(0xFFF8D082),
                      ),
                    ),
                  ),
          ),
          IconButton(
            icon: Icon(
              coords != null ? Icons.map : Icons.map_outlined,
              color: const Color(0xFFFF9800),
              size: 24,
            ),
            tooltip: 'Seleccionar en mapa',
            onPressed: () async {
              final result = await Navigator.push<LatLng?>(
                context,
                MaterialPageRoute(
                  builder: (_) => MapPickerScreen(initialPosition: coords),
                ),
              );
              if (result != null) {
                onMapSelected(result);
                await _setDireccionFromCoords(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
