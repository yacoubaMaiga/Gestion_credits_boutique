import 'package:flutter_test/flutter_test.dart';
import 'package:credits_boutique/features/stats/domain/recommandations.dart';

void main() {
  group('Recommandations - comparaison moyenne', () {
    test('recommande une alerte si dépense actuelle 15%+ au-dessus de la moyenne', () {
      final messages = Recommandations.generer(
        montantActuel: 1200,
        moyennePeriodes: 1000,
        produitsCouteux: [],
        totalDepenseGenerale: 0,
      );
      expect(messages, isNotEmpty);
      expect(messages.first, contains('plus'));
    });

    test('ne recommande rien si l\'écart est faible', () {
      final messages = Recommandations.generer(
        montantActuel: 1050,
        moyennePeriodes: 1000,
        produitsCouteux: [],
        totalDepenseGenerale: 0,
      );
      expect(messages, isEmpty);
    });
  });

  group('Recommandations - produit dominant', () {
    test('signale un produit qui represente 30%+ des depenses', () {
      final messages = Recommandations.generer(
        montantActuel: 0,
        moyennePeriodes: 0,
        produitsCouteux: [{'nom_produit': 'Pain', 'montant_total': 4000}],
        totalDepenseGenerale: 10000,
      );
      expect(messages, isNotEmpty);
      expect(messages.first, contains('Pain'));
    });

    test('ignore un produit qui represente moins de 30%', () {
      final messages = Recommandations.generer(
        montantActuel: 0,
        moyennePeriodes: 0,
        produitsCouteux: [{'nom_produit': 'Pain', 'montant_total': 1000}],
        totalDepenseGenerale: 10000,
      );
      expect(messages, isEmpty);
    });
  });
}