import 'package:flutter/foundation.dart';

/// Hlášení pádů (Sentry v EU, spec 7.1). Do hlášení nikdy nejdou osobní
/// údaje ani texty z deníku.
abstract interface class CrashReporter {
  void recordError(Object error, StackTrace? stack, {bool fatal = false});
}

/// Bez nastaveného Sentry: chyba jen do konzole při vývoji.
class DebugCrashReporter implements CrashReporter {
  const DebugCrashReporter();

  @override
  void recordError(Object error, StackTrace? stack, {bool fatal = false}) {
    debugPrint('${fatal ? 'Pád' : 'Chyba'}: $error\n${stack ?? ''}');
  }
}

/// Anonymní analytika (PostHog v EU, spec 7.1) pro měření hypotéz H1–H4.
/// Vlastnosti události jsou jen čísla a výčty, žádný text od uživatele.
abstract interface class Analytics {
  void track(String event, [Map<String, Object> properties = const {}]);
}

class NoopAnalytics implements Analytics {
  const NoopAnalytics();

  @override
  void track(String event, [Map<String, Object> properties = const {}]) {}
}

/// Události (seznam je zároveň dokumentace, co se měří).
abstract final class AnalyticsEvent {
  static const activityLogged = 'activity_logged';
  static const taskCompleted = 'task_completed';
  static const assistantAsked = 'assistant_asked';
  static const paywallViewed = 'paywall_viewed';
}
