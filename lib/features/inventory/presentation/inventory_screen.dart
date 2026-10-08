import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/inventory_alerts.dart';
import '../domain/inventory_item.dart';
import '../domain/shopping_item.dart';
import 'inventory_controller.dart';
import 'inventory_form_screen.dart';
import 'inventory_ui.dart';
import 'shopping_list_screen.dart';

/// Lehký sklad (spec 4.2, MVP 1.0 bod 4): zásoby po kategoriích a hlídač.
class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final itemsAsync = ref.watch(inventoryControllerProvider);
    final alerts = ref.watch(inventoryAlertsProvider);
    final openShopping = (ref.watch(shoppingControllerProvider).value ?? [])
        .where((s) => !s.done)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.inventoryTitle),
        actions: [
          IconButton(
            tooltip: l.shoppingTitle,
            icon: Badge(
              isLabelVisible: openShopping > 0,
              label: Text('$openShopping'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ShoppingListScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-inventory',
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const InventoryFormScreen())),
        icon: const Icon(Icons.add),
        label: Text(l.inventoryAdd),
      ),
      body: itemsAsync.when(
        skipError: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.commonErrorWithDetail('$e'))),
        data: (items) {
          if (items.isEmpty) {
            return _Empty(
              title: l.inventoryEmptyTitle,
              body: l.inventoryEmptyBody,
            );
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              if (alerts.isNotEmpty) _AlertsCard(alerts: alerts),
              for (final category in InventoryCategory.values)
                ..._section(context, l, category, items),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _section(
    BuildContext context,
    AppLocalizations l,
    InventoryCategory category,
    List<InventoryItem> items,
  ) {
    final inCategory = items.where((i) => i.category == category).toList();
    if (inCategory.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(
          inventoryCategoryLabel(l, category),
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
      for (final item in inCategory)
        ListTile(
          leading: Icon(inventoryCategoryIcon(item.category)),
          title: Text(item.name),
          subtitle: Text(inventorySubtitle(l, item)),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => InventoryFormScreen(initial: item),
            ),
          ),
        ),
    ];
  }
}

class _AlertsCard extends ConsumerWidget {
  const _AlertsCard({required this.alerts});

  final List<InventoryAlert> alerts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.notifications_active, color: scheme.tertiary),
              title: Text(l.inventoryAlertsTitle),
            ),
            for (final alert in alerts)
              ListTile(
                dense: true,
                title: Text(inventoryAlertText(l, alert)),
                trailing: alert.kind == InventoryAlertKind.lowStock
                    ? IconButton(
                        tooltip: l.inventoryToShoppingList,
                        icon: const Icon(Icons.add_shopping_cart),
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          await ref
                              .read(shoppingControllerProvider.notifier)
                              .add(
                                name: alert.item.name,
                                itemId: alert.item.id,
                                source: ShoppingSource.lowStock,
                              );
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                l.inventoryAddedToShopping(alert.item.name),
                              ),
                            ),
                          );
                        },
                      )
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(body, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
