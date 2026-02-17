import 'package:flutter/material.dart';

class AddressDisplay extends StatelessWidget {
  final String? address;
  final bool isLoading;

  const AddressDisplay({super.key, this.address, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      left: 16,
      right: 80,
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
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Icon(Icons.location_on, color: Color(0xFFF8D082), size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                address ?? 'Cargando dirección...',
                style: const TextStyle(
                  color: Color(0xFFF8D082),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
