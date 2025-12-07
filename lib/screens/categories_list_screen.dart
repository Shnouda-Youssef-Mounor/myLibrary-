import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mylibrary/helper/category_helper.dart';
import 'package:mylibrary/models/category.dart';
import 'package:mylibrary/screens/category_details_screen.dart';
import 'package:mylibrary/screens/category_form_screen.dart';
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
      appBar: AppBar(title: const Text('Categories')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
          ? const Center(child: Text('No categories'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
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
                              CategoryDetailsScreen(categoryId: category.id!),
                        ),
                      );
                      _loadCategories();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: ColorManager.darkPink,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: category.icon != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: category.icon!.startsWith('http')
                                        ? Image.network(
                                            category.icon!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(
                                                  Icons.category,
                                                  color: Colors.white,
                                                  size: 32,
                                                ),
                                          )
                                        : Image.file(
                                            File(category.icon!),
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(
                                                  Icons.category,
                                                  color: Colors.white,
                                                  size: 32,
                                                ),
                                          ),
                                  )
                                : const Icon(
                                    Icons.category,
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
                                  category.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: ColorManager.darkPurple,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (category.description != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    category.description!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
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
            MaterialPageRoute(builder: (context) => const CategoryFormScreen()),
          );
          _loadCategories();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
