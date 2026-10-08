import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:zahradnik_boda/core/di/providers.dart';
import 'package:zahradnik_boda/core/notifications/notification_scheduler.dart';
import 'package:zahradnik_boda/features/activity/domain/activity_type.dart';
import 'package:zahradnik_boda/features/settings/domain/app_settings.dart';
import 'package:zahradnik_boda/features/tasks/domain/task_entity.dart';

import '../helpers/fakes.dart';

void main() {
  setUpAll(() => initializeDateFormatting('cs'));

  testWidgets('quick entry: + → type → save is three taps (FR-D6)', (
    tester,
  ) async {
    final repo = InMemoryActivityRepository();
    final settings = InMemorySettingsRepository(
      const AppSettings(lastZoneId: 'Z3'),
    );
    await pumpApp(tester, testOverrides(activities: repo, settings: settings));

    await tester.tap(find.byTooltip('Nový záznam'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Zálivka'));
    await tester.pump();
    await tester.tap(find.widgetWithText(TextButton, 'Uložit'));
    await tester.pumpAndSettle();

    final saved = repo.items.values.single;
    expect(saved.title, 'Zálivka');
    expect(saved.type, ActivityType.watering);
    // Předvyplněná poslední zóna.
    expect(saved.zoneId, 'Z3');
    expect(settings.current.lastZoneId, 'Z3');
  });

  testWidgets('task: create, get reminded, complete and log to diary', (
    tester,
  ) async {
    final tasks = InMemoryTaskRepository();
    final activities = InMemoryActivityRepository();
    final scheduler = NoopNotificationScheduler();
    await pumpApp(tester, [
      ...testOverrides(tasks: tasks, activities: activities),
      notificationSchedulerProvider.overrideWithValue(scheduler),
    ]);

    await tester.tap(find.text('Úkoly'));
    await tester.pumpAndSettle();
    expect(find.text('Zatím žádné úkoly'), findsOneWidget);

    await tester.tap(find.byTooltip('Nový úkol'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Co je potřeba udělat'),
      'Zalít skleník',
    );
    await tester.tap(find.widgetWithText(TextButton, 'Uložit'));
    await tester.pumpAndSettle();

    final task = tasks.items.values.single;
    expect(task.title, 'Zalít skleník');
    expect(task.due, DateTime(2026, 10, 7));
    expect(find.text('Zalít skleník'), findsWidgets);
    // Nesplněný úkol připomene ranní přehled zítra po tichých hodinách.
    expect(scheduler.scheduled.first.at, DateTime(2026, 10, 8, 8));

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    expect(tasks.items[task.id]!.status, TaskStatus.done);
    expect(find.text('Hotovo: Zalít skleník'), findsOneWidget);

    await tester.tap(find.text('Zapsat do deníku'));
    await tester.pumpAndSettle();
    expect(find.text('Nový záznam'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Uložit'));
    await tester.pumpAndSettle();

    final logged = activities.items.values.single;
    expect(logged.title, 'Zalít skleník');
    expect(logged.type, ActivityType.watering);
    expect(tasks.items[task.id]!.completedActivityId, logged.id);
  });

  testWidgets('open task with a reminder is scheduled outside quiet hours', (
    tester,
  ) async {
    final scheduler = NoopNotificationScheduler();
    await pumpApp(tester, [
      ...testOverrides(
        tasks: InMemoryTaskRepository([
          TaskEntity(
            id: 't',
            title: 'Postřik',
            due: DateTime(2026, 10, 8),
            remindAt: 22 * 60,
          ),
        ]),
      ),
      notificationSchedulerProvider.overrideWithValue(scheduler),
    ]);

    final reminder = scheduler.scheduled.firstWhere(
      (m) => m.title == 'Postřik',
    );
    // 22:00 je v tichých hodinách (21–8), přijde v 8:00.
    expect(reminder.at, DateTime(2026, 10, 9, 8));
    expect(
      scheduler.scheduled.map((m) => m.title),
      contains('Dnes tě čeká 1 úkol'),
    );
  });

  testWidgets('settings switch the theme and show backup', (tester) async {
    final settings = InMemorySettingsRepository();
    await pumpApp(tester, testOverrides(settings: settings));

    await tester.tap(find.byTooltip('Nastavení'));
    await tester.pumpAndSettle();
    expect(find.text('21:00'), findsOneWidget);

    await tester.tap(find.text('Tmavý'));
    await tester.pumpAndSettle();
    expect(settings.current.theme, ThemePreference.dark);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);

    await tester.scrollUntilVisible(find.text('Obnovit ze zálohy'), 200);
    expect(find.text('Exportovat zálohu'), findsOneWidget);
  });

  testWidgets('dashboard shows today\'s tasks and the backup reminder', (
    tester,
  ) async {
    await pumpApp(
      tester,
      testOverrides(
        activities: InMemoryActivityRepository([
          activity('a', date: DateTime(2026, 10, 1, 9)),
        ]),
        tasks: InMemoryTaskRepository([
          TaskEntity(
            id: 't',
            title: 'Sklidit dýně',
            due: DateTime(2026, 10, 7),
          ),
        ]),
      ),
    );

    expect(find.text('Dnes je na řadě 1 úkol'), findsOneWidget);
    expect(find.text('Sklidit dýně'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Zálohuj si deník'), 200);
    expect(find.text('Zálohuj si deník'), findsOneWidget);
  });
}
