import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../periodes/models/periode.dart';
import '../../periodes/presentation/providers/app_providers.dart';
import 'periode_detail_screen.dart';

class HistoriqueScreen extends ConsumerWidget {
  const HistoriqueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historiqueAsync = ref.watch(historiqueProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: historiqueAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur : $err')),
        data: (periodes) {
          if (periodes.isEmpty) {
            return const Center(child: Text('Aucune période payée pour l\'instant'));
          }
          return ListView.builder(
            itemCount: periodes.length,
            itemBuilder: (context, index) => _PeriodeCard(periode: periodes[index]),
          );
        },
      ),
    );
  }
}

class _PeriodeCard extends ConsumerWidget {
  final Periode periode;
  const _PeriodeCard({required this.periode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final montantAsync = ref.watch(montantTotalProvider(periode.id!));
    final duree = periode.datePaiement!.difference(periode.dateDebut).inDays + 1;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text('${_formatDate(periode.dateDebut)} → ${_formatDate(periode.datePaiement!)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$duree jours'),
            const SizedBox(height: 2),
            Text(
              'Payé le ${_formatDate(periode.datePaiement!)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: montantAsync.when(
          loading: () => const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          error: (_, _) => const Text('—'),
          data: (montant) => Text('$montant FCFA', style: Theme.of(context).textTheme.titleMedium),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PeriodeDetailScreen(periode: periode)),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
