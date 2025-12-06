import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mylibrary/helper/category_helper.dart';
import 'package:mylibrary/models/category.dart';
import 'package:mylibrary/screens/category_form_screen.dart';
import 'package:mylibrary/utils/color_manager.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final int categoryId;

  const CategoryDetailsScreen({super.key, required this.categoryId});

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  Category? category;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategory();
  }

  Future<void> _loadCategory() async {
    setState(() => isLoading = true);
    category = await CategoryHelper.getById(widget.categoryId);
    setState(() => isLoading = false);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text('This will delete all books in this category. Are you sure?'),
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
      await CategoryHelper.delete(widget.categoryId);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryFormScreen(category: category),
                ),
              );
              _loadCategory();
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
          : category == null
              ? const Center(child: Text('Category not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: ColorManager.darkPink,
                        child: category!.icon != null
                            ? ClipOval(
                                child: category!.icon!.startsWith('http')
                                    ? Image.network(category!.icon!, width: 120, height: 120, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.category, size: 60, color: Colors.white))
                                    : Image.file(File(category!.icon!), width: 120, height: 120, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.category, size: 60, color: Colors.white)),
                              )
                            : const Icon(Icons.category, size: 60, color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        category!.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: ColorManager.darkPurple,
                        ),
                      ),
                      if (category!.description != null) ...[
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
                                'Description',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: ColorManager.darkPurple,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category!.description!,
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
