import 'package:mylibrary/helper/db_helper.dart';
import 'package:mylibrary/models/author.dart';

class AuthorHelper {
  static Future<List<Author>> getAll() async {
    final db = await DBHelper.instance.database;
    final result = await db.rawQuery('''
      SELECT a.*, COUNT(ba.book_id) as book_count
      FROM authors a
      LEFT JOIN book_authors ba ON a.id = ba.author_id
      GROUP BY a.id
      ORDER BY a.name ASC
    ''');
    return result.map((map) => Author.fromMap(map)).toList();
  }

  static Future<Author?> getById(int id) async {
    final db = await DBHelper.instance.database;
    final result = await db.rawQuery('''
      SELECT a.*, COUNT(ba.book_id) as book_count
      FROM authors a
      LEFT JOIN book_authors ba ON a.id = ba.author_id
      WHERE a.id = ?
      GROUP BY a.id
    ''', [id]);
    return result.isNotEmpty ? Author.fromMap(result.first) : null;
  }

  static Future<int> create(String name, String? bio, String? photo) async {
    final db = await DBHelper.instance.database;
    return await db.insert('authors', {
      'name': name,
      'bio': bio,
      'photo': photo,
    });
  }

  static Future<int> update(int id, String name, String? bio, String? photo) async {
    final db = await DBHelper.instance.database;
    return await db.update(
      'authors',
      {'name': name, 'bio': bio, 'photo': photo},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> delete(int id) async {
    final db = await DBHelper.instance.database;
    return await db.delete('authors', where: 'id = ?', whereArgs: [id]);
  }
}
