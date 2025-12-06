import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mylibrary/helper/category_helper.dart';
import 'package:mylibrary/helper/shelf_helper.dart';
import 'package:mylibrary/models/category.dart';
import 'package:mylibrary/models/shelf.dart';

class CategoryFormScreen extends StatefulWidget {
  final Category? category;

  const CategoryFormScreen({super.key, this.category});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _iconController;
  
  int? _selectedShelfId;
  List<Shelf> shelves = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descController = TextEditingController(text: widget.category?.description ?? '');
    _iconController = TextEditingController(text: widget.category?.icon ?? '');
    _selectedShelfId = widget.category?.shelfId;
    _loadShelves();
  }

  Future<void> _loadShelves() async {
    shelves = await ShelfHelper.getAll();
    setState(() => isLoading = false);
  }

  Future<void> _pickIcon() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _iconController.text = result.files.single.path!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final desc = _descController.text.trim().isEmpty ? null : _descController.text.trim();
    final icon = _iconController.text.trim().isEmpty ? null : _iconController.text.trim();

    if (widget.category == null) {
      await CategoryHelper.create(_selectedShelfId!, name, desc, icon);
    } else {
      await CategoryHelper.update(widget.category!.id!, _selectedShelfId!, name, desc, icon);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
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
                  DropdownButtonFormField<int>(
                    value: _selectedShelfId,
                    decoration: const InputDecoration(
                      labelText: 'Shelf',
                      border: OutlineInputBorder(),
                    ),
                    items: shelves.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                    onChanged: (value) => setState(() => _selectedShelfId = value),
                    validator: (value) => value == null ? 'Required' : null,
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
                  TextFormField(
                    controller: _iconController,
                    decoration: InputDecoration(
                      labelText: 'Icon Image',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.image),
                        onPressed: _pickIcon,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _save,
                    child: Text(widget.category == null ? 'Create' : 'Update'),
                  ),
                ],
              ),
            ),
    );
  }
}
