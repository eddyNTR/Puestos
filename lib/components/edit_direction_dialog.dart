import 'package:flutter/material.dart';

class EditDirectionDialog extends StatefulWidget {
  final String dia;
  final String initialAddress;
  final Function(String) onSave;

  const EditDirectionDialog({
    super.key,
    required this.dia,
    required this.initialAddress,
    required this.onSave,
  });

  @override
  State<EditDirectionDialog> createState() => _EditDirectionDialogState();
}

class _EditDirectionDialogState extends State<EditDirectionDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialAddress);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.dia} - Dirección'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Editar dirección',
          border: OutlineInputBorder(),
        ),
        maxLines: null,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_controller.text);
            Navigator.pop(context);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
