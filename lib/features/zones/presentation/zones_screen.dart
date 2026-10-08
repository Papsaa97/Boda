import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../weather/presentation/weather_screen.dart';
import '../../../core/widgets/load_error_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../activity/presentation/controllers/activity_controller.dart';
import '../../builds/presentation/builds_screen.dart';
import '../../canvas/presentation/canvas_screen.dart';
import '../../incidents/presentation/incidents_controller.dart';
import '../../incidents/presentation/incidents_screen.dart';
import '../../inventory/presentation/inventory_controller.dart';
import '../../inventory/presentation/inventory_screen.dart';
import '../domain/zone_entity.dart';
import '../domain/zone_rules.dart';
import 'zone_detail_screen.dart';
import 'zone_form_screen.dart';
import 'zone_icons.dart';
import 'zones_controller.dart';

/// Záložka Zahrada: vstup do skladu a správa zón (přidat, upravit,
/// archivovat, smazat; FR-D3).
class ZonesScreen extends ConsumerWidget {
  const ZonesScreen({super.key});

  void _reportFailure(BuildContext context, WidgetRef ref) {
    if (!context.mounted || !ref.read(zonesControllerProvider).hasError) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).zoneSaveFailed)),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) {
    final controller = ref.read(zonesControllerProvider.notifier);
    final l = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      builder: (_) => _ZoneDialog(
        title: l.zoneNewTitle,
        onSubmit: (name, type) async {
          final error = await controller.addZone(name, type: type);
          if (context.mounted) _reportFailure(context, ref);
          return error;
        },
      ),
    );
  }

  void _edit(BuildContext context, ZoneEntity zone) => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => ZoneFormScreen(zone: zone)));

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
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context);
    final controller = ref.read(zonesControllerProvider.notifier);
    final blocker = await controller.deleteBlocker(zone.id);
    if (!context.mounted) return;
    switch (blocker) {
      case ZoneDeleteBlocker.inUse:
        final archive = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l.zoneCannotDeleteTitle),
            content: Text(l.zoneCannotDeleteBody(zone.name)),
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
        return;
      case ZoneDeleteBlocker.lastZone:
        messenger.showSnackBar(SnackBar(content: Text(l.zoneKeepOne)));
        return;
      case null:
        break;
    }
    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.zoneDeleteConfirmTitle(zone.name)),
        content: Text(l.zoneDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.zoneDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final result = await controller.deleteZone(zone.id);
    if (!context.mounted || result != null) return;
    if (ref.read(zonesControllerProvider).hasError) {
      _reportFailure(context, ref);
    } else {
      messenger.showSnackBar(SnackBar(content: Text(l.zoneDeleted(zone.name))));
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
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ZoneDetailScreen(zoneId: zone.id)),
        ),
        trailing: PopupMenuButton<String>(
          tooltip: l.zoneMoreActions(zone.name),
          onSelected: (action) => switch (action) {
            'edit' => _edit(context, zone),
            'archive' => _setArchived(context, ref, zone, !zone.archived),
            _ => _delete(context, ref, zone),
          },
          itemBuilder: (_) => [
            PopupMenuItem(value: 'edit', child: Text(l.zoneEdit)),
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
      appBar: AppBar(title: Text(l.navGarden)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-zone',
        onPressed: () => _add(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l.zoneNewTitle),
      ),
      body: zonesAsync.when(
        skipError: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => LoadErrorView(error: error, stack: stack),
        data: (zones) {
          final active = zones.where((z) => z.isActive).toList();
          final planned = zones
              .where((z) => z.isPlanned && !z.archived)
              .toList();
          final archived = zones.where((z) => z.archived).toList();
          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              const _InventoryCard(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  l.gardenZonesSection,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              for (final zone in active) tile(zone),
              const _PlanCard(),
              const _IncidentsCard(),
              const _BuildsCard(),
              const WeatherEntryCard(),
              if (planned.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    l.zonePlannedSection,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                for (final zone in planned) tile(zone),
              ],
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
  const _ZoneDialog({required this.title, required this.onSubmit});

  final String title;
  final Future<ZoneNameError?> Function(String name, ZoneType type) onSubmit;

  @override
  State<_ZoneDialog> createState() => _ZoneDialogState();
}

class _ZoneDialogState extends State<_ZoneDialog> {
  final _controller = TextEditingController();
  ZoneType _type = ZoneType.other;
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
            isExpanded: true,
            decoration: InputDecoration(labelText: l.zoneTypeLabel),
            items: [
              for (final type in ZoneType.values)
                DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(zoneIcon(type), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          zoneTypeLabel(l, type),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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

/// Karta skladu s počtem položek a upozornění hlídače.
class _InventoryCard extends ConsumerWidget {
  const _InventoryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final count = ref.watch(inventoryControllerProvider).value?.length ?? 0;
    final alerts = ref.watch(inventoryAlertsProvider).length;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ListTile(
        leading: const Icon(Icons.inventory_2_outlined),
        title: Text(l.gardenInventoryCard),
        subtitle: Text(
          alerts == 0
              ? l.gardenInventorySummary(count)
              : '${l.gardenInventorySummary(count)} · '
                    '${l.gardenAlertsSummary(alerts)}',
        ),
        trailing: alerts == 0
            ? const Icon(Icons.chevron_right)
            : Icon(Icons.notifications_active, color: scheme.tertiary),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const InventoryScreen())),
      ),
    );
  }
}

/// Vstup na plán zahrady (1.1).
class _PlanCard extends StatelessWidget {
  const _PlanCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ListTile(
        leading: const Icon(Icons.map_outlined),
        title: Text(l.canvasTitle),
        subtitle: Text(l.canvasCardSubtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const CanvasScreen())),
      ),
    );
  }
}

/// Vstup na problémy na zahradě (V2).
class _IncidentsCard extends ConsumerWidget {
  const _IncidentsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final open = ref.watch(openIncidentCountProvider);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ListTile(
        leading: Icon(
          open > 0 ? Icons.report_problem_outlined : Icons.healing_outlined,
        ),
        title: Text(l.incidentsTitle),
        subtitle: Text(
          open > 0 ? l.incidentsCardOpen(open) : l.incidentsCardSubtitle,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const IncidentsScreen())),
      ),
    );
  }
}

/// Vstup na návrhy staveb (V3).
class _BuildsCard extends StatelessWidget {
  const _BuildsCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ListTile(
        leading: const Icon(Icons.carpenter_outlined),
        title: Text(l.buildsTitle),
        subtitle: Text(l.buildsCardSubtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const BuildsScreen())),
      ),
    );
  }
}
