import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mylibrary/helper/author_helper.dart';
import 'package:mylibrary/models/author.dart';
import 'package:mylibrary/screens/author_form_screen.dart';
import 'package:mylibrary/screens/book_details_screen.dart';
import 'package:mylibrary/utils/color_manager.dart';

class AuthorDetailsScreen extends StatefulWidget {
  final int authorId;

  const AuthorDetailsScreen({super.key, required this.authorId});

  @override
  State<AuthorDetailsScreen> createState() => _AuthorDetailsScreenState();
}

class _AuthorDetailsScreenState extends State<AuthorDetailsScreen> {
  Author? author;
  List<Map<String, dynamic>> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAuthor();
  }

  Future<void> _loadAuthor() async {
    setState(() => isLoading = true);
    author = await AuthorHelper.getById(widget.authorId);
    books = await AuthorHelper.getBooksByAuthorId(widget.authorId);
    setState(() => isLoading = false);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Author'),
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
      await AuthorHelper.delete(widget.authorId);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Author Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AuthorFormScreen(author: author),
                ),
              );
              _loadAuthor();
            },
          ),
          IconButton(icon: const Icon(Icons.delete), onPressed: _delete),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : author == null
          ? const Center(child: Text('Author not found'))
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ColorManager.darkPurple,
                          ColorManager.darkPurple,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            child: author!.photo != null
                                ? ClipOval(
                                    child: Image.network(
                                      author!.photo!,
                                      fit: BoxFit.cover,
                                      width: 120,
                                      height: 120,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: ColorManager.pink,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: ColorManager.pink,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          author!.name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.book,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${author!.bookCount ?? 0} books',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                  if (author!.bio != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: ColorManager.pink.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.info_outline,
                                    color: ColorManager.darkPink,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Biography',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: ColorManager.darkPurple,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              author!.bio!,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.6,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (books.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: ColorManager.pink.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.book,
                                  color: ColorManager.darkPink,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Books',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: ColorManager.darkPurple,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...books.map((book) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookDetailsScreen(bookId: book['id']),
                                  ),
                                );
                                _loadAuthor();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: ColorManager.pink,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: book['cover_image'] != null
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: book['cover_image'].startsWith('http')
                                                  ? Image.network(
                                                      book['cover_image'],
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (_, __, ___) => const Icon(Icons.book, color: Colors.white),
                                                    )
                                                  : Image.file(
                                                      File(book['cover_image']),
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (_, __, ___) => const Icon(Icons.book, color: Colors.white),
                                                    ),
                                            )
                                          : const Icon(Icons.book, color: Colors.white),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            book['title'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: ColorManager.darkPurple,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (book['rating'] != null) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                                const SizedBox(width: 4),
                                                Text(
                                                  book['rating'].toStringAsFixed(1),
                                                  style: const TextStyle(fontSize: 13, color: Colors.amber),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, color: ColorManager.darkPink),
                                  ],
                                ),
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
