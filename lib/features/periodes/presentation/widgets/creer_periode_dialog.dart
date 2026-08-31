import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../models/periode.dart';
import '../providers/app_providers.dart';

class CreerPeriodeDialog extends ConsumerStatefulWidget {
  const CreerPeriodeDialog({super.key});

  @override
  ConsumerState<CreerPeriodeDialog> createState() => _CreerPeriodeDialogState();
}

class _CreerPeriodeDialogState extends ConsumerState<CreerPeriodeDialog> {
  final seuilController = TextEditingController(text: '10');
  Map<String, dynamic>? resteEnAttente;

  @override
  void initState() {
    super.initState();
    _chargerReste();
  }

  Future<void> _chargerReste() async {
    final reste = await ref.read(periodeRepositoryProvider).getResteEnAttente();
    if (mounted) setState(() => resteEnAttente = reste);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvelle période'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (resteEnAttente != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Text(
                'Report de la période précédente : ${resteEnAttente!['reste']} FCFA',
                style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.w600),
              ),
            ),
          TextField(
            controller: seuilController,
            decoration: const InputDecoration(
              labelText: 'Rappel après combien de jours ?',
              helperText: 'Tu peux payer avant ou après, c\'est juste le rappel',
              helperMaxLines: 2,
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton(onPressed: () => _creerPeriode(context), child: const Text('Créer')),
      ],
    );
  }

  Future<void> _creerPeriode(BuildContext context) async {
    final seuil = int.tryParse(seuilController.text) ?? 10;
    final dateDebut = DateTime.now();

    final periode = Periode(
      dateDebut: dateDebut,
      seuilAlerteJours: seuil,
      resteReporte: resteEnAttente != null ? resteEnAttente!['reste'] as int : 0,
    );
    final id = await ref.read(periodeRepositoryProvider).insert(periode);

    // Marque le reste comme reporté pour ne jamais le réappliquer ailleurs
    if (resteEnAttente != null) {
      await ref
          .read(periodeRepositoryProvider)
          .marquerResteApplique(resteEnAttente!['periode_id'] as int);
    }

    await NotificationService.instance.requestPermission();
    await NotificationService.instance.programmerRappels(
      periodeId: id,
      dateDebut: dateDebut,
      seuilJours: seuil,
    );

    ref.invalidate(periodeActiveProvider);
    if (context.mounted) Navigator.pop(context);
  }
}