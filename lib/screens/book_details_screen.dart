import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mylibrary/helper/book_helper.dart';
import 'package:mylibrary/models/book.dart';
import 'package:mylibrary/screens/book_form_screen.dart';
import 'package:mylibrary/utils/color_manager.dart';

class BookDetailsScreen extends StatefulWidget {
  final int bookId;

  const BookDetailsScreen({super.key, required this.bookId});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  Book? book;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  Future<void> _loadBook() async {
    setState(() => isLoading = true);
    book = await BookHelper.getById(widget.bookId);
    setState(() => isLoading = false);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await BookHelper.delete(widget.bookId);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookFormScreen(book: book),
                ),
              );
              _loadBook();
            },
          ),
          IconButton(icon: const Icon(Icons.delete), onPressed: _delete),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : book == null
          ? const Center(child: Text('Book not found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 150,
                      height: 200,
                      decoration: BoxDecoration(
                        color: ColorManager.pink,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: book!.coverImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: book!.coverImage!.startsWith('http')
                                  ? Image.network(
                                      book!.coverImage!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.book,
                                        size: 80,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Image.file(
                                      File(book!.coverImage!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.book,
                                        size: 80,
                                        color: Colors.white,
                                      ),
                                    ),
                            )
                          : const Icon(
                              Icons.book,
                              size: 80,
                              color: Colors.white,
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    book!.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ColorManager.darkPurple,
                    ),
                  ),
                  if (book!.authors != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      book!.authors!.join(', '),
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (book!.rating != null) ...[
                        const Icon(Icons.star, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          book!.rating!.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 16),
                      ],
                      if (book!.pages != null) ...[
                        const Icon(
                          Icons.menu_book,
                          color: ColorManager.darkPink,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${book!.pages} pages',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ],
                  ),
                  if (book!.publishYear != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Published: ${book!.publishYear}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                  if (book!.status != null) ...[
                    const SizedBox(height: 8),
                    Chip(label: Text(book!.status!)),
                  ],
                  if (book!.filePath != null) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          if (Platform.isLinux) {
                            await Process.run('xdg-open', [book!.filePath!]);
                          } else if (Platform.isWindows) {
                            await Process.run('start', [book!.filePath!], runInShell: true);
                          } else if (Platform.isMacOS) {
                            await Process.run('open', [book!.filePath!]);
                          }
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Opening file...')),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                      icon: Icon(
                        book!.filePath!.startsWith('http')
                            ? Icons.link
                            : Icons.file_present,
                      ),
                      label: Text(
                        book!.filePath!.startsWith('http')
                            ? 'Open URL'
                            : 'Open File',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorManager.darkPink,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                  if (book!.favorite == true) ...[
                    const SizedBox(height: 8),
                    const Chip(
                      label: Text('Favorite'),
                      avatar: Icon(Icons.favorite, size: 16, color: Colors.red),
                    ),
                  ],
                  if (book!.filePath != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ColorManager.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: ColorManager.pink),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            book!.filePath!.startsWith('http')
                                ? Icons.link
                                : Icons.folder,
                            color: ColorManager.darkPink,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              book!.filePath!,
                              style: const TextStyle(fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (book!.description != null) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ColorManager.darkPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      book!.description!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                  if (book!.notes != null) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ColorManager.darkPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ColorManager.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ColorManager.pink),
                      ),
                      child: Text(
                        book!.notes!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
