import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/notifications/notification_service.dart';
import 'features/periodes/presentation/periode_active_screen.dart';
import 'features/produits/presentation/catalogue_screen.dart';
import 'features/historique/presentation/historique_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crédits Boutique',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const AccueilNavigation(),
    );
  }
}

class AccueilNavigation extends StatefulWidget {
  const AccueilNavigation({super.key});

  @override
  State<AccueilNavigation> createState() => _AccueilNavigationState();
}

class _AccueilNavigationState extends State<AccueilNavigation> {
  int indexActif = 0;

  final ecrans = const [
    PeriodeActiveScreen(),
    CatalogueScreen(),
    HistoriqueScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ecrans[indexActif],
      bottomNavigationBar: NavigationBar(
        selectedIndex: indexActif,
        onDestinationSelected: (index) => setState(() => indexActif = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Période'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Catalogue'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Historique'),
        ],
      ),
    );
  }
}