import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/periode_repository.dart';
import '../../models/periode.dart';
import '../../../produits/data/produit_repository.dart';
import '../../../produits/models/produit.dart';
import '../../../achats/data/achat_repository.dart';
import '../../../achats/models/achat.dart';
import '../../../stats/data/stats_repository.dart';


// Repositories (une seule instance partagée)
final periodeRepositoryProvider = Provider((ref) => PeriodeRepository());
final produitRepositoryProvider = Provider((ref) => ProduitRepository());
final achatRepositoryProvider = Provider((ref) => AchatRepository());

// Période actuellement active (ou null s'il n'y en a pas)
final periodeActiveProvider = FutureProvider<Periode?>((ref) {
  return ref.watch(periodeRepositoryProvider).getActive();
});

// Achats de la période active
final achatsProvider = FutureProvider.family<List<Achat>, int>((ref, periodeId) {
  return ref.watch(achatRepositoryProvider).getByPeriode(periodeId);
});

// Montant total (en FCFA, int)
final montantTotalProvider = FutureProvider.family<int, int>((ref, periodeId) {
  return ref.watch(periodeRepositoryProvider).getMontantTotal(periodeId);
});

// Notifier simple pour rafraîchir la liste après modif
final catalogueRefreshProvider = StateProvider<int>((ref) => 0);

// Catalogue produits (pour l'auto-complétion)
final produitsProvider = FutureProvider<List<Produit>>((ref) {
  ref.watch(catalogueRefreshProvider);
  return ref.watch(produitRepositoryProvider).getAll();
});

final historiqueProvider = FutureProvider<List<Periode>>((ref) {
  return ref.watch(periodeRepositoryProvider).getHistorique();
});

final statsRepositoryProvider = Provider((ref) => StatsRepository());

final montantsParPeriodeProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(statsRepositoryProvider).getMontantsParPeriode();
});

final produitsFrequentsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(statsRepositoryProvider).getProduitsPlusFrequents();
});

final produitsCouteuxProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(statsRepositoryProvider).getProduitsPlusCouteux();
});

final moyennePeriodesProvider = FutureProvider<int>((ref) {
  return ref.watch(statsRepositoryProvider).getMoyennePeriodesPayees();
});