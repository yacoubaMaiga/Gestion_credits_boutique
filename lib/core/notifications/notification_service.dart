import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);
  }

  Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  /// Programme les rappels quotidiens (7h et 18h) à partir du jour où le seuil est atteint.
  /// Grâce à matchDateTimeComponents, chaque notification se répète ensuite chaque jour
  /// à la même heure, sans avoir à reprogrammer manuellement jour après jour.
  Future<void> programmerRappels({
    required int periodeId,
    required DateTime dateDebut,
    required int seuilJours,
  }) async {
    final dateDeclenchement = dateDebut.add(Duration(days: seuilJours));

    await _programmerUneNotif(
      id: periodeId * 2,
      corps: 'Ça fait $seuilJours jours, pense à aller payer.',
      date: dateDeclenchement,
      heure: 7,
    );
    await _programmerUneNotif(
      id: periodeId * 2 + 1,
      corps: 'Rappel : le paiement chez le boutiquier est en attente.',
      date: dateDeclenchement,
      heure: 18,
    );
  }

  Future<void> _programmerUneNotif({
    required int id,
    required String corps,
    required DateTime date,
    required int heure,
  }) async {
    final premierDeclenchement = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      heure,
    );

    await _plugin.zonedSchedule(
      id,
      'Paiement boutiquier',
      corps,
      premierDeclenchement,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'rappel_paiement',
          'Rappels de paiement',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Annule les rappels d'une période (appelé quand elle est marquée payée)
  Future<void> annulerRappels(int periodeId) async {
    await _plugin.cancel(periodeId * 2);
    await _plugin.cancel(periodeId * 2 + 1);
  }
}
