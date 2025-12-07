import 'package:flutter/material.dart';
import 'package:mylibrary/helper/author_helper.dart';
import 'package:mylibrary/models/author.dart';
import 'package:mylibrary/screens/author_details_screen.dart';
import 'package:mylibrary/screens/author_form_screen.dart';
import 'package:mylibrary/utils/color_manager.dart';

class AuthorsListScreen extends StatefulWidget {
  const AuthorsListScreen({super.key});

  @override
  State<AuthorsListScreen> createState() => _AuthorsListScreenState();
}

class _AuthorsListScreenState extends State<AuthorsListScreen> {
  List<Author> authors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAuthors();
  }

  Future<void> _loadAuthors() async {
    setState(() => isLoading = true);
    authors = await AuthorHelper.getAll();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authors')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : authors.isEmpty
          ? const Center(child: Text('No authors'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: authors.length,
              itemBuilder: (context, index) {
                final author = authors[index];
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
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AuthorDetailsScreen(authorId: author.id!),
                        ),
                      );
                      _loadAuthors();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: ColorManager.pink,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: author.photo != null
                                ? ClipOval(
                                    child: Image.network(
                                      author.photo!,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  author.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: ColorManager.darkPurple,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${author.bookCount ?? 0} books',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AuthorFormScreen()),
          );
          _loadAuthors();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
