import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'animated_address_text.dart';

class MapPickerScreen extends StatefulWidget {
  final LatLng? initialPosition;
  const MapPickerScreen({super.key, this.initialPosition});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng? selectedPosition;
  GoogleMapController? _mapController;
  String? selectedAddress;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    // Si ya hay una posición inicial, usarla
    if (widget.initialPosition != null) {
      setState(() {
        selectedPosition = widget.initialPosition;
      });
      return;
    }

    // Intentar obtener la ubicación actual del usuario
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final result = await Geolocator.requestPermission();
        if (result == LocationPermission.denied) {
          // Usar ubicación por defecto si se rechaza el permiso
          _setDefaultLocation();
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        selectedPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      // Si hay error, usar ubicación por defecto
      _setDefaultLocation();
    }
  }

  void _setDefaultLocation() {
    setState(() {
      selectedPosition = const LatLng(-16.5, -68.1); // Default: La Paz
    });
    _updateAddress(selectedPosition!);
  }

  Future<void> _updateAddress(LatLng position) async {
    try {
      if (!mounted) return;

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        String address = '';

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
          address = '${validAddresses[0]} y ${validAddresses[1]}';
        } else if (validAddresses.length == 1) {
          address = validAddresses[0];
        } else {
          if ((p.thoroughfare ?? '').isNotEmpty) {
            address = p.thoroughfare!;
          } else if ((p.street ?? '').isNotEmpty) {
            address = p.street!;
          } else if ((p.name ?? '').isNotEmpty) {
            address = p.name!;
          } else {
            address = '${p.locality ?? 'Ubicación'} ${p.postalCode ?? ''}'
                .trim();
          }
        }

        if (mounted) {
          setState(() {
            selectedAddress = address;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            selectedAddress = 'Dirección no encontrada';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          selectedAddress = 'Dirección no encontrada';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _searchController = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Selecciona ubicación en el mapa')),
      body: selectedPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: selectedPosition!,
                    zoom: 15,
                  ),
                  markers: selectedPosition != null
                      ? {
                          Marker(
                            markerId: const MarkerId('selected'),
                            position: selectedPosition!,
                            draggable: true,
                            onDragEnd: (pos) =>
                                setState(() => selectedPosition = pos),
                          ),
                        }
                      : {},
                  onTap: (pos) {
                    setState(() => selectedPosition = pos);
                    _updateAddress(pos);
                  },
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  height: 56,
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(8),
                    child: TextField(
                      controller: _searchController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Buscar dirección...',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (value) async {
                        if (value.isNotEmpty) {
                          try {
                            final locations = await locationFromAddress(value);
                            if (locations.isNotEmpty) {
                              final loc = locations.first;
                              final newPosition = LatLng(
                                loc.latitude,
                                loc.longitude,
                              );
                              setState(() {
                                selectedPosition = newPosition;
                              });
                              if (_mapController != null) {
                                _mapController!.animateCamera(
                                  CameraUpdate.newLatLng(newPosition),
                                );
                              }
                              _updateAddress(newPosition);
                            }
                          } catch (_) {
                            // Error en búsqueda de dirección
                          }
                        }
                      },
                    ),
                  ),
                ),
                if (selectedAddress != null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: AnimatedAddressText(
                                address: selectedAddress!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context, selectedPosition);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[700],
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(12),
                              ),
                              child: Icon(Icons.check, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
