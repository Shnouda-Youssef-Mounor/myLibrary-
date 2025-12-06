import 'package:flutter/material.dart';
import 'package:mylibrary/helper/author_helper.dart';
import 'package:mylibrary/models/author.dart';

class AuthorFormScreen extends StatefulWidget {
  final Author? author;

  const AuthorFormScreen({super.key, this.author});

  @override
  State<AuthorFormScreen> createState() => _AuthorFormScreenState();
}

class _AuthorFormScreenState extends State<AuthorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _photoController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.author?.name ?? '');
    _bioController = TextEditingController(text: widget.author?.bio ?? '');
    _photoController = TextEditingController(text: widget.author?.photo ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final bio = _bioController.text.trim().isEmpty ? null : _bioController.text.trim();
    final photo = _photoController.text.trim().isEmpty ? null : _photoController.text.trim();

    if (widget.author == null) {
      await AuthorHelper.create(name, bio, photo);
    } else {
      await AuthorHelper.update(widget.author!.id!, name, bio, photo);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.author == null ? 'Add Author' : 'Edit Author'),
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
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _photoController,
              decoration: const InputDecoration(
                labelText: 'Photo URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: Text(widget.author == null ? 'Create' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
}
