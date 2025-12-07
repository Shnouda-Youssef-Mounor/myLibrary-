import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mylibrary/helper/book_helper.dart';
import 'package:mylibrary/models/book.dart';
import 'package:mylibrary/models/category.dart';
import 'package:mylibrary/screens/book_details_screen.dart';
import 'package:mylibrary/utils/color_manager.dart';

class CategoryBooksScreen extends StatefulWidget {
  final Category category;

  const CategoryBooksScreen({super.key, required this.category});

  @override
  State<CategoryBooksScreen> createState() => _CategoryBooksScreenState();
}

class _CategoryBooksScreenState extends State<CategoryBooksScreen> {
  List<Book> books = [];
  List<Book> filteredBooks = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() => isLoading = true);
    books = await BookHelper.getByCategoryId(widget.category.id!);
    filteredBooks = books;
    setState(() => isLoading = false);
  }

  void _filterBooks(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredBooks = books;
      } else {
        filteredBooks = books.where((book) {
          return book.title.toLowerCase().contains(query.toLowerCase()) ||
              (book.authors?.any(
                    (author) =>
                        author.toLowerCase().contains(query.toLowerCase()),
                  ) ??
                  false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              onChanged: _filterBooks,
              decoration: InputDecoration(
                hintText: 'Search books...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _filterBooks('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredBooks.isEmpty
          ? Center(
              child: Text(
                searchQuery.isEmpty
                    ? 'No books in this category'
                    : 'No books found',
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.6,
              ),
              itemCount: filteredBooks.length,
              itemBuilder: (context, index) {
                final book = filteredBooks[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BookDetailsScreen(bookId: book.id!),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: ColorManager.pink,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          child: book.coverImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: book.coverImage!.startsWith('http')
                                      ? Image.network(
                                          book.coverImage!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                                Icons.book,
                                                color: Colors.white,
                                                size: 48,
                                              ),
                                        )
                                      : Image.file(
                                          File(book.coverImage!),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                                Icons.book,
                                                color: Colors.white,
                                                size: 48,
                                              ),
                                        ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.book,
                                    color: Colors.white,
                                    size: 48,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        book.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (book.rating != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              book.rating!.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
