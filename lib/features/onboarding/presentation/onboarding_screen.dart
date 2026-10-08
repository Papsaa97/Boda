import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final Set<String> _selected = {'Z1'};
  bool _saving = false;

  Future<void> _save(List<ZoneEntity> zones) async {
    setState(() => _saving = true);
    await ref.read(zonesControllerProvider.notifier).addZones(zones);
    if (!mounted) return;
    if (ref.read(zonesControllerProvider).hasError) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Zóny se nepodařilo uložit, zkus to znovu.'),
        ),
      );
    }
  }

  void _toggle(String id) => setState(() {
    if (!_selected.remove(id)) _selected.add(id);
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final chosen = zoneCatalog.where((z) => _selected.contains(z.id)).toList();

    return Scaffold(
      // Hlavní tlačítko je vždy vidět, i když se karty nevejdou na displej.
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: FilledButton(
          onPressed: chosen.isEmpty || _saving ? null : () => _save(chosen),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          child: Text(
            chosen.isEmpty ? 'Vyber aspoň jednu' : 'Jdeme na zahradu',
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
                        'Zahradník Bóďa',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: _saving ? null : () => _save(defaultZones),
                      child: const Text('Přeskočit'),
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
                    Text('Co pěstuješ?', style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Vyber, co máš na zahradě. Z toho budou zóny, ke kterým '
                      'budeš zapisovat práci. Upravit je můžeš kdykoli.',
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
                  for (final zone in zoneCatalog)
                    _CategoryCard(
                      zone: zone,
                      selected: _selected.contains(zone.id),
                      onTap: () => _toggle(zone.id),
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
    required this.zone,
    required this.selected,
    required this.onTap,
  });

  final ZoneEntity zone;
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
                    Icon(zoneIcon(zone.id), size: 32, color: scheme.primary),
                    const Spacer(),
                    if (selected)
                      Icon(Icons.check_circle, color: scheme.primary),
                  ],
                ),
                const Spacer(),
                Text(
                  zone.name,
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
