import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../periodes/models/periode.dart';
import '../../periodes/presentation/providers/app_providers.dart';

class PeriodeDetailScreen extends ConsumerWidget {
  final Periode periode;
  const PeriodeDetailScreen({super.key, required this.periode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achatsAsync = ref.watch(achatsProvider(periode.id!));
    final montantAsync = ref.watch(montantTotalProvider(periode.id!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail période'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: montantAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (_, _) => const Text('—'),
              data: (montant) => Text(
                '$montant FCFA',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: achatsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Erreur : $err')),
              data: (achats) => ListView.builder(
                itemCount: achats.length,
                itemBuilder: (context, index) {
                  final achat = achats[index];
                  return ListTile(
                    title: Text(achat.nomProduit),
                    subtitle: Text('${_formatQuantite(achat.quantite)} x ${achat.prix} FCFA'),
                    trailing: Text('${achat.total} FCFA'),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatQuantite(double q) => q == q.roundToDouble() ? q.toInt().toString() : q.toString();
}