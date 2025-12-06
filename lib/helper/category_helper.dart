import 'package:mylibrary/helper/db_helper.dart';
import 'package:mylibrary/models/category.dart';

class CategoryHelper {
  static Future<List<Category>> getAll() async {
    final db = await DBHelper.instance.database;
    final result = await db.query('categories', orderBy: 'name ASC');
    return result.map((map) => Category.fromMap(map)).toList();
  }

  static Future<Category?> getById(int id) async {
    final db = await DBHelper.instance.database;
    final result = await db.query('categories', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? Category.fromMap(result.first) : null;
  }

  static Future<int> create(int shelfId, String name, String? description, String? icon) async {
    final db = await DBHelper.instance.database;
    return await db.insert('categories', {
      'shelf_id': shelfId,
      'name': name,
      'description': description,
      'icon': icon,
    });
  }

  static Future<int> update(int id, int shelfId, String name, String? description, String? icon) async {
    final db = await DBHelper.instance.database;
    return await db.update(
      'categories',
      {
        'shelf_id': shelfId,
        'name': name,
        'description': description,
        'icon': icon,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> delete(int id) async {
    final db = await DBHelper.instance.database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Category>> getByShelfId(int shelfId) async {
    final db = await DBHelper.instance.database;
    final result = await db.query('categories', where: 'shelf_id = ?', whereArgs: [shelfId], orderBy: 'name ASC');
    return result.map((map) => Category.fromMap(map)).toList();
  }
}
