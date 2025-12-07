import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mylibrary/helper/book_helper.dart';
import 'package:mylibrary/models/author.dart';
import 'package:mylibrary/models/book.dart';
import 'package:mylibrary/screens/authors_list_screen.dart';
import 'package:mylibrary/screens/books_list_screen.dart';
import 'package:mylibrary/screens/library_view_screen.dart';
import 'package:mylibrary/utils/color_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Author> authors = [];
  List<Book> topBooks = [];
  List<Book> favoriteBooks = [];
  Book? currentBook;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      BookHelper.getAuthors(),
      BookHelper.getTopRatedBooks(),
      BookHelper.getCurrentlyReading(),
      BookHelper.getFavoriteBooks(),
    ]);
    setState(() {
      authors = results[0] as List<Author>;
      topBooks = results[1] as List<Book>;
      currentBook = results[2] as Book?;
      favoriteBooks = results[3] as List<Book>;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyLibrary+'),
        elevation: 0,
        actions: [
          /*  IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset Database'),
                  content: const Text(
                    'This will delete all data. Are you sure?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    /* TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Reset'),
                    ),*/
                  ],
                ),
              );
              if (confirm == true) {
                await DBHelper.instance.resetDatabase();
                _loadData();
              }
            },
          ),*/
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (currentBook != null) _buildCurrentlyReading(),
                      _buildAuthorsSection(),
                      _buildTopBooksSection(),

                      if (favoriteBooks.isNotEmpty)
                        _buildFavoriteBooksSection(),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LibraryViewScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorManager.darkPurple,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [const Text('MyLibrary+')],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildCurrentlyReading() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ColorManager.darkPurple, ColorManager.darkPink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ColorManager.darkPurple.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.menu_book,
                color: ColorManager.background,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Currently Reading',
                style: TextStyle(
                  color: ColorManager.background,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: ColorManager.pink,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: currentBook!.coverImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: currentBook!.coverImage!.startsWith('http')
                            ? Image.network(
                                currentBook!.coverImage!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.book, color: Colors.white),
                              )
                            : Image.file(
                                File(currentBook!.coverImage!),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.book, color: Colors.white),
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
                      currentBook!.title,
                      style: const TextStyle(
                        color: ColorManager.background,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (currentBook!.authors != null)
                      Text(
                        currentBook!.authors!.join(', '),
                        style: TextStyle(
                          color: ColorManager.background.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Authors',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ColorManager.darkPurple,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AuthorsListScreen(),
                    ),
                  );
                },
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 120,
          child: authors.isEmpty
              ? const Center(child: Text('No authors'))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: authors.length,
                  itemBuilder: (context, index) {
                    final author = authors[index];
                    return Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(left: 12),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: ColorManager.pink,
                            child: author.photo != null
                                ? ClipOval(
                                    child: Image.network(
                                      author.photo!,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.fill,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            author.name,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFavoriteBooksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: const Text(
            'Favorite Books',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorManager.darkPurple,
            ),
          ),
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: favoriteBooks.length,
            itemBuilder: (context, index) {
              final book = favoriteBooks[index];
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: ColorManager.pink,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: book.coverImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
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
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopBooksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top 10 Rated Books',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ColorManager.darkPurple,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BooksListScreen(),
                    ),
                  );
                },
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        topBooks.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No books'),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: topBooks.length,
                itemBuilder: (context, index) {
                  final book = topBooks[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
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
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 85,
                              decoration: BoxDecoration(
                                color: ColorManager.pink,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
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
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                    Icons.book,
                                                    color: Colors.white,
                                                  ),
                                            )
                                          : Image.file(
                                              File(book.coverImage!),
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                    Icons.book,
                                                    color: Colors.white,
                                                  ),
                                            ),
                                    )
                                  : const Icon(
                                      Icons.book,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    book.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: ColorManager.darkPurple,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (book.authors != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      book.authors!.join(', '),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              book.rating?.toStringAsFixed(1) ??
                                                  '0.0',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.amber,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: ColorManager.darkPink,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }
}
