import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  // ---------- Singleton ----------
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;

  // ---------- Get Database ----------
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("library.db");
    return _database!;
  }

  // ---------- Init Database ----------
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    print("DB Path: $path");

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // ---------- Create Tables ----------
  Future<void> _createDB(Database db, int version) async {
    // ---------------- Shelves ----------------
    await db.execute("""
      CREATE TABLE shelves (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        color TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    """);

    // ---------------- Categories ----------------
    await db.execute("""
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shelf_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        icon TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (shelf_id) REFERENCES shelves(id)
          ON DELETE CASCADE
          ON UPDATE CASCADE
      );
    """);

    // ---------------- Books ----------------
    await db.execute("""
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        cover_image TEXT,
        file_path TEXT,
        description TEXT,
        pages INTEGER,
        publish_year INTEGER,
        status TEXT,
        rating REAL,
        notes TEXT,
        favorite INTEGER DEFAULT 0,
        added_at TEXT DEFAULT CURRENT_TIMESTAMP,
        finished_at TEXT,
        FOREIGN KEY (category_id) REFERENCES categories(id)
          ON DELETE CASCADE
          ON UPDATE CASCADE
      );
    """);

    // ---------------- Authors ----------------
    await db.execute("""
      CREATE TABLE authors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        bio TEXT,
        photo TEXT
      );
    """);

    // ---------------- Book Authors (Many-To-Many) ----------------
    await db.execute("""
      CREATE TABLE book_authors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_id INTEGER NOT NULL,
        author_id INTEGER NOT NULL,
        FOREIGN KEY (book_id) REFERENCES books(id)
          ON DELETE CASCADE
          ON UPDATE CASCADE,
        FOREIGN KEY (author_id) REFERENCES authors(id)
          ON DELETE CASCADE
          ON UPDATE CASCADE
      );
    """);
  }

  // ---------- Upgrade Database ----------
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE books ADD COLUMN file_path TEXT');
    }
  }

  // ---------- Reset Database ----------
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "library.db");
    
    await _database?.close();
    _database = null;
    
    await deleteDatabase(path);
    print("Database deleted and reset");
  }

  // ---------- Close Database ----------
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
