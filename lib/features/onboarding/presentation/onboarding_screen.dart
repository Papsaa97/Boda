import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../zones/domain/zone_entity.dart';
import '../../zones/presentation/zone_icons.dart';
import '../../zones/presentation/zones_controller.dart';

/// První spuštění: uvítání a výběr zón zahrady velkými kartami.
///
/// Onboarding končí uložením vybraných zón. Jakmile seznam zón není
/// prázdný, kořen aplikace sám přepne na hlavní obrazovku.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  final Set<String> _selected = {'Z1'};
  bool _saving = false;

  List<ZoneEntity> get _chosen =>
      zoneCatalog.where((z) => _selected.contains(z.id)).toList();

  Future<void> _finish() async {
    setState(() => _saving = true);
    await ref.read(zonesControllerProvider.notifier).addZones(_chosen);
    if (!mounted) return;
    if (ref.read(zonesControllerProvider).hasError) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zóny se nepodařilo uložit, zkus to znovu.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: switch (_step) {
            0 => _Welcome(
                key: const ValueKey(0),
                onStart: () => setState(() => _step = 1),
              ),
            1 => _ZonePicker(
                key: const ValueKey(1),
                selected: _selected,
                onToggle: (id) => setState(() {
                  if (!_selected.remove(id)) _selected.add(id);
                }),
                onBack: () => setState(() => _step = 0),
                onNext: () => setState(() => _step = 2),
              ),
            _ => _Summary(
                key: const ValueKey(2),
                zones: _chosen,
                saving: _saving,
                onBack: () => setState(() => _step = 1),
                onFinish: _finish,
              ),
          },
        ),
      ),
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Icon(Icons.yard, size: 96, color: theme.colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            'Zahradník Bóďa',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Tvůj parťák na každé semínko i šroubek. '
            'Zapisuj, co na zahradě děláš, a Bóďa ti řekne, co dál.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const Spacer(),
          FilledButton(
            onPressed: onStart,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: const Text('Začít bez registrace'),
          ),
          const SizedBox(height: 12),
          Text(
            'Všechno zůstává jen v tomhle zařízení.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.progress, required this.title, this.onBack});

  final double progress;
  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Zpět',
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(value: progress, minHeight: 8),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
        ),
      ],
    );
  }
}

class _ZonePicker extends StatelessWidget {
  const _ZonePicker({
    super.key,
    required this.selected,
    required this.onToggle,
    required this.onBack,
    required this.onNext,
  });

  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepHeader(progress: 0.5, title: 'Co máš na zahradě?', onBack: onBack),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Vyber, co pěstuješ. Z toho budou zóny, ke kterým budeš zapisovat práci.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: GridView.count(
            padding: const EdgeInsets.all(24),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              for (final zone in zoneCatalog)
                _CategoryCard(
                  zone: zone,
                  selected: selected.contains(zone.id),
                  onTap: () => onToggle(zone.id),
                  scheme: scheme,
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: FilledButton(
            onPressed: selected.isEmpty ? null : onNext,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: Text(selected.isEmpty ? 'Vyber aspoň jednu' : 'Pokračovat'),
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.zone,
    required this.selected,
    required this.onTap,
    required this.scheme,
  });

  final ZoneEntity zone;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? scheme.primaryContainer : scheme.surfaceContainerHighest,
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
                    if (selected) Icon(Icons.check_circle, color: scheme.primary),
                  ],
                ),
                const Spacer(),
                Text(zone.name, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    super.key,
    required this.zones,
    required this.saving,
    required this.onBack,
    required this.onFinish,
  });

  final List<ZoneEntity> zones;
  final bool saving;
  final VoidCallback onBack;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepHeader(progress: 1, title: 'Tvoje zahrada je připravená', onBack: onBack),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Tyhle zóny jsem ti založil. Přejmenovat je nebo přidat vlastní můžeš kdykoli v záložce Zóny.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              for (final zone in zones)
                ListTile(
                  leading: Icon(zoneIcon(zone.id)),
                  title: Text(zone.name),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: FilledButton(
            onPressed: saving ? null : onFinish,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: const Text('Jdeme na zahradu'),
          ),
        ),
      ],
    );
  }
}
