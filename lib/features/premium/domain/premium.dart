import 'package:equatable/equatable.dart';

/// Tarif uživatele (spec kap. 11.2).
enum Plan { free, premium }

/// Kde bylo Premium koupeno (sloupec `entitlements.source`).
enum PlanSource { play, appstore, promo }

/// Nárok na Premium. Zapisuje ho jen backend (webhook plateb), aplikace
/// ho čte (DECLOG D73).
class Entitlement extends Equatable {
  const Entitlement({this.plan = Plan.free, this.validUntil, this.source});

  static const free = Entitlement();

  final Plan plan;

  /// Konec předplaceného období; null u Premium = bez omezení.
  final DateTime? validUntil;
  final PlanSource? source;

  bool isPremiumAt(DateTime now) =>
      plan == Plan.premium && (validUntil == null || validUntil!.isAfter(now));

  /// Řádek tabulky `entitlements`; neznámé hodnoty znamenají Free.
  static Entitlement fromRow(Map<String, Object?>? row) {
    if (row == null) return free;
    final plan = row['plan'] == 'premium' ? Plan.premium : Plan.free;
    final until = row['valid_until'];
    final source = row['source'];
    return Entitlement(
      plan: plan,
      validUntil: until is String ? DateTime.tryParse(until) : null,
      source: PlanSource.values.where((s) => s.name == source).firstOrNull,
    );
  }

  @override
  List<Object?> get props => [plan, validUntil, source];
}

/// Délka předplatného.
enum BillingPeriod { monthly, yearly }

/// Nabídka z obchodu (Google Play, App Store) přes RevenueCat.
class PremiumOffer extends Equatable {
  const PremiumOffer({
    required this.id,
    required this.period,
    required this.price,
    this.trialDays = 0,
  });

  final String id;
  final BillingPeriod period;

  /// Cena naformátovaná obchodem v měně uživatele („449,00 Kč“).
  final String price;
  final int trialDays;

  @override
  List<Object?> get props => [id, period, price, trialDays];
}

/// Proč nákup neprošel.
enum PurchaseFailureKind {
  /// Uživatel nákup zrušil sám; nehlásí se jako chyba.
  cancelled,

  /// Platby v této verzi nejsou (bez klíče RevenueCat nebo na webu).
  unavailable,

  /// Nákup je potřeba spárovat s účtem: uživatel není přihlášený.
  notSignedIn,
  offline,

  /// Platba čeká (např. hotově v obchodě); Premium přijde později.
  pending,
  unknown,
}

class PurchaseFailure implements Exception {
  const PurchaseFailure(this.kind);

  final PurchaseFailureKind kind;

  @override
  String toString() => 'PurchaseFailure(${kind.name})';
}

/// Nákupy v obchodě (RevenueCat nad Google Play Billing a App Store,
/// spec 7.1). Výsledek nákupu zapíše na server webhook; aplikace pak
/// nárok načte znovu přes [EntitlementRepository].
abstract interface class PurchaseService {
  /// Platby jsou v této verzi zapnuté.
  bool get available;

  /// Spáruje nákupy s účtem (RevenueCat `app_user_id` = id uživatele).
  Future<void> logIn(String userId);

  Future<void> logOut();

  Future<List<PremiumOffer>> offers();

  /// Koupí nabídku; skončí až po potvrzení obchodem.
  Future<void> purchase(PremiumOffer offer);

  /// Obnoví dřívější nákupy (nový telefon, přeinstalace).
  Future<void> restore();
}

/// Build bez plateb: nabídka se ukáže, koupit zatím nejde.
class UnavailablePurchaseService implements PurchaseService {
  const UnavailablePurchaseService();

  @override
  bool get available => false;

  @override
  Future<void> logIn(String userId) async {}

  @override
  Future<void> logOut() async {}

  @override
  Future<List<PremiumOffer>> offers() async => const [];

  @override
  Future<void> purchase(PremiumOffer offer) async =>
      throw const PurchaseFailure(PurchaseFailureKind.unavailable);

  @override
  Future<void> restore() async =>
      throw const PurchaseFailure(PurchaseFailureKind.unavailable);
}

/// Nárok na Premium uložený na serveru.
abstract interface class EntitlementRepository {
  /// Nárok přihlášeného uživatele; bez účtu nebo bez řádku Free.
  Future<Entitlement> load(String userId);
}

/// Ceny ze specifikace (kap. 11.2), než je řekne obchod.
const specYearlyPrice = '449 Kč';
const specMonthlyPrice = '69 Kč';
const specTrialDays = 7;
