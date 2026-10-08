import 'package:sentry_flutter/sentry_flutter.dart';

import 'telemetry.dart';

/// Hlášení pádů do Sentry (EU). Bez osobních údajů: `sendDefaultPii` je
/// vypnuté, do hlášení jde jen výjimka, zásobník a verze aplikace.
class SentryCrashReporter implements CrashReporter {
  const SentryCrashReporter();

  @override
  void recordError(Object error, StackTrace? stack, {bool fatal = false}) {
    Sentry.captureException(
      error,
      stackTrace: stack,
      withScope: (scope) =>
          scope.level = fatal ? SentryLevel.fatal : SentryLevel.error,
    );
  }
}
