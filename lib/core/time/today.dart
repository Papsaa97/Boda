import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/providers.dart';

/// Okamžik, ke kterému se počítají „dnes“, „včera“ a dny bez záznamu.
///
/// Obnovuje se o půlnoci a při návratu do aplikace (HomeShell), takže
/// dashboard nezůstane viset na včerejšku, když aplikace běží přes noc.
class TodayNotifier extends Notifier<DateTime> {
  Timer? _midnight;

  @override
  DateTime build() {
    ref.onDispose(() => _midnight?.cancel());
    final now = ref.watch(clockProvider)();
    _scheduleMidnight(now);
    return now;
  }

  void refresh() {
    final now = ref.read(clockProvider)();
    _scheduleMidnight(now);
    state = now;
  }

  void _scheduleMidnight(DateTime now) {
    _midnight?.cancel();
    final next = DateTime(now.year, now.month, now.day + 1, 0, 0, 1);
    _midnight = Timer(next.difference(now), refresh);
  }
}

final todayProvider = NotifierProvider<TodayNotifier, DateTime>(
  TodayNotifier.new,
);
