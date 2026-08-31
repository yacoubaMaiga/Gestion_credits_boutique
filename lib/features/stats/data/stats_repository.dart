import '../../../core/database/database_helper.dart';

class StatsRepository {
  final _db = DatabaseHelper.instance;

  /// Montant total par période payée, trié par date de paiement croissante
  /// (utile pour tracer l'évolution dans le temps)
  Future<List<Map<String, dynamic>>> getMontantsParPeriode() async {
    final db = await _db.database;
    return await db.rawQuery('''
      SELECT p.id, p.date_paiement, SUM(a.prix * a.quantite) as total
      FROM periode p
      JOIN achat a ON a.periode_id = p.id
      WHERE p.statut = 'payee'
      GROUP BY p.id
      ORDER BY p.date_paiement ASC
    ''');
  }

  /// Produits les plus achetés, toutes périodes confondues (par fréquence d'achat)
  Future<List<Map<String, dynamic>>> getProduitsPlusFrequents({
    int limite = 5,
  }) async {
    final db = await _db.database;
    return await db.rawQuery(
      '''
      SELECT nom_produit, COUNT(*) as nb_achats, SUM(quantite) as quantite_totale
      FROM achat
      GROUP BY nom_produit
      ORDER BY nb_achats DESC
      LIMIT ?
    ''',
      [limite],
    );
  }

  /// Produits qui représentent le plus gros poste de dépense (montant cumulé)
  Future<List<Map<String, dynamic>>> getProduitsPlusCouteux({
    int limite = 5,
  }) async {
    final db = await _db.database;
    return await db.rawQuery(
      '''
      SELECT nom_produit, SUM(prix * quantite) as montant_total
      FROM achat
      GROUP BY nom_produit
      ORDER BY montant_total DESC
      LIMIT ?
    ''',
      [limite],
    );
  }

  /// Moyenne des montants totaux des périodes déjà payées (pour comparaison)
  Future<int> getMoyennePeriodesPayees() async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT AVG(total) as moyenne FROM (
        SELECT SUM(a.prix * a.quantite) as total
        FROM periode p
        JOIN achat a ON a.periode_id = p.id
        WHERE p.statut = 'payee'
        GROUP BY p.id
      )
    ''');
    return ((result.first['moyenne'] as num?) ?? 0).round();
  }

  /// Somme de toutes les dépenses enregistrées, toutes périodes confondues
  /// (utilisé pour calculer le poids relatif d'un produit dans les dépenses totales)
  Future<int> getTotalDepenseGenerale() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT SUM(prix * quantite) as total FROM achat',
    );
    return ((result.first['total'] as num?) ?? 0).round();
  }
}
