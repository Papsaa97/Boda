import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/text/numbers.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/shopping_item.dart';
import '../domain/units.dart';
import 'inventory_controller.dart';
import 'inventory_ui.dart';

/// Nákupní seznam. Odškrtnutím položky propojené se skladem se koupené
/// množství rovnou přičte do skladu.
class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    ShoppingItem item,
  ) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final done = !item.done;
    final linked = item.itemId == null
        ? null
        : ref.read(inventoryItemProvider(item.itemId!));
    final qty = item.qty;
    final unit = item.unit;
    final restock =
        done &&
        linked != null &&
        qty != null &&
        unit != null &&
        unit.convert(qty, linked.unit) != null;
    await ref
        .read(shoppingControllerProvider.notifier)
        .setDone(item.id, done, restock: restock);
    if (restock) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l.shoppingRestocked(linked.name, formatQty(l, qty, unit)),
          ),
        ),
      );
    }
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<_NewItem>(
      context: context,
      builder: (_) => const _AddDialog(),
    );
    if (result == null) return;
    await ref
        .read(shoppingControllerProvider.notifier)
        .add(name: result.name, qty: result.qty, unit: result.unit);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final itemsAsync = ref.watch(shoppingControllerProvider);
    final hasDone = (itemsAsync.value ?? const []).any((s) => s.done);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.shoppingTitle),
        actions: [
          if (hasDone)
            IconButton(
              tooltip: l.shoppingClearDone,
              icon: const Icon(Icons.playlist_remove),
              onPressed: () =>
                  ref.read(shoppingControllerProvider.notifier).clearDone(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-shopping',
        onPressed: () => _add(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l.shoppingAdd),
      ),
      body: itemsAsync.when(
        skipError: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.commonErrorWithDetail('$e'))),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l.shoppingEmptyTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(l.shoppingEmptyBody, textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              for (final item in items)
                CheckboxListTile(
                  value: item.done,
                  onChanged: (_) => _toggle(context, ref, item),
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    item.name,
                    style: item.done
                        ? const TextStyle(
                            decoration: TextDecoration.lineThrough,
                          )
                        : null,
                  ),
                  subtitle: _subtitle(l, item),
                  secondary: IconButton(
                    tooltip: l.commonDelete,
                    icon: const Icon(Icons.close),
                    onPressed: () => ref
                        .read(shoppingControllerProvider.notifier)
                        .delete(item.id),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget? _subtitle(AppLocalizations l, ShoppingItem item) {
    final parts = <String>[
      if (item.qty != null && item.unit != null)
        formatQty(l, item.qty!, item.unit!)
      else if (item.qty != null)
        formatDecimal(item.qty!),
      if (item.source == ShoppingSource.boda) l.shoppingFromBoda,
      if (item.source == ShoppingSource.lowStock) l.shoppingFromLowStock,
    ];
    return parts.isEmpty ? null : Text(parts.join(' · '));
  }
}

class _NewItem {
  const _NewItem(this.name, this.qty, this.unit);

  final String name;
  final double? qty;
  final InventoryUnit? unit;
}

class _AddDialog extends StatefulWidget {
  const _AddDialog();

  @override
  State<_AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<_AddDialog> {
  final _name = TextEditingController();
  final _qty = TextEditingController();
  InventoryUnit _unit = InventoryUnit.ks;

  @override
  void dispose() {
    _name.dispose();
    _qty.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final qty = parseDecimal(_qty.text);
    Navigator.of(context).pop(
      _NewItem(
        name,
        qty != null && qty > 0 ? qty : null,
        qty == null ? null : _unit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.shoppingAdd),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l.shoppingNameLabel),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _qty,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(labelText: l.shoppingQtyLabel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<InventoryUnit>(
                  initialValue: _unit,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l.inventoryUnitLabel),
                  items: [
                    for (final u in InventoryUnit.values)
                      DropdownMenuItem(value: u, child: Text(unitLabel(l, u))),
                  ],
                  onChanged: (u) => setState(() => _unit = u ?? _unit),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.commonCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l.commonSave)),
      ],
    );
  }
}
