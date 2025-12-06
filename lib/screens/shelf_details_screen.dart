import 'package:flutter/material.dart';
import 'package:mylibrary/helper/shelf_helper.dart';
import 'package:mylibrary/models/shelf.dart';
import 'package:mylibrary/screens/shelf_form_screen.dart';
import 'package:mylibrary/utils/color_manager.dart';

class ShelfDetailsScreen extends StatefulWidget {
  final int shelfId;

  const ShelfDetailsScreen({super.key, required this.shelfId});

  @override
  State<ShelfDetailsScreen> createState() => _ShelfDetailsScreenState();
}

class _ShelfDetailsScreenState extends State<ShelfDetailsScreen> {
  Shelf? shelf;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShelf();
  }

  Future<void> _loadShelf() async {
    setState(() => isLoading = true);
    shelf = await ShelfHelper.getById(widget.shelfId);
    setState(() => isLoading = false);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Shelf'),
        content: const Text('This will delete all categories and books in this shelf. Are you sure?'),
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
      await ShelfHelper.delete(widget.shelfId);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shelf Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShelfFormScreen(shelf: shelf),
                ),
              );
              _loadShelf();
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
          : shelf == null
              ? const Center(child: Text('Shelf not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: shelf!.color != null ? Color(int.parse(shelf!.color!.replaceFirst('#', '0xFF'))) : ColorManager.pink,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.shelves, size: 60, color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        shelf!.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: ColorManager.darkPurple,
                        ),
                      ),
                      if (shelf!.description != null) ...[
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
                                shelf!.description!,
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
