import '../../../core/database/database_helper.dart';
import '../models/periode.dart';

class PeriodeRepository {
  final _db = DatabaseHelper.instance;

  Future<int> insert(Periode periode) async {
    final db = await _db.database;
    return await db.insert('periode', periode.toMap()..remove('id'));
  }

  Future<Periode?> getActive() async {
    final db = await _db.database;
    final maps = await db.query(
      'periode',
      where: 'statut = ?',
      whereArgs: ['active'],
    );
    if (maps.isEmpty) return null;
    return Periode.fromMap(maps.first);
  }

  Future<List<Periode>> getHistorique() async {
    final db = await _db.database;
    final maps = await db.query(
      'periode',
      where: 'statut = ?',
      whereArgs: ['payee'],
      orderBy: 'date_paiement DESC',
    );
    return maps.map((m) => Periode.fromMap(m)).toList();
  }

  Future<void> marquerPayee(int periodeId) async {
    final db = await _db.database;
    await db.update(
      'periode',
      {'statut': 'payee', 'date_paiement': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [periodeId],
    );
  }

  /// Montant total calculé à la demande (jamais stocké en dur)
  Future<int> getMontantTotal(int periodeId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT SUM(prix * quantite) as total FROM achat WHERE periode_id = ?',
      [periodeId],
    );
    return ((result.first['total'] as num?) ?? 0).round();
  }

  Future<int> getMontantTotalPourPeriode(int periodeId) =>
      getMontantTotal(periodeId);
}
