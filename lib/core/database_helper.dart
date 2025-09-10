import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'hospital_device.db');
    return await openDatabase(path, version: 4, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE hospitals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      );
    ''');
    await db.execute('''
      CREATE TABLE devices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hospitalId INTEGER,
        name TEXT,
        serialNo TEXT,
        maintenanceDate TEXT,
        maintenanceStatus TEXT,
        note TEXT,
        FOREIGN KEY (hospitalId) REFERENCES hospitals(id) ON DELETE CASCADE
      );
    ''');
    await db.execute('''
      CREATE TABLE assets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hospitalId INTEGER,
        name TEXT NOT NULL,
        FOREIGN KEY (hospitalId) REFERENCES hospitals(id) ON DELETE CASCADE
      );
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE assets (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          hospitalId INTEGER,
          name TEXT NOT NULL,
          FOREIGN KEY (hospitalId) REFERENCES hospitals(id) ON DELETE CASCADE
        );
      ''');
    }
  }

  Future<List<Map<String, dynamic>>> getAssets(int hospitalId) async {
    final dbClient = await db;
    return await dbClient.query('assets', where: 'hospitalId = ?', whereArgs: [hospitalId]);
  }

  Future<void> insertAsset(int hospitalId, String name) async {
    final dbClient = await db;
    await dbClient.insert('assets', {'hospitalId': hospitalId, 'name': name});
  }

  Future<void> deleteAsset(int id) async {
    final dbClient = await db;
    await dbClient.delete('assets', where: 'id = ?', whereArgs: [id]);
  }
}
