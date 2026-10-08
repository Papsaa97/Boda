import '../../../core/formatting/dates.dart';
import '../../inventory/domain/inventory_item.dart';
import '../domain/assistant_backend.dart';
import '../domain/dose_calculator.dart';

/// Ukázkový režim Bódi bez AI (do připojení účtu a backendu).
///
/// Nic neodesílá: odpovídá z dat v telefonu, ukáže spočítané dávky,
/// nejbližší úkoly a nabídne akce. Je vždy jasně označený.
class DemoAssistantBackend implements AssistantBackend {
  const DemoAssistantBackend();

  @override
  bool get isDemo => true;

  @override
  Future<AssistantReply> ask(AssistantRequest request) async {
    final context = request.context;
    final zones = context.focusZones.isEmpty
        ? context.zones
        : context.focusZones;
    final lines = <String>[
      'Jsem v ukázkovém režimu bez AI, takže ti zatím neporadím vlastními '
          'slovy. Ukážu ti, co o zahradě vím a co umím spočítat.',
    ];

    final calculations = context.calculations;
    if (calculations.isNotEmpty) {
      lines.add('');
      lines.add('Dávky podle tvých údajů:');
      for (final c in calculations.take(5)) {
        lines.add('• ${c.label}: ${c.result} (${c.source})');
      }
    } else if (context.inventory.any((i) => i.labelDose != null)) {
      lines.add('');
      lines.add(
        'Zóny nemají zadanou výměru, dávku na zónu proto nespočítám. '
        'Výměru doplníš v detailu zóny.',
      );
    } else {
      lines.add('');
      lines.add(
        'Ve skladu nemáš hnojivo s dávkou na m² z obalu. Až ji zadáš, '
        'spočítám dávku na každou zónu s výměrou.',
      );
    }

    final tasks = context.openTasks.take(3).toList();
    if (tasks.isNotEmpty) {
      lines.add('');
      lines.add('Nejbližší úkoly:');
      for (final t in tasks) {
        lines.add('• ${t.title} (${formatDate(t.effectiveDate)})');
      }
    }

    final low = [
      for (final i in context.inventory)
        if (i.lowStockThreshold != null && i.stockQty <= i.lowStockThreshold!)
          i,
    ];
    if (low.isNotEmpty) {
      lines.add('');
      lines.add(
        'Dochází: ${low.map((i) => i.name).join(', ')}. '
        'Můžeš si to přidat na nákupní seznam.',
      );
    }

    final actions = <AssistantAction>[];
    for (final zone in zones) {
      for (final item in context.inventory) {
        if (actions.length >= 2) break;
        if (item.category != InventoryCategory.fertilizer) continue;
        final c = zoneDose(item, zone);
        if (c == null) continue;
        actions.add(
          TaskAction(
            title: 'Pohnojit ${zone.name}: ${item.name} ${c.result}',
            zoneId: zone.id,
          ),
        );
      }
    }
    for (final i in low.take(3)) {
      actions.add(ShoppingAction(name: i.name, unit: i.unit));
    }
    return AssistantReply(answer: lines.join('\n'), actions: actions);
  }
}
