import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Hotová notifikace k naplánování: okamžik a texty.
class ScheduledMessage {
  const ScheduledMessage({
    required this.at,
    required this.title,
    required this.body,
  });

  final DateTime at;
  final String title;
  final String body;
}

/// Plánování lokálních notifikací. Rozhraní odstiňuje platformní plugin,
/// aby šly testovat obrazovky i plánovač bez zařízení.
abstract class NotificationScheduler {
  /// Požádá o oprávnění k notifikacím (Android 13+, iOS). Vrací, zda je
  /// uděleno.
  Future<bool> requestPermission();

  /// Zruší dříve naplánované notifikace a naplánuje [messages].
  /// [channel] je název kanálu v nastavení systému (Android).
  Future<void> replaceAll(
    List<ScheduledMessage> messages, {
    required String channel,
  });
}

/// Nic neplánuje (web, testy).
class NoopNotificationScheduler implements NotificationScheduler {
  final List<ScheduledMessage> scheduled = [];

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> replaceAll(
    List<ScheduledMessage> messages, {
    required String channel,
  }) async {
    scheduled
      ..clear()
      ..addAll(messages);
  }
}

/// Lokální notifikace přes `flutter_local_notifications`.
///
/// Časy se předávají jako absolutní okamžiky v UTC, takže není potřeba
/// znát název časové zóny zařízení; letní čas vyřeší výpočet v místním
/// čase v [ReminderPlanner]. Na Androidu se plánuje nepřesně
/// (`inexactAllowWhileIdle`), přesné alarmy by vyžadovaly zvláštní
/// oprávnění (DECLOG D27).
class LocalNotificationScheduler implements NotificationScheduler {
  LocalNotificationScheduler._(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static Future<NotificationScheduler> create() async {
    if (kIsWeb) return NoopNotificationScheduler();
    try {
      tzdata.initializeTimeZones();
      final plugin = FlutterLocalNotificationsPlugin();
      await plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      return LocalNotificationScheduler._(plugin);
    } catch (e) {
      debugPrint('Notifikace nejdou inicializovat: $e');
      return NoopNotificationScheduler();
    }
  }

  @override
  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, sound: true) ?? false;
    }
    return false;
  }

  @override
  Future<void> replaceAll(
    List<ScheduledMessage> messages, {
    required String channel,
  }) async {
    await _plugin.cancelAll();
    var id = 1;
    for (final m in messages) {
      await _plugin.zonedSchedule(
        id: id++,
        title: m.title,
        body: m.body,
        scheduledDate: tz.TZDateTime.from(m.at.toUtc(), tz.UTC),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders',
            channel,
            styleInformation: BigTextStyleInformation(m.body),
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}
