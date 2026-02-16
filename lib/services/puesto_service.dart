import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/puesto.dart';
import 'sync_manager.dart';

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

    // Sincronizar a Firebase en background
    final puestoConId = Puesto(
      id: id,
      nombre: puesto.nombre,
      dias: puesto.dias,
    );

    // Sincronizar con pequeño delay para asegurar que Firebase esté listo
    Future.delayed(const Duration(milliseconds: 500), () {
      SyncManager().syncPuestoToFirebase(puestoConId);
      print('✓ Iniciando sincronización para puesto: $id');
    });

    return id;
  }

  /// Inserta un puesto con ID específico (utilizado en sincronización desde Firebase)
  static Future<int> insertPuestoWithId(Puesto puesto) async {
    final db = await database;

    try {
      await db.insert('puestos', puesto.toMap());
      print(
        '✓ [SYNC] Puesto ${puesto.id} insertado desde Firebase al SQLite local',
      );
      return puesto.id ?? -1;
    } catch (e) {
      print('⚠️ [SYNC] Error insertando puesto ${puesto.id}: $e');
      return -1;
    }
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

  /// Alias para getPuestos (utilizado en sincronización)
  static Future<List<Puesto>> getAllPuestos() => getPuestos();

  static Future<int> updatePuesto(Puesto puesto) async {
    final db = await database;
    final result = await db.update(
      'puestos',
      puesto.toMapForUpdate(),
      where: 'id = ?',
      whereArgs: [puesto.id],
    );

    // Sincronizar a Firebase en background
    SyncManager().syncPuestoToFirebase(puesto);

    return result;
  }

  static Future<int> deletePuesto(int id) async {
    final db = await database;
    final result = await db.delete('puestos', where: 'id = ?', whereArgs: [id]);

    // Eliminar de Firebase en background
    SyncManager().deletePuestoFromFirebase(id);

    return result;
  }

  /// Sincroniza todos los puestos locales a Firebase
  static Future<bool> syncAllToFirebase() async {
    final puestos = await getPuestos();
    return await SyncManager().syncAllLocalToFirebase(puestos);
  }
}
