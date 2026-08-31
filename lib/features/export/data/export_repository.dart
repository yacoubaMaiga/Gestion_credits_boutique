import 'dart:convert';
import '../../../core/database/database_helper.dart';

class ExportRepository {
  final _db = DatabaseHelper.instance;

  /// Récupère toutes les tables et les sérialise en JSON.
  /// Format simple et lisible, réutilisable pour une future réimportation.
  Future<String> exporterToutesLesDonnees() async {
    final db = await _db.database;

    final produits = await db.query('produit');
    final periodes = await db.query('periode');
    final achats = await db.query('achat');

    final export = {
      'version': 1,
      'date_export': DateTime.now().toIso8601String(),
      'produits': produits,
      'periodes': periodes,
      'achats': achats,
    };

    // indent: '  ' rend le fichier lisible si quelqu'un l'ouvre manuellement
    return const JsonEncoder.withIndent('  ').convert(export);
  }
}