import 'package:mylibrary/helper/db_helper.dart';
import 'package:mylibrary/models/shelf.dart';

class ShelfHelper {
  static Future<List<Shelf>> getAll() async {
    final db = await DBHelper.instance.database;
    final result = await db.query('shelves', orderBy: 'name ASC');
    return result.map((map) => Shelf.fromMap(map)).toList();
  }

  static Future<Shelf?> getById(int id) async {
    final db = await DBHelper.instance.database;
    final result = await db.query('shelves', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? Shelf.fromMap(result.first) : null;
  }

  static Future<int> create(String name, String? description, String? color) async {
    final db = await DBHelper.instance.database;
    return await db.insert('shelves', {
      'name': name,
      'description': description,
      'color': color,
    });
  }

  static Future<int> update(int id, String name, String? description, String? color) async {
    final db = await DBHelper.instance.database;
    return await db.update(
      'shelves',
      {
        'name': name,
        'description': description,
        'color': color,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> delete(int id) async {
    final db = await DBHelper.instance.database;
    return await db.delete('shelves', where: 'id = ?', whereArgs: [id]);
  }
}
