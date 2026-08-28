import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/produit.dart';
import '../../../periodes/presentation/providers/app_providers.dart';

class ProduitFormDialog extends ConsumerStatefulWidget {
  final Produit? produit; // null = création, non-null = édition

  const ProduitFormDialog({super.key, this.produit});

  @override
  ConsumerState<ProduitFormDialog> createState() => _ProduitFormDialogState();
}

class _ProduitFormDialogState extends ConsumerState<ProduitFormDialog> {
  late final TextEditingController nomController;
  late final TextEditingController prixController;
  late final TextEditingController categorieController;

  bool get estEdition => widget.produit != null;

  @override
  void initState() {
    super.initState();
    nomController = TextEditingController(text: widget.produit?.nom ?? '');
    prixController = TextEditingController(text: widget.produit?.prixDefaut.toString() ?? '');
    categorieController = TextEditingController(text: widget.produit?.categorie ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(estEdition ? 'Modifier le produit' : 'Nouveau produit'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nomController,
            decoration: const InputDecoration(labelText: 'Nom'),
            onChanged: (_) => setState(() {}),
          ),
          TextField(
            controller: prixController,
            decoration: const InputDecoration(labelText: 'Prix par défaut (FCFA)'),
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
          TextField(
            controller: categorieController,
            decoration: const InputDecoration(labelText: 'Catégorie (optionnel)'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton(
          onPressed: _peutValider() ? () => _enregistrer(context) : null,
          child: Text(estEdition ? 'Enregistrer' : 'Ajouter'),
        ),
      ],
    );
  }

  bool _peutValider() {
    return nomController.text.trim().isNotEmpty && int.tryParse(prixController.text) != null;
  }

  Future<void> _enregistrer(BuildContext context) async {
    final produit = Produit(
      id: widget.produit?.id,
      nom: nomController.text.trim(),
      prixDefaut: int.parse(prixController.text),
      categorie: categorieController.text.trim().isEmpty ? null : categorieController.text.trim(),
    );

    final repo = ref.read(produitRepositoryProvider);
    if (estEdition) {
      await repo.update(produit);
    } else {
      await repo.insert(produit);
    }

    ref.read(catalogueRefreshProvider.notifier).state++;
    if (context.mounted) Navigator.pop(context);
  }
}