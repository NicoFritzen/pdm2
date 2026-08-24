import 'package:sqflite/sqflite.dart';

/// Singleton do arquivo SQLite (`desafio2.db` na pasta privada do app).
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String dbName = 'desafio2.db';

  static const int dbVersion = 2;

  static const String itemsTable = 'items';

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  /// [openDatabase] só chama [_onCreate] se o arquivo ainda não existir.
  Future<Database> _open() async {
    final String databasesPath = await getDatabasesPath();
    final String path = '$databasesPath/$dbName';

    return openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        await db.execute('DROP TABLE IF EXISTS $itemsTable');
        await _onCreate(db, newVersion);
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $itemsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        image_path TEXT NOT NULL
      )
    ''');
  }
}
