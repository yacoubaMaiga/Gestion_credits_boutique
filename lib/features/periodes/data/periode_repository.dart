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

  /// Montant total = reste hérité de la période précédente + somme des achats
  Future<int> getMontantTotal(int periodeId) async {
    final db = await _db.database;
    final periodeMap = await db.query(
      'periode',
      where: 'id = ?',
      whereArgs: [periodeId],
    );
    final resteReporte =
        (periodeMap.first['reste_reporte'] as num?)?.toInt() ?? 0;

    final result = await db.rawQuery(
      'SELECT SUM(prix * quantite) as total FROM achat WHERE periode_id = ?',
      [periodeId],
    );
    final totalAchats = ((result.first['total'] as num?) ?? 0).round();

    return resteReporte + totalAchats;
  }

  Future<void> marquerPayee(int periodeId, int montantPaye) async {
    final db = await _db.database;
    await db.update(
      'periode',
      {
        'statut': 'payee',
        'date_paiement': DateTime.now().toIso8601String(),
        'montant_paye': montantPaye,
      },
      where: 'id = ?',
      whereArgs: [periodeId],
    );
  }

  /// Cherche la dernière période payée dont le reste n'a pas encore été reporté.
  /// Retourne null s'il n'y a rien à reporter.
  Future<Map<String, dynamic>?> getResteEnAttente() async {
    final db = await _db.database;
    final maps = await db.query(
      'periode',
      where: 'statut = ? AND reste_applique = 0',
      whereArgs: ['payee'],
      orderBy: 'date_paiement DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;

    final periode = maps.first;
    final periodeId = periode['id'] as int;
    final total = await getMontantTotal(periodeId);
    final montantPaye = (periode['montant_paye'] as int?) ?? total;
    final reste = total - montantPaye;

    if (reste <= 0) return null;
    return {'periode_id': periodeId, 'reste': reste};
  }

  Future<void> marquerResteApplique(int periodeId) async {
    final db = await _db.database;
    await db.update(
      'periode',
      {'reste_applique': 1},
      where: 'id = ?',
      whereArgs: [periodeId],
    );
  }

  Future<int> getMontantTotalPourPeriode(int periodeId) =>
      getMontantTotal(periodeId);
}
