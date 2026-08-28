import '../../../core/database/database_helper.dart';
import '../models/produit.dart';

class ProduitRepository {
  final _db = DatabaseHelper.instance;

  Future<List<Produit>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('produit', orderBy: 'nom ASC');
    return maps.map((m) => Produit.fromMap(m)).toList();
  }

  Future<int> insert(Produit produit) async {
    final db = await _db.database;
    return await db.insert('produit', produit.toMap()..remove('id'));
  }

  // Cherche un produit par nom, le crée s'il n'existe pas.
  // Utilisé quand l'utilisateur ajoute un produit inconnu directement dans une période.
  Future<Produit> getOrCreateByNom(String nom, int prix) async {
    final db = await _db.database;
    final existing = await db.query(
      'produit',
      where: 'nom = ?',
      whereArgs: [nom],
    );
    if (existing.isNotEmpty) {
      return Produit.fromMap(existing.first);
    }
    final nouveauProduit = Produit(nom: nom, prixDefaut: prix);
    final id = await insert(nouveauProduit);
    return Produit(id: id, nom: nom, prixDefaut: prix);
  }

  Future<void> update(Produit produit) async {
    final db = await _db.database;
    await db.update(
      'produit',
      produit.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [produit.id],
    );
  }
}
