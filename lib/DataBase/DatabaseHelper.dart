import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _databaseName = 'offline_todos.db';
  static const int _databaseVersion = 4;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialisation de la base de données
  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // CREATION DES TABLES
  static Future<void> _onCreate(Database db, int version) async {
    print("🏗️ Création de la base de données locale...");

    // TABLE UTILISATEURS
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_account_id INTEGER,        -- ID du serveur MySQL 
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        profile_photo_path TEXT,
        synced INTEGER DEFAULT 0          -- BONUS: sync avec serveur
      )
    ''');

    // TABLE TÂCHES
    await db.execute('''
      CREATE TABLE todos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        todo_id INTEGER,           -- ID du serveur (null si pas sync)
        account_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        todo TEXT NOT NULL,
        done INTEGER DEFAULT 0,         
        synced INTEGER DEFAULT 0,        -- 0 = pas sync, 1 = sync
        created_locally INTEGER DEFAULT 1, -- 1 = créé hors ligne
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        LocalTodoId INTEGER,
        FOREIGN KEY (account_id) REFERENCES users (id)
      )
    ''');

    // TABLE PARAMÈTRES (optionnel)
    await db.execute('''
      CREATE TABLE app_settings(
        id INTEGER PRIMARY KEY,
        key TEXT NOT NULL UNIQUE,
        value TEXT,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    print("✅ Tables créées avec succès !");
  }

  // Pour les futures mises à jour de la base
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print("🔄 Mise à jour de la base de données de v$oldVersion vers v$newVersion");

  }

  Future<void> deleteAllTodos() async {
    final db = await database;
    await db.delete('todos');
  }

  Future<void> deleteAllUsers() async {
    final db = await database;
    await db.delete('users');
  }

  // Fermer la base
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

}