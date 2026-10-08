import 'app_settings.dart';

abstract class SettingsRepository {
  /// Nastavení se čtou synchronně, aby aplikace hned věděla, jaký motiv
  /// vykreslit. Implementace je načte předem.
  AppSettings load();
  Future<void> save(AppSettings settings);
}
