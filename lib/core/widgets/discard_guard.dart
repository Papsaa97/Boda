import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Hlídá neuložené změny ve formuláři: tlačítko i gesto zpět se nejdřív
/// zeptá, jestli je zahodit. Uložení přes `Navigator.pop` projde vždy.
class DiscardGuard extends StatelessWidget {
  const DiscardGuard({
    super.key,
    required this.hasChanges,
    required this.child,
  });

  /// Liší se formulář od stavu při otevření?
  final bool Function() hasChanges;
  final Widget child;

  @override
  Widget build(BuildContext context) => PopScope<Object?>(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) async {
      if (didPop) return;
      final navigator = Navigator.of(context);
      if (!hasChanges() || await confirmDiscard(context)) {
        navigator.pop(result);
      }
    },
    child: child,
  );
}

/// Dialog „Zahodit změny?“. Vrací true, když je uživatel chce zahodit.
Future<bool> confirmDiscard(BuildContext context) async {
  final l = AppLocalizations.of(context);
  final leave = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l.commonDiscardTitle),
      content: Text(l.commonDiscardBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.activityDiscardKeepEditing),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l.activityDiscardConfirm),
        ),
      ],
    ),
  );
  return leave == true;
}
