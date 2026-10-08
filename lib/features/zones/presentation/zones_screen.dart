import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../activity/presentation/controllers/activity_controller.dart';
import '../domain/zone_entity.dart';
import '../domain/zone_rules.dart';
import 'zone_icons.dart';
import 'zones_controller.dart';

/// Správa zón: přidat, upravit, archivovat, smazat (FR-D3).
class ZonesScreen extends ConsumerWidget {
  const ZonesScreen({super.key});

  void _reportFailure(BuildContext context, WidgetRef ref) {
    if (!context.mounted || !ref.read(zonesControllerProvider).hasError) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).zoneSaveFailed)),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, [ZoneEntity? zone]) {
    final controller = ref.read(zonesControllerProvider.notifier);
    final l = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      builder: (_) => _ZoneDialog(
        title: zone == null ? l.zoneNewTitle : l.zoneRenameTitle,
        initial: zone,
        onSubmit: (name, type) async {
          final error = zone == null
              ? await controller.addZone(name, type: type)
              : await controller.editZone(zone.id, name: name, type: type);
          if (context.mounted) _reportFailure(context, ref);
          return error;
        },
      ),
    );
  }

  Future<void> _setArchived(
    BuildContext context,
    WidgetRef ref,
    ZoneEntity zone,
    bool archived,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context);
    final ok = await ref
        .read(zonesControllerProvider.notifier)
        .setArchived(zone.id, archived);
    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text(l.zoneArchiveKeepOne)));
    } else if (context.mounted) {
      _reportFailure(context, ref);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    ZoneEntity zone,
    int activityCount,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context);
    final blocker = await ref
        .read(zonesControllerProvider.notifier)
        .deleteZone(zone.id);
    if (!context.mounted) return;
    switch (blocker) {
      case ZoneDeleteBlocker.hasActivities:
        final archive = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l.zoneCannotDeleteTitle),
            content: Text(l.zoneCannotDeleteBody(zone.name, activityCount)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l.commonCancel),
              ),
              if (!zone.archived)
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(l.zoneArchive),
                ),
            ],
          ),
        );
        if (archive == true && context.mounted) {
          await _setArchived(context, ref, zone, true);
        }
      case ZoneDeleteBlocker.lastZone:
        messenger.showSnackBar(SnackBar(content: Text(l.zoneKeepOne)));
      case null:
        if (ref.read(zonesControllerProvider).hasError) {
          _reportFailure(context, ref);
        } else {
          messenger.showSnackBar(
            SnackBar(content: Text(l.zoneDeleted(zone.name))),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final zonesAsync = ref.watch(zonesControllerProvider);
    final activities = ref.watch(activityControllerProvider).value ?? const [];

    final usage = <String, int>{};
    for (final a in activities) {
      usage[a.zoneId] = (usage[a.zoneId] ?? 0) + 1;
    }

    Widget tile(ZoneEntity zone) {
      final count = usage[zone.id] ?? 0;
      return ListTile(
        leading: Icon(zoneIcon(zone.type)),
        title: Text(zone.name),
        subtitle: Text(l.zoneActivityCount(count)),
        onTap: () => _edit(context, ref, zone),
        trailing: PopupMenuButton<String>(
          tooltip: l.zoneMoreActions(zone.name),
          onSelected: (action) => switch (action) {
            'archive' => _setArchived(context, ref, zone, !zone.archived),
            _ => _delete(context, ref, zone, count),
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'archive',
              child: Text(zone.archived ? l.zoneUnarchive : l.zoneArchive),
            ),
            PopupMenuItem(value: 'delete', child: Text(l.zoneDelete)),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.zoneTitle)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-zone',
        onPressed: () => _edit(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l.zoneNewTitle),
      ),
      body: zonesAsync.when(
        skipError: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text(l.commonErrorWithDetail('$error'))),
        data: (zones) {
          final active = zones.where((z) => !z.archived).toList();
          final archived = zones.where((z) => z.archived).toList();
          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              for (final zone in active) tile(zone),
              if (archived.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    l.zoneArchivedSection,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                for (final zone in archived) tile(zone),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ZoneDialog extends StatefulWidget {
  const _ZoneDialog({
    required this.title,
    required this.initial,
    required this.onSubmit,
  });

  final String title;
  final ZoneEntity? initial;
  final Future<ZoneNameError?> Function(String name, ZoneType type) onSubmit;

  @override
  State<_ZoneDialog> createState() => _ZoneDialogState();
}

class _ZoneDialogState extends State<_ZoneDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial?.name,
  );
  late ZoneType _type = widget.initial?.type ?? ZoneType.other;
  ZoneNameError? _error;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;
    setState(() => _saving = true);
    final error = await widget.onSubmit(_controller.text, _type);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _error = error;
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: l.zoneNameHint,
              errorText: switch (_error) {
                ZoneNameError.empty => l.zoneNameEmpty,
                ZoneNameError.duplicate => l.zoneNameDuplicate,
                null => null,
              },
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ZoneType>(
            initialValue: _type,
            decoration: InputDecoration(labelText: l.zoneTypeLabel),
            items: [
              for (final type in ZoneType.values)
                DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(zoneIcon(type), size: 20),
                      const SizedBox(width: 12),
                      Text(zoneTypeLabel(l, type)),
                    ],
                  ),
                ),
            ],
            onChanged: (type) => setState(() => _type = type ?? _type),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.commonCancel),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: Text(l.commonSave),
        ),
      ],
    );
  }
}
