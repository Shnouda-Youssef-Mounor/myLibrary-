import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mylibrary/helper/shelf_helper.dart';
import 'package:mylibrary/helper/category_helper.dart';
import 'package:mylibrary/models/shelf.dart';
import 'package:mylibrary/models/category.dart';
import 'package:mylibrary/screens/shelf_categories_screen.dart';
import 'package:mylibrary/screens/category_books_screen.dart';
import 'package:mylibrary/screens/shelf_form_screen.dart';
import 'package:mylibrary/screens/book_form_screen.dart';
import 'package:mylibrary/screens/author_form_screen.dart';
import 'package:mylibrary/screens/category_form_screen.dart';
import 'package:mylibrary/utils/color_manager.dart';

class LibraryViewScreen extends StatefulWidget {
  const LibraryViewScreen({super.key});

  @override
  State<LibraryViewScreen> createState() => _LibraryViewScreenState();
}

class _LibraryViewScreenState extends State<LibraryViewScreen> {
  List<Shelf> shelves = [];
  Map<int, List<Category>> categoriesByShelf = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    shelves = await ShelfHelper.getAll();
    final allCategories = await CategoryHelper.getAll();
    
    categoriesByShelf.clear();
    for (var category in allCategories) {
      if (!categoriesByShelf.containsKey(category.shelfId)) {
        categoriesByShelf[category.shelfId] = [];
      }
      categoriesByShelf[category.shelfId]!.add(category);
    }
    
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenu(context),
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : shelves.isEmpty
              ? const Center(child: Text('No shelves in library'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: shelves.length,
                  itemBuilder: (context, index) {
                    final shelf = shelves[index];
                    final categories = categoriesByShelf[shelf.id] ?? [];
                    return _buildShelf(shelf, categories);
                  },
                ),
    );
  }

  Widget _buildShelf(Shelf shelf, List<Category> categories) {
    final shelfColor = shelf.color != null 
        ? Color(int.parse(shelf.color!.replaceFirst('#', '0xFF')))
        : ColorManager.darkPurple;

    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShelfCategoriesScreen(shelf: shelf),
                ),
              );
            },
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 30,
                  decoration: BoxDecoration(
                    color: shelfColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  shelf.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: shelfColor,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, size: 16, color: shelfColor),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: shelfColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: shelfColor.withOpacity(0.3), width: 2),
            ),
            child: Column(
              children: [
                if (categories.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Empty shelf',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final crossAxisCount = width > 1200 ? 6 : width > 800 ? 4 : width > 600 ? 3 : 2;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return _buildBook(categories[index], shelfColor);
                        },
                      );
                    },
                  ),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: shelfColor.withOpacity(0.5),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBook(Category category, Color shelfColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final iconSize = constraints.maxWidth * 0.4;
        final fontSize = constraints.maxWidth * 0.12;
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
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
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
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: category.icon!.startsWith('http')
                          ? Image.network(
                              category.icon!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(Icons.category, color: Colors.white, size: iconSize),
                            )
                          : Image.file(
                              File(category.icon!),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(Icons.category, color: Colors.white, size: iconSize),
                            ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Icon(Icons.category, color: Colors.white, size: iconSize),
                ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(constraints.maxWidth * 0.08),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  category.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize.clamp(10.0, 14.0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        );
      },
    );
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.shelves, color: ColorManager.darkPurple),
              title: const Text('Add Shelf'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShelfFormScreen()),
                );
                _loadData();
              },
            ),
            ListTile(
              leading: const Icon(Icons.category, color: ColorManager.darkPink),
              title: const Text('Add Category'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CategoryFormScreen()),
                );
                _loadData();
              },
            ),
            ListTile(
              leading: const Icon(Icons.book, color: ColorManager.pink),
              title: const Text('Add Book'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BookFormScreen()),
                );
                _loadData();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: ColorManager.darkPurple),
              title: const Text('Add Author'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthorFormScreen()),
                );
                _loadData();
              },
            ),
          ],
        ),
      ),
    );
  }
}
