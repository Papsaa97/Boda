import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/dates.dart';
import '../../../core/text/numbers.dart';
import '../../../core/widgets/load_error_view.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/build_design.dart';
import '../domain/build_params.dart';
import '../domain/calculators.dart';
import 'build_editor_screen.dart';
import 'build_ui.dart';
import 'builds_controller.dart';

IconData templateIcon(BuildTemplate t) => switch (t) {
  BuildTemplate.raisedBed => Icons.yard_outlined,
  BuildTemplate.path => Icons.route_outlined,
  BuildTemplate.bridge => Icons.water_outlined,
  BuildTemplate.shelter => Icons.roofing_outlined,
};

/// Návrhy staveb (V3, spec 5.7): seznam a nový návrh ze šablony.
class BuildsScreen extends ConsumerWidget {
  const BuildsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(buildsControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.buildsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-build',
        onPressed: () => _new(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l.buildsNew),
      ),
      body: async.when(
        skipError: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => LoadErrorView(error: e, stack: stack),
        data: (builds) => ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            const DisclaimerCard(),
            if (builds.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Text(l.buildsEmpty, textAlign: TextAlign.center),
              ),
            for (final b in builds) _BuildTile(design: b),
          ],
        ),
      ),
    );
  }

  Future<void> _new(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final template = await showModalBottomSheet<BuildTemplate>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                l.buildsChooseTemplate,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final t in BuildTemplate.values)
              ListTile(
                leading: Icon(templateIcon(t)),
                title: Text(templateLabel(l, t)),
                subtitle: Text(templateHint(l, t)),
                onTap: () => Navigator.of(context).pop(t),
              ),
          ],
        ),
      ),
    );
    if (template == null || !context.mounted) return;
    final draft = ref
        .read(buildsControllerProvider.notifier)
        .draft(template, templateLabel(l, template));
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BuildEditorScreen(initial: draft, isNew: true),
      ),
    );
  }
}

/// Trvalé upozornění na každém návrhu (FR-G3).
class DisclaimerCard extends StatelessWidget {
  const DisclaimerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      color: scheme.secondaryContainer,
      child: ListTile(
        leading: Icon(Icons.info_outline, color: scheme.onSecondaryContainer),
        title: Text(
          AppLocalizations.of(context).buildsDisclaimer,
          style: TextStyle(color: scheme.onSecondaryContainer),
        ),
      ),
    );
  }
}

class _BuildTile extends StatelessWidget {
  const _BuildTile({required this.design});

  final BuildDesign design;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final plan = planFor(design.values);
    final total = formatDecimal(plan.total(design.prices).round());
    return ListTile(
      leading: Icon(templateIcon(design.template)),
      title: Text(design.name),
      subtitle: Text(
        [
          templateLabel(l, design.template),
          l.buildsTotal(total),
          if (design.updatedAt case final at?) l.buildsUpdated(formatDate(at)),
        ].join(' · '),
      ),
      trailing: plan.hasDanger
          ? Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.error,
            )
          : const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BuildEditorScreen(initial: design),
        ),
      ),
    );
  }
}
