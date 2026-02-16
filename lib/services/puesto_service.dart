import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/puesto.dart';

class PuestoService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'puestos.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE puestos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT,
            dias TEXT
          )
        ''');
      },
    );
  }

  static Future<int> insertPuesto(Puesto puesto) async {
    final db = await database;
    final map = puesto.toMapForInsert();
    final id = await db.insert('puestos', map);
    return id;
  }

  static Future<List<Puesto>> getPuestos() async {
    final db = await database;
    final maps = await db.query('puestos');
    try {
      return maps.map((map) {
        return Puesto.fromMap(map);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<int> updatePuesto(Puesto puesto) async {
    final db = await database;
    return await db.update(
      'puestos',
      puesto.toMapForUpdate(),
      where: 'id = ?',
      whereArgs: [puesto.id],
    );
  }

  static Future<int> deletePuesto(int id) async {
    final db = await database;
    return await db.delete('puestos', where: 'id = ?', whereArgs: [id]);
  }
}
