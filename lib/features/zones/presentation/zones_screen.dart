import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../activity/presentation/controllers/activity_controller.dart';
import '../domain/zone_entity.dart';
import '../domain/zone_rules.dart';
import 'zone_icons.dart';
import 'zones_controller.dart';

/// Správa seznamu zón: přidat, přejmenovat, smazat.
class ZonesScreen extends ConsumerWidget {
  const ZonesScreen({super.key});

  /// Dialog s názvem zóny. [onSubmit] vrací chybu, která se ukáže v poli,
  /// nebo null, když se uložení povedlo a dialog se může zavřít.
  Future<void> _nameDialog(
    BuildContext context, {
    required String title,
    String? initial,
    required Future<String?> Function(String name) onSubmit,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) =>
          _ZoneNameDialog(title: title, initial: initial, onSubmit: onSubmit),
    );
  }

  void _reportFailure(BuildContext context, WidgetRef ref) {
    if (!context.mounted || !ref.read(zonesControllerProvider).hasError) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Změnu zón se nepodařilo uložit.')),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    ZoneEntity zone,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final blocker = await ref
        .read(zonesControllerProvider.notifier)
        .deleteZone(zone.id);
    switch (blocker) {
      case ZoneDeleteBlocker.hasActivities:
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Zónu ${zone.name} nejde smazat, má v deníku záznamy.',
            ),
          ),
        );
      case ZoneDeleteBlocker.lastZone:
        messenger.showSnackBar(
          const SnackBar(content: Text('Aspoň jedna zóna musí zůstat.')),
        );
      case null:
        if (context.mounted) _reportFailure(context, ref);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zonesAsync = ref.watch(zonesControllerProvider);
    final activities = ref.watch(activityControllerProvider).value ?? const [];
    final controller = ref.read(zonesControllerProvider.notifier);

    final usage = <String, int>{};
    for (final a in activities) {
      usage[a.zoneId] = (usage[a.zoneId] ?? 0) + 1;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Zóny')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-zone',
        onPressed: () => _nameDialog(
          context,
          title: 'Nová zóna',
          onSubmit: (name) async {
            final error = await controller.addZone(name);
            if (context.mounted) _reportFailure(context, ref);
            return error;
          },
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nová zóna'),
      ),
      body: zonesAsync.when(
        skipError: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Chyba: $error')),
        data: (zones) => ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            for (final zone in zones)
              ListTile(
                leading: Icon(zoneIcon(zone.id)),
                title: Text(zone.name),
                subtitle: Text('Záznamů: ${usage[zone.id] ?? 0}'),
                onTap: () => _nameDialog(
                  context,
                  title: 'Přejmenovat zónu',
                  initial: zone.name,
                  onSubmit: (name) async {
                    final error = await controller.renameZone(zone.id, name);
                    if (context.mounted) _reportFailure(context, ref);
                    return error;
                  },
                ),
                trailing: IconButton(
                  tooltip: 'Smazat zónu ${zone.name}',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _delete(context, ref, zone),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ZoneNameDialog extends StatefulWidget {
  const _ZoneNameDialog({
    required this.title,
    required this.initial,
    required this.onSubmit,
  });

  final String title;
  final String? initial;
  final Future<String?> Function(String name) onSubmit;

  @override
  State<_ZoneNameDialog> createState() => _ZoneNameDialogState();
}

class _ZoneNameDialogState extends State<_ZoneNameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;
    setState(() => _saving = true);
    final error = await widget.onSubmit(_controller.text);
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
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: 'např. Záhon u plotu',
          errorText: _error,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Zrušit'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: const Text('Uložit'),
        ),
      ],
    );
  }
}
