import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mylibrary/helper/author_helper.dart';
import 'package:mylibrary/helper/book_helper.dart';
import 'package:mylibrary/models/book.dart';
import 'package:mylibrary/screens/author_details_screen.dart';
import 'package:mylibrary/screens/book_form_screen.dart';
import 'package:mylibrary/utils/color_manager.dart';
import 'package:open_filex/open_filex.dart' as openFilex;
import 'package:url_launcher/url_launcher.dart';

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

  Future<List<Map<String, dynamic>>> _getAuthorsDetails() async {
    if (book?.authorIds == null || book!.authorIds!.isEmpty) return [];
    final authors = <Map<String, dynamic>>[];
    for (var id in book!.authorIds!) {
      final author = await AuthorHelper.getById(id);
      if (author != null) {
        authors.add({'id': author.id, 'name': author.name, 'photo': author.photo});
      }
    }
    return authors;
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              ColorManager.darkPurple,
                              ColorManager.darkPurple.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Hero(
                            tag: 'book_${book!.id}',
                            child: Container(
                              width: 160,
                              height: 220,
                              decoration: BoxDecoration(
                                color: ColorManager.pink,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: book!.coverImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child:
                                          book!.coverImage!.startsWith('http')
                                          ? Image.network(
                                              book!.coverImage!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                    Icons.book,
                                                    size: 80,
                                                    color: Colors.white,
                                                  ),
                                            )
                                          : Image.file(
                                              File(book!.coverImage!),
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
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
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            book!.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: ColorManager.darkPurple,
                            ),
                          ),
                        ),
                        if (book!.authors != null && book!.authorIds != null) ...[
                          const SizedBox(height: 16),
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: _getAuthorsDetails(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: snapshot.data!.map((author) => InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AuthorDetailsScreen(authorId: author['id']),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: ColorManager.pink.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: ColorManager.pink),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: ColorManager.pink,
                                          backgroundImage: author['photo'] != null ? NetworkImage(author['photo']) : null,
                                          child: author['photo'] == null ? const Icon(Icons.person, size: 16, color: Colors.white) : null,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          author['name'],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: ColorManager.darkPurple,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )).toList(),
                              );
                            },
                          ),
                        ],
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (book!.rating != null)
                              _buildInfoCard(
                                icon: Icons.star,
                                label: 'Rating',
                                value: book!.rating!.toStringAsFixed(1),
                                color: Colors.amber,
                              ),
                            if (book!.pages != null)
                              _buildInfoCard(
                                icon: Icons.menu_book,
                                label: 'Pages',
                                value: '${book!.pages}',
                                color: ColorManager.darkPink,
                              ),
                            if (book!.publishYear != null)
                              _buildInfoCard(
                                icon: Icons.calendar_today,
                                label: 'Year',
                                value: '${book!.publishYear}',
                                color: ColorManager.darkPurple,
                              ),
                          ],
                        ),
                        if (book!.status != null || book!.favorite == true) ...[
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            children: [
                              if (book!.status != null)
                                Chip(
                                  label: Text(formatStatus(book!.status!)),
                                  backgroundColor: ColorManager.pink
                                      .withOpacity(0.3),
                                ),
                              if (book!.favorite == true)
                                const Chip(
                                  label: Text('Favorite'),
                                  avatar: Icon(
                                    Icons.favorite,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                  backgroundColor: Color(0xFFFFE0E0),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  if (book!.filePath != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            final filePath = book!.filePath!;

                            if (filePath.startsWith('http')) {
                              final uri = Uri.parse(filePath);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              } else {
                                throw 'Cannot launch URL';
                              }
                            } else {
                              if (Platform.isAndroid || Platform.isIOS) {
                                final result = await openFilex.OpenFilex.open(
                                  filePath,
                                );
                                if (result.type != openFilex.ResultType.done) {
                                  throw result.message;
                                }
                              } else if (Platform.isLinux ||
                                  Platform.isWindows ||
                                  Platform.isMacOS) {
                                // على الكمبيوتر: فتح التطبيق الافتراضي
                                final uri = Uri.file(filePath);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } else {
                                  if (Platform.isLinux) {
                                    await Process.run('xdg-open', [filePath]);
                                  } else if (Platform.isWindows) {
                                    await Process.run('cmd', [
                                      '/c',
                                      'start',
                                      '',
                                      filePath,
                                    ], runInShell: true);
                                  } else if (Platform.isMacOS) {
                                    await Process.run('open', [filePath]);
                                  }
                                }
                              }
                            }

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Opening file...'),
                                ),
                              );
                            }
                          } catch (e) {
                            print(e);
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
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ),
                  ],

                  if (book!.description != null) ...[
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (book!.notes != null) ...[
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                              color: ColorManager.pink.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: ColorManager.pink),
                            ),
                            child: Text(
                              book!.notes!,
                              style: const TextStyle(fontSize: 16, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  String formatStatus(String text) {
    return text
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
