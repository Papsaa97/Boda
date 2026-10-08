import '../../../core/database/app_database.dart';
import '../domain/app_settings.dart';
import '../domain/settings_repository.dart';

/// Nastavení v tabulce `app_settings` (klíč → text).
///
/// Při startu se načtou do paměti ([open]), aby první snímek aplikace měl
/// správný motiv bez čekání na databázi.
class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository._(this._db, this._current);

  static Future<DriftSettingsRepository> open(AppDatabase db) async {
    final values = await db.readAllSettings();
    return DriftSettingsRepository._(db, settingsFromMap(values));
  }

  final AppDatabase _db;
  AppSettings _current;

  @override
  AppSettings load() => _current;

  @override
  Future<void> save(AppSettings settings) async {
    _current = settings;
    await _db.transaction(() async {
      for (final entry in settingsToMap(settings).entries) {
        await _db.writeSetting(entry.key, entry.value);
      }
    });
  }
}

const _theme = 'theme';
const _quietStart = 'quiet_start';
const _quietEnd = 'quiet_end';
const _digest = 'digest';
const _lastExportAt = 'last_export_at';
const _lastZoneId = 'last_zone_id';
const _aiConsentAt = 'ai_consent_at';

AppSettings settingsFromMap(Map<String, String> m) {
  const defaults = AppSettings();
  int? minutes(String key) {
    final v = int.tryParse(m[key] ?? '');
    return v != null && v >= 0 && v < 24 * 60 ? v : null;
  }

  return AppSettings(
    theme: ThemePreference.values.firstWhere(
      (t) => t.name == m[_theme],
      orElse: () => defaults.theme,
    ),
    quietStart: minutes(_quietStart) ?? defaults.quietStart,
    quietEnd: minutes(_quietEnd) ?? defaults.quietEnd,
    digest: DigestMode.fromKey(m[_digest]),
    lastExportAt: DateTime.tryParse(m[_lastExportAt] ?? '')?.toLocal(),
    lastZoneId: m[_lastZoneId],
    aiConsentAt: DateTime.tryParse(m[_aiConsentAt] ?? '')?.toLocal(),
  );
}

/// Null hodnota klíč z tabulky smaže.
Map<String, String?> settingsToMap(AppSettings s) => {
  _theme: s.theme.name,
  _quietStart: '${s.quietStart}',
  _quietEnd: '${s.quietEnd}',
  _digest: s.digest.name,
  _lastExportAt: s.lastExportAt?.toUtc().toIso8601String(),
  _lastZoneId: s.lastZoneId,
  _aiConsentAt: s.aiConsentAt?.toUtc().toIso8601String(),
};
