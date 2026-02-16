import 'package:flutter/material.dart';
import '../models/puesto.dart';

class PuestoList extends StatelessWidget {
  final List<Puesto> puestos;
  final void Function(Puesto) onTap;
  final void Function(Puesto) onDelete;

  const PuestoList({
    super.key,
    required this.puestos,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: puestos.length,
      itemBuilder: (context, index) {
        final puesto = puestos[index];
        return Card(
          color: const Color(0xFF1A1200), // Fondo oscuro con toque naranja
          elevation: 8,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(
              color: Color(0xFFFF9800),
              width: 2,
            ), // Naranja eléctrico
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            leading: const Icon(
              Icons.workspaces,
              color: Color(0xFFF8D082),
              size: 32,
            ),
            title: Text(
              puesto.nombre,
              style: const TextStyle(
                color: Color(0xFFF8D082),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFFFF0054)),
                  onPressed: () => onDelete(puesto),
                  tooltip: 'Eliminar',
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, color: Color(0xFFFF0054)),
              ],
            ),
            onTap: () => onTap(puesto),
          ),
        );
      },
    );
  }
}
