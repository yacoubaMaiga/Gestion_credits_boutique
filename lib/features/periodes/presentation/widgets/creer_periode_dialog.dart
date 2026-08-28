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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvelle période'),
      content: TextField(
        controller: seuilController,
        decoration: const InputDecoration(
          labelText: 'Rappel après combien de jours ?',
          helperText: 'Tu peux payer avant ou après, c\'est juste le rappel',
          helperMaxLines: 2,
        ),
        keyboardType: TextInputType.number,
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

    final periode = Periode(dateDebut: dateDebut, seuilAlerteJours: seuil);
    final id = await ref.read(periodeRepositoryProvider).insert(periode);

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