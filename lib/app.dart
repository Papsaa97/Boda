import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/activity/presentation/screens/activity_form_screen.dart';
import 'features/activity/presentation/screens/timeline_screen.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/zones/presentation/zones_controller.dart';
import 'features/zones/presentation/zones_screen.dart';

class ZahradnikBodaApp extends StatelessWidget {
  const ZahradnikBodaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zahradník Bóďa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      locale: const Locale('cs'),
      supportedLocales: const [Locale('cs')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const AppRoot(),
    );
  }
}

/// Bez zón ještě uživatel neprošel onboardingem, jinak hlavní obrazovka.
class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zones = ref.watch(zonesControllerProvider);
    return zones.when(
      skipError: true,
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text('Chyba při načítání zón: $error')),
      ),
      data: (list) => list.isEmpty ? const OnboardingScreen() : const HomeShell(),
    );
  }
}

/// Hlavní obrazovka se spodní navigací: Dnes, Deník, Zóny.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          DashboardScreen(),
          TimelineScreen(),
          ZonesScreen(),
        ],
      ),
      floatingActionButton: _index == 2
          ? null
          : FloatingActionButton(
              heroTag: 'add-activity',
              tooltip: 'Nový záznam',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ActivityFormScreen()),
              ),
              child: const Icon(Icons.add),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.wb_sunny_outlined),
            selectedIcon: Icon(Icons.wb_sunny),
            label: 'Dnes',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Deník',
          ),
          NavigationDestination(
            icon: Icon(Icons.grass_outlined),
            selectedIcon: Icon(Icons.grass),
            label: 'Zóny',
          ),
        ],
      ),
    );
  }
}
