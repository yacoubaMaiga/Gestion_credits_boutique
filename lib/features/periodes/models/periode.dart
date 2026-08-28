enum StatutPeriode { active, payee }

class Periode {
  final int? id;
  final DateTime dateDebut;
  final int seuilAlerteJours;
  final StatutPeriode statut;
  final DateTime? datePaiement;
  final String? note;

  Periode({
    this.id,
    required this.dateDebut,
    this.seuilAlerteJours = 10,
    this.statut = StatutPeriode.active,
    this.datePaiement,
    this.note,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date_debut': dateDebut.toIso8601String(),
        'seuil_alerte_jours': seuilAlerteJours,
        'statut': statut.name,
        'date_paiement': datePaiement?.toIso8601String(),
        'note': note,
      };

  factory Periode.fromMap(Map<String, dynamic> map) => Periode(
        id: map['id'],
        dateDebut: DateTime.parse(map['date_debut']),
        seuilAlerteJours: map['seuil_alerte_jours'],
        statut: StatutPeriode.values.byName(map['statut']),
        datePaiement:
            map['date_paiement'] != null ? DateTime.parse(map['date_paiement']) : null,
        note: map['note'],
      );
}