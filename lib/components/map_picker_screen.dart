import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';
import 'map_search_bar.dart';
import 'address_display.dart';
import 'confirm_location_button.dart';

class MapPickerScreen extends StatefulWidget {
  final LatLng? initialPosition;
  const MapPickerScreen({super.key, this.initialPosition});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late LatLng selectedPosition;
  GoogleMapController? _mapController;
  String? selectedAddress;
  bool _isLoadingAddress = false;
  bool _isInitializing = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      if (widget.initialPosition != null) {
        _setPosition(widget.initialPosition!);
      } else {
        final location = await LocationService.getCurrentLocation();
        _setPosition(location);
      }
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  void _setPosition(LatLng position) {
    setState(() => selectedPosition = position);
    _updateAddress(position);
  }

  Future<void> _updateAddress(LatLng position) async {
    setState(() => _isLoadingAddress = true);
    final address = await LocationService.getAddressFromCoordinates(position);
    if (mounted) {
      setState(() {
        selectedAddress = address;
        _isLoadingAddress = false;
      });
    }
  }

  Future<void> _searchAddress(String query) async {
    if (query.isEmpty) return;

    final location = await LocationService.getLocationFromAddress(query);
    if (location != null) {
      _setPosition(location);
      if (_mapController != null) {
        _mapController!.animateCamera(CameraUpdate.newLatLng(location));
      }
    }
  }

  Future<void> _goToCurrentLocation() async {
    final location = await LocationService.getCurrentLocation();
    _setPosition(location);
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(location));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selecciona ubicación en el mapa')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        _buildGoogleMap(),
        MapSearchBar(
          searchController: _searchController,
          onSearchSubmitted: _searchAddress,
          onLocationPressed: _goToCurrentLocation,
        ),
        AddressDisplay(address: selectedAddress, isLoading: _isLoadingAddress),
        ConfirmLocationButton(
          visible: true,
          onPressed: () => Navigator.pop(context, selectedPosition),
        ),
      ],
    );
  }

  Widget _buildGoogleMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: selectedPosition, zoom: 15),
      markers: {
        Marker(
          markerId: const MarkerId('selected'),
          position: selectedPosition,
          draggable: true,
          onDragEnd: (pos) {
            _setPosition(pos);
          },
        ),
      },
      onTap: (pos) => _setPosition(pos),
      onMapCreated: (controller) => _mapController = controller,
    );
  }
}
