import 'package:flutter/material.dart';
import 'package:mylibrary/helper/author_helper.dart';
import 'package:mylibrary/models/author.dart';
import 'package:mylibrary/screens/author_form_screen.dart';
import 'package:mylibrary/screens/author_details_screen.dart';
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
      appBar: AppBar(
        title: const Text('Authors'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : authors.isEmpty
              ? const Center(child: Text('No authors'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: authors.length,
                  itemBuilder: (context, index) {
                    final author = authors[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: ColorManager.pink,
                          child: author.photo != null
                              ? ClipOval(
                                  child: Image.network(
                                    author.photo!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white),
                                  ),
                                )
                              : const Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(author.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${author.bookCount ?? 0} books'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AuthorDetailsScreen(authorId: author.id!),
                            ),
                          );
                          _loadAuthors();
                        },
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
