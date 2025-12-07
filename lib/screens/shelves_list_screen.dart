import 'package:flutter/material.dart';
import 'package:mylibrary/helper/shelf_helper.dart';
import 'package:mylibrary/models/shelf.dart';
import 'package:mylibrary/screens/shelf_details_screen.dart';
import 'package:mylibrary/screens/shelf_form_screen.dart';
import 'package:mylibrary/utils/color_manager.dart';

class ShelvesListScreen extends StatefulWidget {
  const ShelvesListScreen({super.key});

  @override
  State<ShelvesListScreen> createState() => _ShelvesListScreenState();
}

class _ShelvesListScreenState extends State<ShelvesListScreen> {
  List<Shelf> shelves = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShelves();
  }

  Future<void> _loadShelves() async {
    setState(() => isLoading = true);
    shelves = await ShelfHelper.getAll();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shelves')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : shelves.isEmpty
          ? const Center(child: Text('No shelves'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: shelves.length,
              itemBuilder: (context, index) {
                final shelf = shelves[index];
                final shelfColor = shelf.color != null
                    ? Color(int.parse(shelf.color!.replaceFirst('#', '0xFF')))
                    : ColorManager.pink;
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
                              ShelfDetailsScreen(shelfId: shelf.id!),
                        ),
                      );
                      _loadShelves();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: shelfColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.shelves,
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
                                  shelf.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: ColorManager.darkPurple,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (shelf.description != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    shelf.description!,
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
            MaterialPageRoute(builder: (context) => const ShelfFormScreen()),
          );
          _loadShelves();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
