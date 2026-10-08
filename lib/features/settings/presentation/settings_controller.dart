import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../domain/app_settings.dart';

/// Aktuální nastavení. Změna se hned projeví v UI a uloží na pozadí.
class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(settingsRepositoryProvider).load();

  Future<void> update(AppSettings Function(AppSettings) change) async {
    state = change(state);
    await ref.read(settingsRepositoryProvider).save(state);
  }

  Future<void> setTheme(ThemePreference theme) =>
      update((s) => s.copyWith(theme: theme));

  Future<void> rememberZone(String zoneId) async {
    if (state.lastZoneId == zoneId) return;
    await update((s) => s.copyWith(lastZoneId: zoneId));
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
