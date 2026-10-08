import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/providers.dart';
import '../../../core/formatting/dates.dart';
import '../../../l10n/app_localizations.dart';
import '../../settings/presentation/settings_controller.dart';
import '../domain/consents.dart';

/// Souhlasy odděleně a odvolatelně (kap. 9): zpracování dotazů AI
/// a anonymní analytika. Diagnostika z fotek přijde ve V2.
class ConsentsScreen extends ConsumerWidget {
  const ConsentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final now = ref.read(clockProvider);
    final ai = settings.aiConsentAt;
    final analytics = settings.analyticsConsentAt;
    final photo = settings.photoConsentAt;

    return Scaffold(
      appBar: AppBar(title: Text(l.consentsTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l.consentsIntro),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.auto_awesome_outlined),
            title: Text(l.settingsAiConsent),
            subtitle: Text(
              '${ai == null ? l.settingsAiConsentOff : l.settingsAiConsentOn(formatDate(ai))}\n'
              '${l.consentsAiHelp}',
            ),
            isThreeLine: true,
            value: ai != null,
            onChanged: (on) => controller.update(
              (s) => s.copyWith(aiConsentAt: () => on ? now() : null),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.query_stats),
            title: Text(l.consentsAnalytics),
            subtitle: Text(
              '${analytics == null ? l.consentsAnalyticsOff : l.consentsAnalyticsOn(formatDate(analytics))}\n'
              '${l.consentsAnalyticsHelp}',
            ),
            isThreeLine: true,
            value: analytics != null,
            onChanged: (on) => controller.update(
              (s) => s.copyWith(analyticsConsentAt: () => on ? now() : null),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.local_florist_outlined),
            title: Text(l.consentsPhoto),
            subtitle: Text(
              '${photo == null ? l.consentsPhotoOff : l.consentsPhotoOn(formatDate(photo))}\n'
              '${l.consentsPhotoHelp}',
            ),
            isThreeLine: true,
            value: photo != null,
            onChanged: (on) => controller.update(
              (s) => s.copyWith(photoConsentAt: () => on ? now() : null),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l.consentsSync(privacyPolicyVersion),
              style: theme.textTheme.bodySmall,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: Text(l.consentsPolicy),
            subtitle: const Text(privacyPolicyUrl),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => launchUrl(
              Uri.parse(privacyPolicyUrl),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
      ),
    );
  }
}
