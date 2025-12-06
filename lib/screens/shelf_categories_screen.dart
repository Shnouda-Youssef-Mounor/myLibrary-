import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mylibrary/helper/category_helper.dart';
import 'package:mylibrary/models/category.dart';
import 'package:mylibrary/models/shelf.dart';
import 'package:mylibrary/screens/category_books_screen.dart';
import 'package:mylibrary/utils/color_manager.dart';

class ShelfCategoriesScreen extends StatefulWidget {
  final Shelf shelf;

  const ShelfCategoriesScreen({super.key, required this.shelf});

  @override
  State<ShelfCategoriesScreen> createState() => _ShelfCategoriesScreenState();
}

class _ShelfCategoriesScreenState extends State<ShelfCategoriesScreen> {
  List<Category> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => isLoading = true);
    categories = await CategoryHelper.getByShelfId(widget.shelf.id!);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final shelfColor = widget.shelf.color != null
        ? Color(int.parse(widget.shelf.color!.replaceFirst('#', '0xFF')))
        : ColorManager.darkPurple;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shelf.name),
        backgroundColor: shelfColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
              ? const Center(child: Text('No categories in this shelf'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryBooksScreen(category: category),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              shelfColor.withOpacity(0.8),
                              shelfColor.withOpacity(0.6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (category.icon != null)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: category.icon!.startsWith('http')
                                        ? Image.network(
                                            category.icon!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => const Icon(Icons.category, color: Colors.white, size: 48),
                                          )
                                        : Image.file(
                                            File(category.icon!),
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => const Icon(Icons.category, color: Colors.white, size: 48),
                                          ),
                                  ),
                                ),
                              )
                            else
                              const Expanded(
                                child: Icon(Icons.category, color: Colors.white, size: 48),
                              ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              child: Text(
                                category.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
