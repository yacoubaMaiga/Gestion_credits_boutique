import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'credits_boutique.db');
    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE produit (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        prix_defaut INTEGER NOT NULL CHECK (prix_defaut >= 0),
        categorie TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE periode (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date_debut TEXT NOT NULL,
        seuil_alerte_jours INTEGER NOT NULL DEFAULT 10,
        statut TEXT NOT NULL DEFAULT 'active',
        date_paiement TEXT,
        note TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE achat (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        periode_id INTEGER NOT NULL,
        produit_id INTEGER NOT NULL,
        nom_produit TEXT NOT NULL,
        prix INTEGER NOT NULL CHECK (prix >= 0),
        quantite REAL NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (periode_id) REFERENCES periode (id) ON DELETE CASCADE,
        FOREIGN KEY (produit_id) REFERENCES produit (id)
      )
    ''');
  }
}
