import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../zones/domain/zone_entity.dart';
import '../../zones/presentation/zone_icons.dart';
import '../../zones/presentation/zones_controller.dart';

/// První spuštění: „Co pěstuješ?“ velkými kartami (spec 10.4).
///
/// Bez úvodní obrazovky a bez registrace (spec 10.1, bod 4): aplikace
/// rovnou ukáže výběr, ze kterého vzniknou zóny. Krok jde přeskočit,
/// pak se založí výchozí zóny. Jakmile seznam zón není prázdný, kořen
/// aplikace sám přepne na hlavní obrazovku.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final Set<ZoneType> _selected = {ZoneType.vegetable};
  bool _saving = false;

  Future<void> _save(List<ZoneType> types) async {
    final l = AppLocalizations.of(context);
    final newId = ref.read(newIdProvider);
    final zones = [
      for (final type in types)
        ZoneEntity(id: newId(), name: zoneTypeLabel(l, type), type: type),
    ];
    setState(() => _saving = true);
    await ref.read(zonesControllerProvider.notifier).addZones(zones);
    if (!mounted) return;
    if (ref.read(zonesControllerProvider).hasError) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.onboardingSaveFailed)));
    }
  }

  void _toggle(ZoneType type) => setState(() {
    if (!_selected.remove(type)) _selected.add(type);
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = AppLocalizations.of(context);
    final chosen = zoneCatalog.where(_selected.contains).toList();

    return Scaffold(
      // Hlavní tlačítko je vždy vidět, i když se karty nevejdou na displej.
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: FilledButton(
          onPressed: chosen.isEmpty || _saving ? null : () => _save(chosen),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          child: Text(
            chosen.isEmpty ? l.onboardingPickAtLeastOne : l.onboardingFinish,
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 8, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Icon(Icons.yard, color: scheme.primary, size: 28),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l.appTitle,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: _saving ? null : () => _save(defaultZoneTypes),
                      child: Text(l.onboardingSkip),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.onboardingZonesTitle,
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.onboardingZonesBody,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverGrid.extent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.25,
                children: [
                  for (final type in zoneCatalog)
                    _CategoryCard(
                      type: type,
                      selected: _selected.contains(type),
                      onTap: () => _toggle(type),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final ZoneType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected
            ? scheme.primaryContainer
            : scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selected ? scheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(zoneIcon(type), size: 32, color: scheme.primary),
                    const Spacer(),
                    if (selected)
                      Icon(Icons.check_circle, color: scheme.primary),
                  ],
                ),
                const Spacer(),
                Text(
                  zoneTypeLabel(AppLocalizations.of(context), type),
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
