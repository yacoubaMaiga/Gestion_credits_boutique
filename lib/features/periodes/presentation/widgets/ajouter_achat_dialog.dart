import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../achats/models/achat.dart';
import '../providers/app_providers.dart';

class AjouterAchatDialog extends ConsumerStatefulWidget {
  final int periodeId;
  const AjouterAchatDialog({super.key, required this.periodeId});

  @override
  ConsumerState<AjouterAchatDialog> createState() => _AjouterAchatDialogState();
}

class _AjouterAchatDialogState extends ConsumerState<AjouterAchatDialog> {
  final nomController = TextEditingController();
  final prixController = TextEditingController();
  final quantiteController = TextEditingController(text: '1');

  @override
  Widget build(BuildContext context) {
    final produitsAsync = ref.watch(produitsProvider);

    return AlertDialog(
      title: const Text('Ajouter un achat'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Auto-complétion depuis le catalogue existant
          produitsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (produits) => Autocomplete<String>(
              optionsBuilder: (text) {
                if (text.text.isEmpty) return const Iterable.empty();
                return produits
                    .map((p) => p.nom)
                    .where(
                      (nom) =>
                          nom.toLowerCase().contains(text.text.toLowerCase()),
                    );
              },
              onSelected: (nom) {
                nomController.text = nom;
                final produit = produits.firstWhere((p) => p.nom == nom);
                prixController.text = produit.prixDefaut.toString();
              },
              fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                // Synchronise le champ auto-complétion avec notre controller
                controller.text = nomController.text;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(labelText: 'Produit'),
                  onChanged: (value) {
                    nomController.text = value;
                    setState(() {});
                  },
                );
              },
            ),
          ),
          TextField(
            controller: prixController,
            decoration: const InputDecoration(labelText: 'Prix (FCFA)'),
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
          TextField(
            controller: quantiteController,
            decoration: const InputDecoration(labelText: 'Quantité'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _peutValider() ? () => _ajouterAchat(context) : null,
          child: const Text('Ajouter'),
        ),
      ],
    );
  }

  bool _peutValider() {
    return nomController.text.isNotEmpty &&
        int.tryParse(prixController.text) != null &&
        double.tryParse(quantiteController.text) != null;
  }

  Future<void> _ajouterAchat(BuildContext context) async {
    final nom = nomController.text.trim();
    final prix = int.parse(prixController.text);
    final quantite = double.parse(quantiteController.text);

    // Règle métier : si le produit n'existe pas dans le catalogue, il est créé automatiquement
    final produit = await ref
        .read(produitRepositoryProvider)
        .getOrCreateByNom(nom, prix);

    final achat = Achat(
      periodeId: widget.periodeId,
      produitId: produit.id!,
      nomProduit: nom,
      prix: prix,
      quantite: quantite,
      date: DateTime.now(),
    );
    await ref.read(achatRepositoryProvider).insert(achat);

    ref.invalidate(achatsProvider(widget.periodeId));
    ref.invalidate(montantTotalProvider(widget.periodeId));
    if (context.mounted) Navigator.pop(context);
  }
}
