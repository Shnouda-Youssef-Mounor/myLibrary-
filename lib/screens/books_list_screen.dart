import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mylibrary/helper/book_helper.dart';
import 'package:mylibrary/models/book.dart';
import 'package:mylibrary/screens/book_form_screen.dart';
import 'package:mylibrary/screens/book_details_screen.dart';
import 'package:mylibrary/utils/color_manager.dart';

class BooksListScreen extends StatefulWidget {
  const BooksListScreen({super.key});

  @override
  State<BooksListScreen> createState() => _BooksListScreenState();
}

class _BooksListScreenState extends State<BooksListScreen> {
  List<Book> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() => isLoading = true);
    books = await BookHelper.getAll();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : books.isEmpty
              ? const Center(child: Text('No books'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 70,
                          decoration: BoxDecoration(
                            color: ColorManager.pink,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: book.coverImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: book.coverImage!.startsWith('http')
                                      ? Image.network(book.coverImage!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.book, color: Colors.white))
                                      : Image.file(File(book.coverImage!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.book, color: Colors.white)),
                                )
                              : const Icon(Icons.book, color: Colors.white),
                        ),
                        title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: book.authors != null ? Text(book.authors!.join(', ')) : null,
                        trailing: book.rating != null
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(book.rating!.toStringAsFixed(1)),
                                ],
                              )
                            : null,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookDetailsScreen(bookId: book.id!),
                            ),
                          );
                          _loadBooks();
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BookFormScreen()),
          );
          _loadBooks();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
