import '../../../core/database/database_helper.dart';
import '../models/achat.dart';

class AchatRepository {
  final _db = DatabaseHelper.instance;

  Future<int> insert(Achat achat) async {
    final db = await _db.database;
    return await db.insert('achat', achat.toMap()..remove('id'));
  }

  Future<List<Achat>> getByPeriode(int periodeId) async {
    final db = await _db.database;
    final maps = await db.query(
      'achat',
      where: 'periode_id = ?',
      whereArgs: [periodeId],
      orderBy: 'date DESC',
    );
    return maps.map((m) => Achat.fromMap(m)).toList();
  }

  Future<void> delete(int achatId) async {
    final db = await _db.database;
    await db.delete('achat', where: 'id = ?', whereArgs: [achatId]);
  }
}