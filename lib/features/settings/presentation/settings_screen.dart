import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app/app_info.dart';
import '../../../core/formatting/dates.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/di/providers.dart';
import '../../account/presentation/account_screen.dart';
import '../../backup/presentation/backup_actions.dart';
import '../../stats/presentation/stats_screen.dart';
import '../domain/app_settings.dart';
import 'settings_controller.dart';

/// Nastavení: motiv, tiché hodiny, ranní přehled, záloha (spec 10.3).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _pickQuietTime(
    BuildContext context,
    WidgetRef ref, {
    required bool start,
  }) async {
    final settings = ref.read(settingsControllerProvider);
    final current = start ? settings.quietStart : settings.quietEnd;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    if (picked == null) return;
    final minutes = picked.hour * 60 + picked.minute;
    await ref
        .read(settingsControllerProvider.notifier)
        .update(
          (s) => start
              ? s.copyWith(quietStart: minutes)
              : s.copyWith(quietEnd: minutes),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final theme = Theme.of(context);

    Widget section(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );

    final lastExport = settings.lastExportAt;
    final user = ref.watch(currentUserProvider).value;
    final consentAt = settings.aiConsentAt;

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          section(l.settingsAppearance),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemePreference>(
              segments: [
                ButtonSegment(
                  value: ThemePreference.system,
                  icon: const Icon(Icons.brightness_auto),
                  label: Text(l.settingsThemeSystem),
                ),
                ButtonSegment(
                  value: ThemePreference.light,
                  icon: const Icon(Icons.light_mode_outlined),
                  label: Text(l.settingsThemeLight),
                ),
                ButtonSegment(
                  value: ThemePreference.dark,
                  icon: const Icon(Icons.dark_mode_outlined),
                  label: Text(l.settingsThemeDark),
                ),
              ],
              selected: {settings.theme},
              onSelectionChanged: (s) => controller.setTheme(s.first),
            ),
          ),
          section(l.settingsNotifications),
          ListTile(
            leading: const Icon(Icons.bedtime_outlined),
            title: Text(l.settingsQuietStart),
            trailing: Text(formatMinuteOfDay(settings.quietStart)),
            onTap: () => _pickQuietTime(context, ref, start: true),
          ),
          ListTile(
            leading: const Icon(Icons.wb_twilight),
            title: Text(l.settingsQuietEnd),
            trailing: Text(formatMinuteOfDay(settings.quietEnd)),
            onTap: () => _pickQuietTime(context, ref, start: false),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(l.settingsQuietHelp, style: theme.textTheme.bodySmall),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.summarize_outlined),
            title: Text(l.settingsDigest),
            subtitle: Text(_digestHelp(l, settings.digest)),
            trailing: DropdownButton<DigestMode>(
              value: settings.digest,
              underline: const SizedBox.shrink(),
              items: [
                for (final mode in DigestMode.values)
                  DropdownMenuItem(
                    value: mode,
                    child: Text(_digestLabel(l, mode)),
                  ),
              ],
              onChanged: (mode) {
                if (mode != null) {
                  controller.update((s) => s.copyWith(digest: mode));
                }
              },
            ),
          ),
          section(l.settingsData),
          ListTile(
            leading: const Icon(Icons.cloud_sync_outlined),
            title: Text(l.accountSettingsTile),
            subtitle: Text(
              user == null
                  ? l.accountSettingsSignedOut
                  : l.accountSettingsSignedIn(user.email ?? ''),
            ),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AccountScreen())),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.auto_awesome_outlined),
            title: Text(l.settingsAiConsent),
            subtitle: Text(
              consentAt == null
                  ? l.settingsAiConsentOff
                  : l.settingsAiConsentOn(formatDate(consentAt)),
            ),
            value: consentAt != null,
            onChanged: (on) => controller.update(
              (s) => s.copyWith(
                aiConsentAt: () => on ? ref.read(clockProvider)() : null,
              ),
            ),
          ),
          if (kIsWeb)
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l.backupUnavailableWeb),
            )
          else ...[
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: Text(l.backupExport),
              subtitle: Text(
                lastExport == null
                    ? l.backupExportSubtitleNever
                    : l.backupExportSubtitle(formatDate(lastExport)),
              ),
              onTap: () => exportBackup(context, ref),
            ),
            ListTile(
              leading: const Icon(Icons.settings_backup_restore),
              title: Text(l.backupImport),
              subtitle: Text(l.backupImportSubtitle),
              onTap: () => importBackup(context, ref),
            ),
          ],
          ListTile(
            leading: const Icon(Icons.insights_outlined),
            title: Text(l.statsTitle),
            subtitle: Text(l.statsSubtitle),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const StatsScreen())),
          ),
          section(l.settingsAbout),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(l.settingsPrivacy),
            subtitle: Text(l.settingsVersion(appVersion)),
          ),
        ],
      ),
    );
  }

  static String _digestLabel(AppLocalizations l, DigestMode mode) =>
      switch (mode) {
        DigestMode.auto => l.digestAuto,
        DigestMode.daily => l.digestDaily,
        DigestMode.weekly => l.digestWeekly,
        DigestMode.off => l.digestOff,
      };

  static String _digestHelp(AppLocalizations l, DigestMode mode) =>
      switch (mode) {
        DigestMode.auto => l.digestAutoHelp,
        DigestMode.daily => l.digestDailyHelp,
        DigestMode.weekly => l.digestWeeklyHelp,
        DigestMode.off => l.digestOffHelp,
      };
}
