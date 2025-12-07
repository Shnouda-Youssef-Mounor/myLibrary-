import 'package:mylibrary/helper/db_helper.dart';
import 'package:mylibrary/models/book.dart';
import 'package:mylibrary/models/author.dart';

class BookHelper {
  static Future<List<Book>> getAll() async {
    final db = await DBHelper.instance.database;
    final result = await db.rawQuery('''
      SELECT b.*, GROUP_CONCAT(a.name, ', ') as authors, GROUP_CONCAT(a.id, ',') as author_ids
      FROM books b
      LEFT JOIN book_authors ba ON b.id = ba.book_id
      LEFT JOIN authors a ON ba.author_id = a.id
      GROUP BY b.id
      ORDER BY b.added_at DESC
    ''');
    return result.map((map) => Book.fromMap(map)).toList();
  }

  static Future<Book?> getById(int id) async {
    final db = await DBHelper.instance.database;
    final result = await db.rawQuery('''
      SELECT b.*, GROUP_CONCAT(a.name, ', ') as authors, GROUP_CONCAT(a.id, ',') as author_ids
      FROM books b
      LEFT JOIN book_authors ba ON b.id = ba.book_id
      LEFT JOIN authors a ON ba.author_id = a.id
      WHERE b.id = ?
      GROUP BY b.id
    ''', [id]);
    return result.isNotEmpty ? Book.fromMap(result.first) : null;
  }

  static Future<int> create({
    required int categoryId,
    required String title,
    String? coverImage,
    String? filePath,
    String? description,
    int? pages,
    int? publishYear,
    String? status,
    double? rating,
    String? notes,
    bool favorite = false,
    List<int>? authorIds,
  }) async {
    final db = await DBHelper.instance.database;
    final bookId = await db.insert('books', {
      'category_id': categoryId,
      'title': title,
      'cover_image': coverImage,
      'file_path': filePath,
      'description': description,
      'pages': pages,
      'publish_year': publishYear,
      'status': status,
      'rating': rating,
      'notes': notes,
      'favorite': favorite ? 1 : 0,
    });

    if (authorIds != null) {
      for (var authorId in authorIds) {
        await db.insert('book_authors', {
          'book_id': bookId,
          'author_id': authorId,
        });
      }
    }

    return bookId;
  }

  static Future<int> update({
    required int id,
    required int categoryId,
    required String title,
    String? coverImage,
    String? filePath,
    String? description,
    int? pages,
    int? publishYear,
    String? status,
    double? rating,
    String? notes,
    bool favorite = false,
    List<int>? authorIds,
  }) async {
    final db = await DBHelper.instance.database;
    final result = await db.update(
      'books',
      {
        'category_id': categoryId,
        'title': title,
        'cover_image': coverImage,
        'file_path': filePath,
        'description': description,
        'pages': pages,
        'publish_year': publishYear,
        'status': status,
        'rating': rating,
        'notes': notes,
        'favorite': favorite ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    await db.delete('book_authors', where: 'book_id = ?', whereArgs: [id]);
    if (authorIds != null) {
      for (var authorId in authorIds) {
        await db.insert('book_authors', {
          'book_id': id,
          'author_id': authorId,
        });
      }
    }

    return result;
  }

  static Future<int> delete(int id) async {
    final db = await DBHelper.instance.database;
    return await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }
  static Future<List<Book>> getTopRatedBooks({int limit = 10}) async {
    final db = await DBHelper.instance.database;
    final result = await db.rawQuery('''
      SELECT b.*, GROUP_CONCAT(a.name, ', ') as authors
      FROM books b
      LEFT JOIN book_authors ba ON b.id = ba.book_id
      LEFT JOIN authors a ON ba.author_id = a.id
      WHERE b.rating IS NOT NULL
      GROUP BY b.id
      ORDER BY b.rating DESC, b.title ASC
      LIMIT ?
    ''', [limit]);
    return result.map((map) => Book.fromMap(map)).toList();
  }

  static Future<Book?> getCurrentlyReading() async {
    final db = await DBHelper.instance.database;
    final result = await db.rawQuery('''
      SELECT b.*, GROUP_CONCAT(a.name, ', ') as authors
      FROM books b
      LEFT JOIN book_authors ba ON b.id = ba.book_id
      LEFT JOIN authors a ON ba.author_id = a.id
      WHERE b.status = 'reading'
      GROUP BY b.id
      ORDER BY b.added_at DESC
      LIMIT 1
    ''');
    return result.isNotEmpty ? Book.fromMap(result.first) : null;
  }

  static Future<List<Author>> getAuthors() async {
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

  static Future<List<Author>> getAllAuthors() async {
    final db = await DBHelper.instance.database;
    final result = await db.query('authors', orderBy: 'name ASC');
    return result.map((map) => Author.fromMap(map)).toList();
  }

  static Future<List<Book>> getFavoriteBooks() async {
    final db = await DBHelper.instance.database;
    final result = await db.rawQuery('''
      SELECT b.*, GROUP_CONCAT(a.name, ', ') as authors, GROUP_CONCAT(a.id, ',') as author_ids
      FROM books b
      LEFT JOIN book_authors ba ON b.id = ba.book_id
      LEFT JOIN authors a ON ba.author_id = a.id
      WHERE b.favorite = 1
      GROUP BY b.id
      ORDER BY b.added_at DESC
    ''');
    return result.map((map) => Book.fromMap(map)).toList();
  }

  static Future<List<Book>> getByCategoryId(int categoryId) async {
    final db = await DBHelper.instance.database;
    final result = await db.rawQuery('''
      SELECT b.*, GROUP_CONCAT(a.name, ', ') as authors, GROUP_CONCAT(a.id, ',') as author_ids
      FROM books b
      LEFT JOIN book_authors ba ON b.id = ba.book_id
      LEFT JOIN authors a ON ba.author_id = a.id
      WHERE b.category_id = ?
      GROUP BY b.id
      ORDER BY b.title ASC
    ''', [categoryId]);
    return result.map((map) => Book.fromMap(map)).toList();
  }
}
