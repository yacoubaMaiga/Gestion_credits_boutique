class Produit {
  final int? id;
  final String nom;
  final int prixDefaut;
  final String? categorie;

  Produit({
    this.id,
    required this.nom,
    required this.prixDefaut,
    this.categorie,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nom': nom,
    'prix_defaut': prixDefaut,
    'categorie': categorie,
  };

  factory Produit.fromMap(Map<String, dynamic> map) => Produit(
    id: map['id'],
    nom: map['nom'],
    prixDefaut: map['prix_defaut'],
    categorie: map['categorie'],
  );
}
