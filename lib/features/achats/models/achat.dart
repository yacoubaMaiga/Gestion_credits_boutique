class Achat {
  final int? id;
  final int periodeId;
  final int produitId;
  final String nomProduit;
  final int prix;
  final double quantite;
  final DateTime date;

  Achat({
    this.id,
    required this.periodeId,
    required this.produitId,
    required this.nomProduit,
    required this.prix,
    required this.quantite,
    required this.date,
  });

  int get total => (prix * quantite).round();

  Map<String, dynamic> toMap() => {
        'id': id,
        'periode_id': periodeId,
        'produit_id': produitId,
        'nom_produit': nomProduit,
        'prix': prix,
        'quantite': quantite,
        'date': date.toIso8601String(),
      };

  factory Achat.fromMap(Map<String, dynamic> map) => Achat(
        id: map['id'],
        periodeId: map['periode_id'],
        produitId: map['produit_id'],
        nomProduit: map['nom_produit'],
        prix: map['prix'],
        quantite: (map['quantite'] as num).toDouble(),
        date: DateTime.parse(map['date']),
      );
}