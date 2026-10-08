import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../di/providers.dart';

/// Místo seznamu, který se nepodařilo načíst: srozumitelná věta pro
/// uživatele, podrobnosti jdou do hlášení chyb, ne na obrazovku.
class LoadErrorView extends ConsumerWidget {
  const LoadErrorView({super.key, required this.error, this.stack});

  final Object error;
  final StackTrace? stack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(crashReporterProvider).recordError(error, stack);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          AppLocalizations.of(context).commonLoadFailed,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
