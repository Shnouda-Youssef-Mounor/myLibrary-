import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mylibrary/helper/book_helper.dart';
import 'package:mylibrary/helper/category_helper.dart';
import 'package:mylibrary/models/book.dart';
import 'package:mylibrary/models/category.dart';
import 'package:mylibrary/models/author.dart';

class BookFormScreen extends StatefulWidget {
  final Book? book;

  const BookFormScreen({super.key, this.book});

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _coverController;
  late TextEditingController _filePathController;
  late TextEditingController _descController;
  late TextEditingController _pagesController;
  late TextEditingController _yearController;
  late TextEditingController _notesController;
  
  int? _selectedCategoryId;
  String? _selectedStatus;
  double? _rating;
  bool _favorite = false;
  List<int> _selectedAuthorIds = [];
  
  List<Category> categories = [];
  List<Author> authors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book?.title ?? '');
    _coverController = TextEditingController(text: widget.book?.coverImage ?? '');
    _filePathController = TextEditingController(text: widget.book?.filePath ?? '');
    _descController = TextEditingController(text: widget.book?.description ?? '');
    _pagesController = TextEditingController(text: widget.book?.pages?.toString() ?? '');
    _yearController = TextEditingController(text: widget.book?.publishYear?.toString() ?? '');
    _notesController = TextEditingController(text: widget.book?.notes ?? '');
    _selectedCategoryId = widget.book?.categoryId;
    _selectedStatus = widget.book?.status;
    _rating = widget.book?.rating;
    _favorite = widget.book?.favorite ?? false;
    _selectedAuthorIds = widget.book?.authorIds ?? [];
    _loadData();
  }

  Future<void> _loadData() async {
    categories = await CategoryHelper.getAll();
    authors = await BookHelper.getAllAuthors();
    setState(() => isLoading = false);
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _coverController.text = result.files.single.path!);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'epub', 'mobi', 'txt'],
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _filePathController.text = result.files.single.path!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _coverController.dispose();
    _filePathController.dispose();
    _descController.dispose();
    _pagesController.dispose();
    _yearController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.book == null) {
      await BookHelper.create(
        categoryId: _selectedCategoryId!,
        title: _titleController.text.trim(),
        coverImage: _coverController.text.trim().isEmpty ? null : _coverController.text.trim(),
        filePath: _filePathController.text.trim().isEmpty ? null : _filePathController.text.trim(),
        description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        pages: _pagesController.text.trim().isEmpty ? null : int.tryParse(_pagesController.text.trim()),
        publishYear: _yearController.text.trim().isEmpty ? null : int.tryParse(_yearController.text.trim()),
        status: _selectedStatus,
        rating: _rating,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        favorite: _favorite,
        authorIds: _selectedAuthorIds.isEmpty ? null : _selectedAuthorIds,
      );
    } else {
      await BookHelper.update(
        id: widget.book!.id!,
        categoryId: _selectedCategoryId!,
        title: _titleController.text.trim(),
        coverImage: _coverController.text.trim().isEmpty ? null : _coverController.text.trim(),
        filePath: _filePathController.text.trim().isEmpty ? null : _filePathController.text.trim(),
        description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        pages: _pagesController.text.trim().isEmpty ? null : int.tryParse(_pagesController.text.trim()),
        publishYear: _yearController.text.trim().isEmpty ? null : int.tryParse(_yearController.text.trim()),
        status: _selectedStatus,
        rating: _rating,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        favorite: _favorite,
        authorIds: _selectedAuthorIds.isEmpty ? null : _selectedAuthorIds,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book == null ? 'Add Book' : 'Edit Book'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                    validator: (value) => value?.trim().isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                    items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (value) => setState(() => _selectedCategoryId = value),
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _coverController,
                    decoration: InputDecoration(
                      labelText: 'Cover Image',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.folder_open),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _filePathController,
                    decoration: InputDecoration(
                      labelText: 'Book File (PDF, EPUB, etc.)',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.attach_file),
                        onPressed: _pickFile,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _pagesController,
                          decoration: const InputDecoration(labelText: 'Pages', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _yearController,
                          decoration: const InputDecoration(labelText: 'Year', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                    items: ['reading', 'finished', 'want_to_read']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedStatus = value),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<double>(
                    value: _rating,
                    decoration: const InputDecoration(labelText: 'Rating', border: OutlineInputBorder()),
                    items: [1.0, 2.0, 3.0, 4.0, 5.0]
                        .map((r) => DropdownMenuItem(value: r, child: Text(r.toString())))
                        .toList(),
                    onChanged: (value) => setState(() => _rating = value),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Favorite'),
                    value: _favorite,
                    onChanged: (value) => setState(() => _favorite = value ?? false),
                  ),
                  const SizedBox(height: 16),
                  const Text('Authors', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ...authors.map((author) => CheckboxListTile(
                        title: Text(author.name),
                        value: _selectedAuthorIds.contains(author.id),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedAuthorIds.add(author.id!);
                            } else {
                              _selectedAuthorIds.remove(author.id);
                            }
                          });
                        },
                      )),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _save,
                    child: Text(widget.book == null ? 'Create' : 'Update'),
                  ),
                ],
              ),
            ),
    );
  }
}
