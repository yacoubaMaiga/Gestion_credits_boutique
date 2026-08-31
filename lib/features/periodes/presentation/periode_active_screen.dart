import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../achats/models/achat.dart';
import '../../../core/notifications/notification_service.dart';
import '../models/periode.dart';
import 'providers/app_providers.dart';
import 'widgets/creer_periode_dialog.dart';
import 'widgets/ajouter_achat_dialog.dart';

class PeriodeActiveScreen extends ConsumerWidget {
  const PeriodeActiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodeAsync = ref.watch(periodeActiveProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Période active'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          periodeAsync.maybeWhen(
            data: (periode) => periode == null
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    tooltip: 'Marquer comme payée',
                    onPressed: () =>
                        _confirmerPaiement(context, ref, periode.id!),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: periodeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur : $err')),
        data: (periode) {
          if (periode == null) return _AucunePeriode(ref: ref);
          return _PeriodeContenu(periode: periode);
        },
      ),
      floatingActionButton: periodeAsync.maybeWhen(
        data: (periode) => periode == null
            ? null
            : FloatingActionButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => AjouterAchatDialog(periodeId: periode.id!),
                ),
                child: const Icon(Icons.add),
              ),
        orElse: () => null,
      ),
    );
  }

  Future<void> _confirmerPaiement(
    BuildContext context,
    WidgetRef ref,
    int periodeId,
  ) async {
    final montantTotal = await ref.read(montantTotalProvider(periodeId).future);
    final montantController = TextEditingController(
      text: montantTotal.toString(),
    );

    final montantPaye = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Marquer comme payée'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Montant total dû : $montantTotal FCFA'),
            const SizedBox(height: 12),
            TextField(
              controller: montantController,
              decoration: const InputDecoration(
                labelText: 'Montant réellement payé (FCFA)',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              int.tryParse(montantController.text),
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (montantPaye == null) return;

    await ref
        .read(periodeRepositoryProvider)
        .marquerPayee(periodeId, montantPaye);
    await NotificationService.instance.annulerRappels(periodeId);
    ref.invalidate(periodeActiveProvider);
    ref.invalidate(historiqueProvider);

    if (montantPaye < montantTotal && context.mounted) {
      final reste = montantTotal - montantPaye;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reste de $reste FCFA — sera ajouté à la prochaine période',
          ),
        ),
      );
    }
  }
}

class _AucunePeriode extends StatelessWidget {
  final WidgetRef ref;
  const _AucunePeriode({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Aucune période active'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const CreerPeriodeDialog(),
            ),
            child: const Text('Créer une période'),
          ),
        ],
      ),
    );
  }
}

class _PeriodeContenu extends ConsumerWidget {
  final Periode periode;
  const _PeriodeContenu({required this.periode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodeId = periode.id!;
    final montantAsync = ref.watch(montantTotalProvider(periodeId));
    final achatsAsync = ref.watch(achatsProvider(periodeId));
    final joursEcoules =
        DateTime.now().difference(periode.dateDebut).inDays + 1;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatBlock(label: 'Jour', valeur: '$joursEcoules'),
                  montantAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (_, _) => const Text('—'),
                    data: (montant) =>
                        _StatBlock(label: 'Total', valeur: '$montant FCFA'),
                  ),
                ],
              ),
              if (periode.resteReporte > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'dont ${periode.resteReporte} FCFA reporté(s) de la période précédente',
                  style: TextStyle(color: Colors.orange.shade800, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: achatsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Erreur : $err')),
            data: (achats) {
              if (achats.isEmpty) {
                return const Center(child: Text('Aucun achat pour l\'instant'));
              }
              return _ListeGroupeeParDate(achats: achats);
            },
          ),
        ),
      ],
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final String valeur;
  const _StatBlock({required this.label, required this.valeur});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(valeur, style: Theme.of(context).textTheme.headlineMedium),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

class _ListeGroupeeParDate extends StatelessWidget {
  final List<Achat> achats;
  const _ListeGroupeeParDate({required this.achats});

  @override
  Widget build(BuildContext context) {
    final groupes = _grouperParDate(achats);
    final dates = groupes.keys.toList()..sort((a, b) => b.compareTo(a));
    final aujourdHui = _dateKey(DateTime.now());

    return ListView.builder(
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final cle = dates[index];
        final achatsDuJour = groupes[cle]!;
        final sousTotal = achatsDuJour.fold<int>(
          0,
          (somme, a) => somme + a.total,
        );
        final estAujourdHui = cle == aujourdHui;

        return ExpansionTile(
          initiallyExpanded:
              estAujourdHui, // aujourd'hui = déroulé, le reste = replié
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(cle),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(
                '$sousTotal FCFA',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
          children: achatsDuJour
              .map(
                (achat) => ListTile(
                  title: Text(achat.nomProduit),
                  subtitle: Text(
                    '${_formatQuantite(achat.quantite)} x ${achat.prix} FCFA',
                  ),
                  trailing: Text('${achat.total} FCFA'),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Map<String, List<Achat>> _grouperParDate(List<Achat> achats) {
    final Map<String, List<Achat>> groupes = {};
    for (final achat in achats) {
      final cle = _dateKey(achat.date);
      groupes.putIfAbsent(cle, () => []).add(achat);
    }
    return groupes;
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _formatDate(String cle) {
    final p = cle.split('-').map(int.parse).toList();
    final date = DateTime(p[0], p[1], p[2]);
    const jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return '${jours[date.weekday - 1]} ${date.day}/${date.month}';
  }

  String _formatQuantite(double q) =>
      q == q.roundToDouble() ? q.toInt().toString() : q.toString();
}
