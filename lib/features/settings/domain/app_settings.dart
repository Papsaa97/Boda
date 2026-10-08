import 'package:equatable/equatable.dart';

/// Motiv aplikace. Výchozí je podle systému (DECLOG D18).
enum ThemePreference { system, light, dark }

/// Jak často posílat ranní přehled úkolů (FR-U6).
enum DigestMode {
  /// Denně, v zimě (listopad–únor) jednou týdně.
  auto,
  daily,
  weekly,
  off;

  static DigestMode fromKey(String? key) =>
      values.firstWhere((m) => m.name == key, orElse: () => auto);
}

/// Čas dne v minutách od půlnoci (0–1439).
typedef MinuteOfDay = int;

/// Nastavení aplikace uložená v zařízení.
class AppSettings extends Equatable {
  final ThemePreference theme;

  /// Začátek a konec tichých hodin (FR-U5), výchozí 21:00–08:00.
  final MinuteOfDay quietStart;
  final MinuteOfDay quietEnd;

  final DigestMode digest;

  /// Kdy uživatel naposledy exportoval zálohu (FR-E3).
  final DateTime? lastExportAt;

  /// Poslední použitá zóna, předvyplní se v novém záznamu (FR-D6).
  final String? lastZoneId;

  /// Kdy uživatel souhlasil se zpracováním dotazů na Bóďu jazykovým
  /// modelem (kap. 9); null = nesouhlasil nebo souhlas odvolal.
  final DateTime? aiConsentAt;

  /// Kdy uživatel souhlasil s anonymní analytikou (kap. 9); null = ne.
  final DateTime? analyticsConsentAt;

  /// Kdy uživatel souhlasil s odesíláním fotek k diagnostice (FR-V1,
  /// `consents.photoUpload`); null = ne.
  final DateTime? photoConsentAt;

  const AppSettings({
    this.theme = ThemePreference.system,
    this.quietStart = 21 * 60,
    this.quietEnd = 8 * 60,
    this.digest = DigestMode.auto,
    this.lastExportAt,
    this.lastZoneId,
    this.aiConsentAt,
    this.analyticsConsentAt,
    this.photoConsentAt,
  });

  AppSettings copyWith({
    ThemePreference? theme,
    MinuteOfDay? quietStart,
    MinuteOfDay? quietEnd,
    DigestMode? digest,
    DateTime? lastExportAt,
    String? lastZoneId,
    DateTime? Function()? aiConsentAt,
    DateTime? Function()? analyticsConsentAt,
    DateTime? Function()? photoConsentAt,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      quietStart: quietStart ?? this.quietStart,
      quietEnd: quietEnd ?? this.quietEnd,
      digest: digest ?? this.digest,
      lastExportAt: lastExportAt ?? this.lastExportAt,
      lastZoneId: lastZoneId ?? this.lastZoneId,
      aiConsentAt: aiConsentAt == null ? this.aiConsentAt : aiConsentAt(),
      analyticsConsentAt: analyticsConsentAt == null
          ? this.analyticsConsentAt
          : analyticsConsentAt(),
      photoConsentAt: photoConsentAt == null
          ? this.photoConsentAt
          : photoConsentAt(),
    );
  }

  @override
  List<Object?> get props => [
    theme,
    quietStart,
    quietEnd,
    digest,
    lastExportAt,
    lastZoneId,
    aiConsentAt,
    analyticsConsentAt,
    photoConsentAt,
  ];
}
