# Crédits Boutique 🛒

Application mobile Android pour suivre mes achats à crédit chez le boutiquier, période après période — sans carnet de notes, sans calcul manuel, avec rappel automatique le jour où il faut payer.

## 📲 Installer l'application sur mon téléphone

1. Va dans l'onglet **[Releases](../../releases)** de ce dépôt (menu à droite de la page GitHub, ou lien direct ci-dessus).
2. Télécharge le fichier `app-release-arm64-v8a.apk` de la dernière version.
3. Ouvre le fichier téléchargé depuis ton gestionnaire de fichiers.
4. Si Android demande d'autoriser l'installation depuis une source inconnue, accepte (uniquement pour ce fichier).
5. Installe et lance l'app.

> ⚠️ Cette app n'est pas publiée sur le Play Store — c'est un projet personnel. L'installation se fait directement via le fichier `.apk` ci-dessus.

## 🎯 Objectif du projet

Avant chaque paiement chez le boutiquier (tous les 1-2 semaines, ou selon l'usage), je notais mes achats à la main sur mon téléphone. Cette app centralise tout :

- Suivi des achats jour par jour, pendant une période donnée
- Rappel de paiement automatique (notification) après un certain nombre de jours
- Calcul automatique du montant total à payer
- Gestion des paiements partiels (le reste se reporte sur la période suivante)
- Historique des périodes déjà payées
- Statistiques et recommandations basées sur mes habitudes de consommation

## ✨ Fonctionnalités

- **Période active** : les achats du jour s'ajoutent en un clic, regroupés par date, avec le total mis à jour en temps réel.
- **Catalogue produit** : les produits utilisés sont mémorisés automatiquement avec leur prix habituel — plus besoin de tout retaper à chaque fois.
- **Notifications** : un rappel après X jours (configurable), répété matin et soir tant que la période n'est pas payée.
- **Paiement partiel** : si je ne paie pas tout d'un coup, le reste est reporté automatiquement (et visiblement) sur la période suivante.
- **Historique** : chaque période payée est archivée avec sa durée réelle et son montant.
- **Statistiques** : évolution des montants dans le temps, produits les plus pris, plus gros postes de dépense.
- **Recommandations** : messages simples basés sur des règles (ex: "tu as dépensé 20% de plus que ta moyenne").
- **Export** : sauvegarde de toutes les données en JSON, partageable vers Drive, mail, etc.

## 🛠️ Stack technique

| Élément | Choix |
|---|---|
| Framework | Flutter (Dart) |
| Base de données locale | SQLite (`sqflite`) — toutes les données restent sur le téléphone, aucun serveur |
| Gestion d'état | Riverpod |
| Notifications | `flutter_local_notifications` |
| Graphiques | `fl_chart` |
| Export | `path_provider` + `share_plus` |
| Architecture | MVVM léger, organisation par feature |

Toutes les données sont stockées **localement sur l'appareil** — pas de compte, pas de cloud, pas de connexion internet requise.

## 📁 Structure du projet

```
lib/
├── core/
│   ├── database/         # Configuration SQLite
│   └── notifications/    # Service de notifications locales
├── features/
│   ├── periodes/         # Période active, création, paiement
│   ├── produits/          # Catalogue produit
│   ├── achats/            # Modèle et accès aux achats
│   ├── historique/        # Liste et détail des périodes payées
│   ├── stats/              # Statistiques et recommandations
│   └── export/             # Export/sauvegarde JSON
```

## 🚀 Développement local

Prérequis : [Flutter SDK](https://flutter.dev/get-started) installé et fonctionnel (`flutter doctor` sans erreur bloquante).

```bash
git clone https://github.com/yacoubaMaiga/Gestion_credits_boutique.git
cd Gestion_credits_boutique
flutter pub get
flutter run
```

### Lancer les tests

```bash
flutter test
```

### Build de production (APK optimisé)

```bash
flutter build apk --release --target-platform android-arm64 --split-per-abi
```

L'APK généré se trouve dans `build/app/outputs/flutter-apk/app-release-arm64-v8a.apk`.

## 📌 Notes

- Projet personnel, solo, développé pour un usage privé.
- Pas de multi-comptes, pas de synchronisation multi-appareils — volontairement simple (principe KISS).
- Toutes les valeurs monétaires sont en **FCFA** (nombres entiers, pas de sous-unité).
