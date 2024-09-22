import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/shift.dart';
import '../models/settings.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('shiftview.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE shifts(
  id TEXT PRIMARY KEY,
  startTime TEXT NOT NULL,
  endTime TEXT NOT NULL,
  breakDuration INTEGER NOT NULL,
  hourlyRate REAL NOT NULL
)
''');

    await db.execute('''
CREATE TABLE settings(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  defaultHourlyRate REAL NOT NULL,
  defaultBreakDuration INTEGER NOT NULL,
  currency TEXT NOT NULL,
  language TEXT NOT NULL,
  theme TEXT NOT NULL
)
''');
  }

  // Shift methods
  Future<void> insertShift(Shift shift) async {
    final db = await database;
    await db.insert('shifts', shift.toJson());
  }

  Future<List<Shift>> getShifts() async {
    final db = await database;
    final maps = await db.query('shifts');
    return List.generate(maps.length, (i) => Shift.fromJson(maps[i]));
  }

  Future<void> updateShift(Shift shift) async {
    final db = await database;
    await db.update(
      'shifts',
      shift.toJson(),
      where: 'id = ?',
      whereArgs: [shift.id],
    );
  }

  Future<void> deleteShift(String id) async {
    final db = await database;
    await db.delete(
      'shifts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Settings methods
  Future<void> insertSettings(Settings settings) async {
    final db = await database;
    await db.insert('settings', settings.toJson());
  }

  Future<Settings?> getSettings() async {
    final db = await database;
    final maps = await db.query('settings');
    if (maps.isNotEmpty) {
      return Settings.fromJson(maps.first);
    }
    return null;
  }

  Future<void> updateSettings(Settings settings) async {
    final db = await database;
    await db.update(
      'settings',
      settings.toJson(),
      where: 'id = ?',
      whereArgs: [settings.id],
    );
  }
}
