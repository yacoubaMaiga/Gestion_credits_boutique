import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'export_repository.dart';

class ExportService {
  final _repository = ExportRepository();

  Future<void> exporterEtPartager() async {
    final jsonData = await _repository.exporterToutesLesDonnees();

    final dossierTemp = await getTemporaryDirectory();
    final dateFichier = DateTime.now().toIso8601String().split('T')[0];
    final fichier = File('${dossierTemp.path}/credits_boutique_$dateFichier.json');

    await fichier.writeAsString(jsonData);

    await Share.shareXFiles(
      [XFile(fichier.path)],
      text: 'Sauvegarde de mes données Crédits Boutique',
    );
  }
}