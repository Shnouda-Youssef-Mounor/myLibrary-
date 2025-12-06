import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:mylibrary/helper/shelf_helper.dart';
import 'package:mylibrary/models/shelf.dart';

class ShelfFormScreen extends StatefulWidget {
  final Shelf? shelf;

  const ShelfFormScreen({super.key, this.shelf});

  @override
  State<ShelfFormScreen> createState() => _ShelfFormScreenState();
}

class _ShelfFormScreenState extends State<ShelfFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  Color _selectedColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.shelf?.name ?? '');
    _descController = TextEditingController(text: widget.shelf?.description ?? '');
    if (widget.shelf?.color != null) {
      _selectedColor = Color(int.parse(widget.shelf!.color!.replaceFirst('#', '0xFF')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickColor() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) => setState(() => _selectedColor = color),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final desc = _descController.text.trim().isEmpty ? null : _descController.text.trim();
    final color = '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}';

    if (widget.shelf == null) {
      await ShelfHelper.create(name, desc, color);
    } else {
      await ShelfHelper.update(widget.shelf!.id!, name, desc, color);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shelf == null ? 'Add Shelf' : 'Edit Shelf'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.trim().isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickColor,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Color',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: Text(widget.shelf == null ? 'Create' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
}
