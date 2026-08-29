import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../periodes/presentation/providers/app_providers.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView(
  padding: const EdgeInsets.all(16),
  children: const [
    _ComparaisonMoyenne(),
    SizedBox(height: 24),
    _GraphiqueEvolution(),
    SizedBox(height: 24),
    _TopProduits(),
  ],
),
    );
  }
}

class _ComparaisonMoyenne extends ConsumerWidget {
  const _ComparaisonMoyenne();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodeActiveAsync = ref.watch(periodeActiveProvider);
    final moyenneAsync = ref.watch(moyennePeriodesProvider);

    return periodeActiveAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (periode) {
        if (periode == null) return const SizedBox.shrink();

        final montantActuelAsync = ref.watch(montantTotalProvider(periode.id!));

        return montantActuelAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (montantActuel) => moyenneAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (moyenne) {
              if (moyenne == 0) return const SizedBox.shrink(); // pas assez d'historique
              final ecart = montantActuel - moyenne;
              final pourcentage = ((ecart / moyenne) * 100).round();

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Période en cours', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 8),
                      Text('$montantActuel FCFA', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Text(
                        pourcentage > 0
                            ? '$pourcentage% de plus que ta moyenne habituelle'
                            : '${pourcentage.abs()}% de moins que ta moyenne habituelle',
                        style: TextStyle(
                          color: pourcentage > 0 ? Colors.orange.shade800 : Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _GraphiqueEvolution extends ConsumerWidget {
  const _GraphiqueEvolution();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(montantsParPeriodeProvider);

    return dataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Erreur : $err'),
      data: (donnees) {
        if (donnees.isEmpty) {
          return const Text('Pas encore assez de données pour un graphique');
        }

        final barres = donnees.asMap().entries.map((entry) {
          final index = entry.key;
          final total = (entry.value['total'] as num).toDouble();
          return BarChartGroupData(
            x: index,
            barRods: [BarChartRodData(toY: total, width: 16)],
          );
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Évolution des montants', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: barres,
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TopProduits extends ConsumerWidget {
  const _TopProduits();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final frequentsAsync = ref.watch(produitsFrequentsProvider);
    final couteuxAsync = ref.watch(produitsCouteuxProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Produits les plus pris', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        frequentsAsync.when(
          loading: () => const CircularProgressIndicator(),
          error: (err, _) => Text('Erreur : $err'),
          data: (produits) => Column(
            children: produits
                .map((p) => ListTile(
                      dense: true,
                      title: Text(p['nom_produit'] as String),
                      trailing: Text('${p['nb_achats']} fois'),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 24),
        Text('Plus gros postes de dépense', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        couteuxAsync.when(
          loading: () => const CircularProgressIndicator(),
          error: (err, _) => Text('Erreur : $err'),
          data: (produits) => Column(
            children: produits
                .map((p) => ListTile(
                      dense: true,
                      title: Text(p['nom_produit'] as String),
                      trailing: Text('${p['montant_total']} FCFA'),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}