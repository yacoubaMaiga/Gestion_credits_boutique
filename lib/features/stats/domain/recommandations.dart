/// Logique pure, sans dépendance Flutter — facilement testable.
class Recommandations {
  static List<String> generer({
    required int montantActuel,
    required int moyennePeriodes,
    required List<Map<String, dynamic>> produitsCouteux,
    required int totalDepenseGenerale,
  }) {
    final messages = <String>[];

    messages.addAll(_comparerMoyenne(montantActuel, moyennePeriodes));
    messages.addAll(_produitDominant(produitsCouteux, totalDepenseGenerale));

    return messages;
  }

  static List<String> _comparerMoyenne(int montantActuel, int moyenne) {
    if (moyenne <= 0) return [];

    final ecartPourcentage = ((montantActuel - moyenne) / moyenne) * 100;

    if (ecartPourcentage >= 15) {
      return ['Tu as dépensé ${ecartPourcentage.round()}% de plus que ta moyenne habituelle sur cette période.'];
    }
    if (ecartPourcentage <= -15) {
      return ['Bien joué, tu as dépensé ${ecartPourcentage.abs().round()}% de moins que ta moyenne habituelle.'];
    }
    return [];
  }

  static List<String> _produitDominant(List<Map<String, dynamic>> produitsCouteux, int totalGeneral) {
    if (produitsCouteux.isEmpty || totalGeneral <= 0) return [];

    final top = produitsCouteux.first;
    final montantTop = (top['montant_total'] as num).toInt();
    final part = (montantTop / totalGeneral) * 100;

    if (part >= 30) {
      return ['"${top['nom_produit']}" représente ${part.round()}% de tes dépenses totales.'];
    }
    return [];
  }
}