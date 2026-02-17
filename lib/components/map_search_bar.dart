import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onLocationPressed;

  const MapSearchBar({
    super.key,
    required this.searchController,
    this.onSearchSubmitted,
    this.onLocationPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      left: 12,
      right: 12,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF212121).withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF212121).withOpacity(0.95),
                    hintText: 'Buscar dirección...',
                    hintStyle: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.white70,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                  onSubmitted: onSearchSubmitted,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.my_location,
                  color: Colors.blueAccent,
                  size: 20,
                ),
                iconSize: 24,
                padding: const EdgeInsets.all(6),
                tooltip: 'Ir a mi ubicación',
                onPressed: onLocationPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
