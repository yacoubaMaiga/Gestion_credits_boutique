import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../periodes/presentation/providers/app_providers.dart';
import 'widgets/produit_form_dialog.dart';

class CatalogueScreen extends ConsumerWidget {
  const CatalogueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final produitsAsync = ref.watch(produitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue produits'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: produitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur : $err')),
        data: (produits) {
          if (produits.isEmpty) {
            return const Center(child: Text('Aucun produit enregistré'));
          }
          return ListView.builder(
            itemCount: produits.length,
            itemBuilder: (context, index) {
              final produit = produits[index];
              return ListTile(
                title: Text(produit.nom),
                subtitle: Text('${produit.prixDefaut} FCFA'
                    '${produit.categorie != null ? ' · ${produit.categorie}' : ''}'),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => ProduitFormDialog(produit: produit),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(context: context, builder: (_) => const ProduitFormDialog()),
        child: const Icon(Icons.add),
      ),
    );
  }

}