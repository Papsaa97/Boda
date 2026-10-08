import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/time/today.dart';
import 'features/activity/presentation/screens/activity_form_screen.dart';
import 'features/activity/presentation/screens/timeline_screen.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/settings/domain/app_settings.dart';
import 'features/settings/presentation/settings_controller.dart';
import 'features/tasks/presentation/reminder_sync.dart';
import 'features/tasks/presentation/screens/task_form_screen.dart';
import 'features/tasks/presentation/screens/tasks_screen.dart';
import 'features/zones/presentation/zones_controller.dart';
import 'features/zones/presentation/zones_screen.dart';
import 'l10n/app_localizations.dart';

class ZahradnikBodaApp extends ConsumerWidget {
  const ZahradnikBodaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(settingsControllerProvider.select((s) => s.theme));
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // Výchozí podle systému: venku na slunci je světlý motiv čitelnější
      // (spec 10.2); v Nastavení jde vynutit.
      themeMode: switch (theme) {
        ThemePreference.system => ThemeMode.system,
        ThemePreference.light => ThemeMode.light,
        ThemePreference.dark => ThemeMode.dark,
      },
      locale: const Locale('cs'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const AppRoot(),
    );
  }
}

/// Bez zón ještě uživatel neprošel onboardingem, jinak hlavní obrazovka.
class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final zones = ref.watch(zonesControllerProvider);
    return zones.when(
      skipError: true,
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) =>
          Scaffold(body: Center(child: Text(l.zonesLoadError('$error')))),
      data: (list) => list.isEmpty
          ? const OnboardingScreen()
          : const ReminderSync(child: HomeShell()),
    );
  }
}

/// Hlavní obrazovka se spodní navigací: Dnes, Deník, Úkoly, Zóny.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell>
    with WidgetsBindingObserver {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Po návratu do aplikace (třeba druhý den ráno) přepočítat „dnes“.
    if (state == AppLifecycleState.resumed) {
      ref.read(todayProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fab = switch (_index) {
      2 => FloatingActionButton(
        heroTag: 'add-task',
        tooltip: l.newTaskTooltip,
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const TaskFormScreen())),
        child: const Icon(Icons.add_task),
      ),
      3 => null,
      _ => FloatingActionButton(
        heroTag: 'add-activity',
        tooltip: l.newActivityTooltip,
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ActivityFormScreen())),
        child: const Icon(Icons.add),
      ),
    };

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          DashboardScreen(),
          TimelineScreen(),
          TasksScreen(),
          ZonesScreen(),
        ],
      ),
      floatingActionButton: fab,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.wb_sunny_outlined),
            selectedIcon: const Icon(Icons.wb_sunny),
            label: l.navToday,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: l.navDiary,
          ),
          NavigationDestination(
            icon: const Icon(Icons.task_alt_outlined),
            selectedIcon: const Icon(Icons.task_alt),
            label: l.navTasks,
          ),
          NavigationDestination(
            icon: const Icon(Icons.grass_outlined),
            selectedIcon: const Icon(Icons.grass),
            label: l.navZones,
          ),
        ],
      ),
    );
  }
}
