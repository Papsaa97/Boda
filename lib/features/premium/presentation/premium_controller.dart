import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../domain/premium.dart';

/// Nárok na Premium přihlášeného uživatele (bez účtu Free).
class PremiumController extends AsyncNotifier<Entitlement> {
  @override
  Future<Entitlement> build() async {
    final user = ref.watch(currentUserProvider).value;
    final repo = ref.watch(entitlementRepositoryProvider);
    final purchases = ref.watch(purchaseServiceProvider);
    if (user == null || repo == null) {
      await purchases.logOut();
      return Entitlement.free;
    }
    await purchases.logIn(user.id);
    return repo.load(user.id);
  }

  /// Koupí nabídku a načte nárok znovu. Zrušený nákup není chyba.
  Future<void> purchase(PremiumOffer offer) =>
      _afterStore(() => ref.read(purchaseServiceProvider).purchase(offer));

  /// Obnoví nákupy z obchodu (nový telefon) a načte nárok znovu.
  Future<void> restore() =>
      _afterStore(() => ref.read(purchaseServiceProvider).restore());

  Future<void> _afterStore(Future<void> Function() op) async {
    if (ref.read(currentUserProvider).value == null) {
      throw const PurchaseFailure(PurchaseFailureKind.notSignedIn);
    }
    await op();
    // Nárok zapíše webhook obchodu na serveru; aplikace si ho načte.
    ref.invalidateSelf();
    await future;
  }
}

final premiumControllerProvider =
    AsyncNotifierProvider<PremiumController, Entitlement>(
      PremiumController.new,
    );

/// Nabídky z obchodu (prázdné, dokud platby nejsou zapnuté).
final premiumOffersProvider = FutureProvider<List<PremiumOffer>>((ref) async {
  final purchases = ref.watch(purchaseServiceProvider);
  return purchases.available ? purchases.offers() : const [];
});
