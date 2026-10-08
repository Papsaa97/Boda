import 'package:posthog_flutter/posthog_flutter.dart';

import 'telemetry.dart';

/// Analytika v PostHogu (EU). Volá se jen přes [analyticsProvider], tedy
/// jen se souhlasem; automatické události (životní cyklus, obrazovky,
/// záznam relace) jsou v nastavení vypnuté, posílá se jen to, co je v
/// [AnalyticsEvent].
class PosthogAnalytics implements Analytics {
  const PosthogAnalytics();

  @override
  void track(String event, [Map<String, Object> properties = const {}]) {
    Posthog().capture(eventName: event, properties: properties);
  }
}
