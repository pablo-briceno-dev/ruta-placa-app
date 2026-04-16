import 'package:path/path.dart';
import 'package:ruta_placa/models/route_city.dart';
import 'package:ruta_placa/models/vehicle.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ruta_placa.db');

    return openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createVehiclesTable(db);
        }
        if (oldVersion < 3) {
          // Agregar columna a usuarios existentes
          await db.execute('''
            ALTER TABLE vehicles
            ADD COLUMN plate_origin_index INTEGER NOT NULL DEFAULT 0
          ''');
        }
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await _createRouteCitiesTable(db);
    await _createVehiclesTable(db);
  }

  Future<void> _createRouteCitiesTable(Database db) async {
    await db.execute('''
      CREATE TABLE route_cities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        city_id TEXT NOT NULL,
        city_name TEXT NOT NULL,
        city_emoji TEXT NOT NULL,
        order_route INTEGER NOT NULL,
        added_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createVehiclesTable(Database db) async {
    await db.execute('''
      CREATE TABLE vehicles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plate TEXT NOT NULL UNIQUE,
        alias TEXT NOT NULL,
        city_id TEXT NOT NULL,
        vehicle_type_index INTEGER NOT NULL DEFAULT 0,
        is_default INTEGER NOT NULL DEFAULT 0,
        plate_origin_index   INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // ----- CRUD route_cities --------------------------------------------------
  Future<List<RouteCity>> getAll() async {
    final database = await db;
    final maps = await database.query(
      'route_cities',
      orderBy: '"order_route" ASC',
    );
    return maps.map(RouteCity.fromMap).toList();
  }

  Future<RouteCity> insert(RouteCity routeCity) async {
    final database = await db;
    final id = await database.insert(
      'route_cities',
      routeCity.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return routeCity.copyWith(id: id);
  }

  Future<void> delete(int id) async {
    final database = await db;
    await database.delete('route_cities', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAll() async {
    final database = await db;
    await database.delete('route_cities');
  }

  // Preserva la última ciudad (mayor order)
  Future<void> deleteAllExceptLast() async {
    final database = await db;
    await database.execute('''
      DELETE FROM route_cities
      WHERE id NOT IN (
        SELECT id FROM route_cities
        ORDER BY "order_route" DESC
        LIMIT 1
      )
    ''');
  }

  Future<void> updateOrder(int id, int newOrder) async {
    final database = await db;
    await database.update(
      'route_cities',
      {'order': newOrder},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ----- CRUD vehicles --------------------------------------------------
  // ── Vehículos ──────────────────────────────────────────

  Future<List<Vehicle>> getAllVehicles() async {
    final database = await db;
    final maps = await database.query(
      'vehicles',
      orderBy: 'is_default DESC, created_at ASC',
    );
    return maps.map(Vehicle.fromMap).toList();
  }

  Future<Vehicle> insertVehicle(Vehicle vehicle) async {
    final database = await db;

    // Si es el primero, hacerlo default automáticamente
    final count =
        Sqflite.firstIntValue(
          await database.rawQuery('SELECT COUNT(*) FROM vehicles'),
        ) ??
        0;
    final isDefault = count == 0 ? 1 : (vehicle.isDefault ? 1 : 0);

    final id = await database.insert('vehicles', {
      'plate': vehicle.plate.toUpperCase(),
      'alias': vehicle.alias,
      'city_id': vehicle.cityId,
      'vehicle_type_index': vehicle.vehicleTypeIndex,
      'is_default': isDefault,
      'plate_origin_index': vehicle.plateOriginIndex,
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return vehicle.copyWith(id: id, isDefault: isDefault == 1);
  }

  Future<void> deleteVehicle(String plate) async {
    final database = await db;

    // Si era el default, asignar otro como default
    final wasDefault =
        Sqflite.firstIntValue(
          await database.rawQuery(
            'SELECT is_default FROM vehicles WHERE plate = ?',
            [plate],
          ),
        ) ==
        1;

    await database.delete('vehicles', where: 'plate = ?', whereArgs: [plate]);

    if (wasDefault) {
      final remaining = await database.query('vehicles', limit: 1);
      if (remaining.isNotEmpty) {
        await database.update(
          'vehicles',
          {'is_default': 1},
          where: 'id = ?',
          whereArgs: [remaining.first['id']],
        );
      }
    }
  }

  Future<void> setDefaultVehicle(int id) async {
    final database = await db;
    await database.transaction((txn) async {
      // Quitar default a todos
      await txn.update('vehicles', {'is_default': 0});
      // Asignar default al seleccionado
      await txn.update(
        'vehicles',
        {'is_default': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    final database = await db;
    await database.update(
      'vehicles',
      {
        'plate': vehicle.plate.toUpperCase(),
        'alias': vehicle.alias,
        'city_id': vehicle.cityId,
        'vehicle_type_index': vehicle.vehicleTypeIndex,
        'plate_origin_index': vehicle.plateOriginIndex,
      },
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
  }
}
