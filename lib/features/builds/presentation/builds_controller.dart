import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../inventory/domain/units.dart';
import '../../inventory/presentation/inventory_controller.dart';
import '../domain/build_design.dart';
import '../domain/build_params.dart';
import '../domain/build_plan.dart';

/// Návrhy staveb zahrady, naposledy upravené nahoře (V3, spec 5.7).
class BuildsController extends AsyncNotifier<List<BuildDesign>> {
  @override
  Future<List<BuildDesign>> build() =>
      ref.watch(buildRepositoryProvider).getAll();

  /// Nový návrh z šablony s výchozími parametry (zatím neuložený).
  BuildDesign draft(BuildTemplate template, String name) => BuildDesign(
    id: ref.read(newIdProvider)(),
    name: name,
    values: BuildValues(template),
  );

  Future<void> save(BuildDesign design) async {
    final now = ref.read(clockProvider)();
    final stored = BuildDesign(
      id: design.id,
      name: design.name.trim(),
      values: BuildValues(design.template, design.values.toJson()),
      zoneId: design.zoneId,
      prices: design.prices,
      createdAt: design.createdAt ?? now,
      updatedAt: now,
    );
    await _mutate((list) async {
      await ref.read(buildRepositoryProvider).save(stored);
      return [stored, ...list.where((b) => b.id != stored.id)];
    });
  }

  Future<void> delete(String id) async {
    await _mutate((list) async {
      await ref.read(buildRepositoryProvider).delete(id);
      return list.where((b) => b.id != id).toList();
    });
  }

  /// Přidá výkaz materiálu na nákupní seznam; [label] dá položce název
  /// (s množstvím, když nákupní seznam jednotku nezná). Vrátí počet
  /// přidaných položek (duplicity seznam sám přeskočí).
  Future<int> addToShopping(
    List<BomLine> bom,
    String Function(BomLine line, {required bool withQuantity}) label,
  ) async {
    final shopping = ref.read(shoppingControllerProvider.notifier);
    await ref.read(shoppingControllerProvider.future);
    final before = ref.read(shoppingControllerProvider).value?.length ?? 0;
    for (final line in bom) {
      final unit = switch (line.material.unit) {
        BomUnit.pcs => InventoryUnit.ks,
        BomUnit.l => InventoryUnit.l,
        _ => null,
      };
      await shopping.add(
        name: label(line, withQuantity: unit == null),
        qty: unit == null ? null : line.quantity,
        unit: unit,
      );
    }
    final after = ref.read(shoppingControllerProvider).value?.length ?? 0;
    return after - before;
  }

  Future<void> _mutate(
    Future<List<BuildDesign>> Function(List<BuildDesign> current) op,
  ) async {
    final current = state.value ?? const <BuildDesign>[];
    state = await AsyncValue.guard(() => op(current));
  }
}

final buildsControllerProvider =
    AsyncNotifierProvider<BuildsController, List<BuildDesign>>(
      BuildsController.new,
    );
