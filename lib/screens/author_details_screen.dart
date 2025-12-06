import 'package:flutter/material.dart';
import 'package:mylibrary/helper/author_helper.dart';
import 'package:mylibrary/models/author.dart';
import 'package:mylibrary/screens/author_form_screen.dart';
import 'package:mylibrary/utils/color_manager.dart';

class AuthorDetailsScreen extends StatefulWidget {
  final int authorId;

  const AuthorDetailsScreen({super.key, required this.authorId});

  @override
  State<AuthorDetailsScreen> createState() => _AuthorDetailsScreenState();
}

class _AuthorDetailsScreenState extends State<AuthorDetailsScreen> {
  Author? author;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAuthor();
  }

  Future<void> _loadAuthor() async {
    setState(() => isLoading = true);
    author = await AuthorHelper.getById(widget.authorId);
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
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _delete,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : author == null
              ? const Center(child: Text('Author not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: ColorManager.pink,
                        child: author!.photo != null
                            ? ClipOval(
                                child: Image.network(
                                  author!.photo!,
                                  fit: BoxFit.cover,
                                  width: 120,
                                  height: 120,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 60, color: Colors.white),
                                ),
                              )
                            : const Icon(Icons.person, size: 60, color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        author!.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: ColorManager.darkPurple,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${author!.bookCount ?? 0} books',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (author!.bio != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: ColorManager.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: ColorManager.pink),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bio',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: ColorManager.darkPurple,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                author!.bio!,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}
