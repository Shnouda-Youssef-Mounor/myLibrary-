import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mylibrary/helper/category_helper.dart';
import 'package:mylibrary/models/category.dart';
import 'package:mylibrary/screens/category_form_screen.dart';
import 'package:mylibrary/screens/category_details_screen.dart';
import 'package:mylibrary/utils/color_manager.dart';

class CategoriesListScreen extends StatefulWidget {
  const CategoriesListScreen({super.key});

  @override
  State<CategoriesListScreen> createState() => _CategoriesListScreenState();
}

class _CategoriesListScreenState extends State<CategoriesListScreen> {
  List<Category> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => isLoading = true);
    categories = await CategoryHelper.getAll();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
              ? const Center(child: Text('No categories'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: ColorManager.darkPink,
                          child: category.icon != null
                              ? ClipOval(
                                  child: category.icon!.startsWith('http')
                                      ? Image.network(category.icon!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.category, color: Colors.white))
                                      : Image.file(File(category.icon!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.category, color: Colors.white)),
                                )
                              : const Icon(Icons.category, color: Colors.white),
                        ),
                        title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: category.description != null ? Text(category.description!) : null,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryDetailsScreen(categoryId: category.id!),
                            ),
                          );
                          _loadCategories();
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CategoryFormScreen()),
          );
          _loadCategories();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
