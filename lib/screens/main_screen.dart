import 'package:flutter/material.dart';
import 'package:mylibrary/screens/home_screen.dart';
import 'package:mylibrary/screens/books_list_screen.dart';
import 'package:mylibrary/screens/categories_list_screen.dart';
import 'package:mylibrary/screens/shelves_list_screen.dart';
import 'package:mylibrary/utils/color_manager.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const BooksListScreen(),
    const CategoriesListScreen(),
    const ShelvesListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: ColorManager.darkPink,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Books',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shelves),
            label: 'Shelves',
          ),
        ],
      ),
    );
  }
}
