import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:timuchmilk/database/database_seed.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String databaseName = 'timuchmilk.db';
  static const int databaseVersion = 4;

  Database? _database;

  Future<void> initialize() async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not configured for Flutter web.');
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
        break;
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        break;
    }

    await database;
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final databasePath = await _resolveDatabasePath();
    debugPrint('TimuchMilk database path: $databasePath');

    return openDatabase(
      databasePath,
      version: databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < newVersion) {
          await _migrateDatabase(db, oldVersion, newVersion);
        }
      },
      onOpen: (db) async {
        await _seedDemoData(db);
      },
    );
  }

  Future<String> _resolveDatabasePath() async {
    final databaseDirectory = path.join(
      Directory.current.path,
      'lib',
      'database',
    );
    await Directory(databaseDirectory).create(recursive: true);

    return path.join(databaseDirectory, databaseName);
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        first_name TEXT NOT NULL,
        password TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        creation_date TEXT NOT NULL,
        address TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS cows (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        breed TEXT NOT NULL,
        age INTEGER NOT NULL,
        status TEXT NOT NULL,
        health TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        priority TEXT NOT NULL,
        due_date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS milk_productions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quantity REAL NOT NULL,
        production_date TEXT NOT NULL,
        moment TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS foods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        stock REAL NOT NULL,
        unit TEXT NOT NULL,
        category TEXT NOT NULL,
        purchase_date TEXT NOT NULL,
        unit_price REAL NOT NULL,
        daily_consumption REAL NOT NULL DEFAULT 0,
        photo_path TEXT
      )
    ''');
  }

  Future<void> _migrateDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    await _createTables(db);

    if (oldVersion < 3) {
      await _ensureColumnExists(
        db,
        tableName: 'foods',
        columnName: 'photo_path',
        columnDefinition: 'TEXT',
      );
    }

    if (oldVersion < 4) {
      await _ensureColumnExists(
        db,
        tableName: 'foods',
        columnName: 'daily_consumption',
        columnDefinition: 'REAL NOT NULL DEFAULT 0',
      );
    }
  }

  Future<void> _ensureColumnExists(
    Database db, {
    required String tableName,
    required String columnName,
    required String columnDefinition,
  }) async {
    final columns = await db.rawQuery('PRAGMA table_info($tableName)');
    final exists = columns.any((column) => column['name'] == columnName);

    if (!exists) {
      await db.execute(
        'ALTER TABLE $tableName ADD COLUMN $columnName $columnDefinition',
      );
    }
  }

  Future<void> _seedDemoData(Database db) async {
    await DatabaseSeed.seedIfEmpty(db);
  }

  Future<void> clearDatabase() async {
    await DatabaseSeed.clearAll(await database);
  }

  Future<void> seedDatabase() async {
    await DatabaseSeed.seedAll(await database);
  }

  Future<void> resetAndSeedDatabase() async {
    await DatabaseSeed.resetAndSeed(await database);
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
