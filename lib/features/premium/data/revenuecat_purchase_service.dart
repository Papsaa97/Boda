import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../domain/premium.dart';

/// Nákupy přes RevenueCat (DECLOG D73): `app_user_id` je id uživatele
/// Supabase, takže webhook na serveru zapíše nárok ke správnému účtu.
/// Nabídky bere z aktuální offering (`annual`, `monthly`).
class RevenueCatPurchaseService implements PurchaseService {
  RevenueCatPurchaseService();

  final _packages = <String, Package>{};

  @override
  bool get available => true;

  @override
  Future<void> logIn(String userId) async {
    await _call(() => Purchases.logIn(userId));
  }

  @override
  Future<void> logOut() async {
    // Anonymní uživatel se odhlásit nedá; nevadí.
    try {
      await Purchases.logOut();
    } on PlatformException {
      return;
    }
  }

  @override
  Future<List<PremiumOffer>> offers() async {
    final offerings = await _call(Purchases.getOfferings);
    final current = offerings.current;
    if (current == null) return const [];
    _packages.clear();
    final result = <PremiumOffer>[];
    for (final (package, period) in [
      (current.monthly, BillingPeriod.monthly),
      (current.annual, BillingPeriod.yearly),
    ]) {
      if (package == null) continue;
      _packages[package.identifier] = package;
      result.add(
        PremiumOffer(
          id: package.identifier,
          period: period,
          price: package.storeProduct.priceString,
          trialDays: _trialDays(package.storeProduct),
        ),
      );
    }
    return result;
  }

  @override
  Future<void> purchase(PremiumOffer offer) async {
    final package = _packages[offer.id];
    if (package == null) {
      throw const PurchaseFailure(PurchaseFailureKind.unknown);
    }
    await _call(() => Purchases.purchase(PurchaseParams.package(package)));
  }

  @override
  Future<void> restore() async {
    await _call(Purchases.restorePurchases);
  }

  static int _trialDays(StoreProduct product) {
    final intro = product.introductoryPrice;
    if (intro == null || intro.price != 0) return 0;
    final days = switch (intro.periodUnit) {
      PeriodUnit.day => 1,
      PeriodUnit.week => 7,
      PeriodUnit.month => 30,
      PeriodUnit.year => 365,
      PeriodUnit.unknown => 0,
    };
    return days * intro.cycles;
  }

  /// Chyby obchodu na [PurchaseFailure], aby UI mluvilo česky a zrušený
  /// nákup se nehlásil jako chyba.
  static Future<T> _call<T>(Future<T> Function() op) async {
    try {
      return await op();
    } on PlatformException catch (e) {
      throw PurchaseFailure(switch (PurchasesErrorHelper.getErrorCode(e)) {
        PurchasesErrorCode.purchaseCancelledError =>
          PurchaseFailureKind.cancelled,
        PurchasesErrorCode.networkError => PurchaseFailureKind.offline,
        PurchasesErrorCode.paymentPendingError => PurchaseFailureKind.pending,
        _ => PurchaseFailureKind.unknown,
      });
    }
  }
}
