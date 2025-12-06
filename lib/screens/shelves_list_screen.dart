import 'package:flutter/material.dart';
import 'package:mylibrary/helper/shelf_helper.dart';
import 'package:mylibrary/models/shelf.dart';
import 'package:mylibrary/screens/shelf_form_screen.dart';
import 'package:mylibrary/screens/shelf_details_screen.dart';
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
      appBar: AppBar(
        title: const Text('Shelves'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : shelves.isEmpty
              ? const Center(child: Text('No shelves'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: shelves.length,
                  itemBuilder: (context, index) {
                    final shelf = shelves[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: shelf.color != null ? Color(int.parse(shelf.color!.replaceFirst('#', '0xFF'))) : ColorManager.pink,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.shelves, color: Colors.white),
                        ),
                        title: Text(shelf.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: shelf.description != null ? Text(shelf.description!) : null,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShelfDetailsScreen(shelfId: shelf.id!),
                            ),
                          );
                          _loadShelves();
                        },
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
