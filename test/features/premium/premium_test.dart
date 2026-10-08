import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:zahradnik_boda/core/di/providers.dart';
import 'package:zahradnik_boda/core/telemetry/telemetry.dart';
import 'package:zahradnik_boda/features/account/domain/auth_service.dart';
import 'package:zahradnik_boda/features/account/domain/consents.dart';
import 'package:zahradnik_boda/features/account/presentation/consent_sync.dart';
import 'package:zahradnik_boda/features/account/presentation/consents_screen.dart';
import 'package:zahradnik_boda/features/activity/presentation/controllers/activity_controller.dart';
import 'package:zahradnik_boda/features/premium/domain/premium.dart';
import 'package:zahradnik_boda/features/premium/presentation/paywall_screen.dart';
import 'package:zahradnik_boda/features/premium/presentation/premium_controller.dart';
import 'package:zahradnik_boda/features/settings/domain/app_settings.dart';
import 'package:zahradnik_boda/features/settings/presentation/settings_controller.dart';
import 'package:zahradnik_boda/l10n/app_localizations.dart';

import '../../helpers/fake_auth_service.dart';
import '../../helpers/fakes.dart';

const _user = AccountUser(id: 'user-1', email: 'papi@example.cz');

class FakeEntitlements implements EntitlementRepository {
  Entitlement current = Entitlement.free;
  final List<String> loads = [];

  @override
  Future<Entitlement> load(String userId) async {
    loads.add(userId);
    return current;
  }
}

/// Obchod bez obchodu: nákup rovnou „zapíše webhook“ do [entitlements].
class FakePurchases implements PurchaseService {
  FakePurchases(this.entitlements);

  final FakeEntitlements entitlements;
  String? loggedIn;
  PurchaseFailureKind? failWith;

  static const yearly = PremiumOffer(
    id: 'premium_yearly',
    period: BillingPeriod.yearly,
    price: '449,00 Kč',
    trialDays: 7,
  );
  static const monthly = PremiumOffer(
    id: 'premium_monthly',
    period: BillingPeriod.monthly,
    price: '69,00 Kč',
  );

  @override
  bool get available => true;

  @override
  Future<void> logIn(String userId) async => loggedIn = userId;

  @override
  Future<void> logOut() async => loggedIn = null;

  @override
  Future<List<PremiumOffer>> offers() async => const [yearly, monthly];

  @override
  Future<void> purchase(PremiumOffer offer) async {
    final fail = failWith;
    if (fail != null) throw PurchaseFailure(fail);
    entitlements.current = Entitlement(
      plan: Plan.premium,
      validUntil: testNow.add(const Duration(days: 365)),
      source: PlanSource.play,
    );
  }

  @override
  Future<void> restore() async {}
}

class FakeProfiles implements ProfileRemote {
  final List<Map<String, Object?>> saved = [];

  @override
  Future<void> saveConsents(String userId, Map<String, Object?> c) async =>
      saved.add(c);
}

class RecordingAnalytics implements Analytics {
  final List<String> events = [];

  @override
  void track(String event, [Map<String, Object> properties = const {}]) =>
      events.add('$event $properties');
}

Future<void> _pump(
  WidgetTester tester,
  Widget home,
  List<Override> overrides,
) async {
  tester.view.physicalSize = const Size(1080, 6000);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_app(home, overrides));
  await tester.pumpAndSettle();
}

Widget _app(Widget home, List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(
    locale: const Locale('cs'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: home,
  ),
);

void main() {
  group('entitlement', () {
    test('server row maps to a plan, unknown values mean Free', () {
      expect(Entitlement.fromRow(null), Entitlement.free);
      final yearly = Entitlement.fromRow({
        'plan': 'premium',
        'valid_until': '2027-10-07T10:00:00Z',
        'source': 'appstore',
      });
      expect(yearly.source, PlanSource.appstore);
      expect(yearly.isPremiumAt(testNow), isTrue);
      expect(yearly.isPremiumAt(DateTime.utc(2027, 10, 8)), isFalse);
      expect(
        Entitlement.fromRow({'plan': 'premium'}).isPremiumAt(testNow),
        isTrue,
      );
      expect(Entitlement.fromRow({'plan': 'gold'}).plan, Plan.free);
    });

    test('controller loads the plan of the signed-in user', () async {
      final entitlements = FakeEntitlements();
      final purchases = FakePurchases(entitlements);
      final auth = FakeAuthService();
      final c = ProviderContainer(
        overrides: [
          ...testOverrides(),
          authServiceProvider.overrideWithValue(auth),
          entitlementRepositoryProvider.overrideWithValue(entitlements),
          purchaseServiceProvider.overrideWithValue(purchases),
        ],
      );
      addTearDown(c.dispose);
      c.listen(premiumControllerProvider, (_, _) {});
      expect(await c.read(premiumControllerProvider.future), Entitlement.free);
      expect(entitlements.loads, isEmpty);

      await expectLater(
        c
            .read(premiumControllerProvider.notifier)
            .purchase(FakePurchases.yearly),
        throwsA(
          isA<PurchaseFailure>().having(
            (f) => f.kind,
            'kind',
            PurchaseFailureKind.notSignedIn,
          ),
        ),
      );

      await auth.verifyCode('papi@example.cz', FakeAuthService.code);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await c.read(premiumControllerProvider.future);
      expect(purchases.loggedIn, 'user-1');
      expect(entitlements.loads, ['user-1']);

      await c
          .read(premiumControllerProvider.notifier)
          .purchase(FakePurchases.yearly);
      final e = c.read(premiumControllerProvider).value!;
      expect(e.isPremiumAt(testNow), isTrue);
    });
  });

  group('paywall', () {
    testWidgets('without payments the offer shows spec prices only', (
      tester,
    ) async {
      await _pump(tester, const PaywallScreen(), testOverrides());
      await tester.pumpAndSettle();
      expect(find.text('449 Kč za rok'), findsOneWidget);
      expect(find.text('69 Kč za měsíc'), findsOneWidget);
      expect(find.textContaining('na začátku sezóny 2028'), findsOneWidget);
      final buy = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(buy.onPressed, isNull);
    });

    testWidgets('signed in with payments: buy and see Premium', (tester) async {
      final entitlements = FakeEntitlements();
      await _pump(tester, const PaywallScreen(), [
        ...testOverrides(),
        authServiceProvider.overrideWithValue(FakeAuthService(user: _user)),
        entitlementRepositoryProvider.overrideWithValue(entitlements),
        purchaseServiceProvider.overrideWithValue(FakePurchases(entitlements)),
      ]);
      await tester.pumpAndSettle();
      expect(find.text('449,00 Kč za rok'), findsOneWidget);
      expect(find.text('Teď máš Free.'), findsOneWidget);

      await tester.tap(find.text('Vyzkoušet Premium (7 dní zdarma)'));
      await tester.pumpAndSettle();
      expect(find.text('Premium je aktivní.'), findsOneWidget);
      expect(find.text('Máš Premium. Díky!'), findsOneWidget);
    });

    testWidgets('a cancelled purchase is not reported as an error', (
      tester,
    ) async {
      final entitlements = FakeEntitlements();
      final purchases = FakePurchases(entitlements)
        ..failWith = PurchaseFailureKind.cancelled;
      await _pump(tester, const PaywallScreen(), [
        ...testOverrides(),
        authServiceProvider.overrideWithValue(FakeAuthService(user: _user)),
        entitlementRepositoryProvider.overrideWithValue(entitlements),
        purchaseServiceProvider.overrideWithValue(purchases),
      ]);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Měsíčně'));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Vyzkoušet Premium'));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
      expect(find.text('Teď máš Free.'), findsOneWidget);
    });
  });

  group('consents', () {
    test('server shape records version, time and withdrawal', () {
      final at = DateTime.utc(2026, 10, 8, 9);
      final json = consentsJson(
        AppSettings(aiConsentAt: at),
        changedAt: DateTime.utc(2026, 10, 9),
      );
      expect(json['policyVersion'], privacyPolicyVersion);
      expect(json['aiProcessing'], {
        'granted': true,
        'at': '2026-10-08T09:00:00.000Z',
      });
      expect(json['analytics'], {
        'granted': false,
        'at': '2026-10-09T00:00:00.000Z',
      });
    });

    test('consents reach the profile after sign-in and on change', () async {
      final profiles = FakeProfiles();
      final auth = FakeAuthService();
      final c = ProviderContainer(
        overrides: [
          ...testOverrides(),
          authServiceProvider.overrideWithValue(auth),
          profileRemoteProvider.overrideWithValue(profiles),
        ],
      );
      addTearDown(c.dispose);
      c.listen(consentSyncProvider, (_, _) {});
      // Bez účtu se nic neposílá.
      await c
          .read(settingsControllerProvider.notifier)
          .update((s) => s.copyWith(aiConsentAt: () => testNow));
      expect(profiles.saved, isEmpty);

      await auth.verifyCode('papi@example.cz', FakeAuthService.code);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(profiles.saved, hasLength(1));
      expect((profiles.saved.last['aiProcessing']! as Map)['granted'], isTrue);

      await c
          .read(settingsControllerProvider.notifier)
          .update((s) => s.copyWith(aiConsentAt: () => null));
      await Future<void>.delayed(Duration.zero);
      expect(profiles.saved, hasLength(2));
      expect((profiles.saved.last['aiProcessing']! as Map)['granted'], isFalse);
    });

    test('analytics stays silent without consent', () async {
      final sink = RecordingAnalytics();
      final settings = InMemorySettingsRepository();
      final c = ProviderContainer(
        overrides: [
          ...testOverrides(settings: settings),
          analyticsSinkProvider.overrideWithValue(sink),
        ],
      );
      addTearDown(c.dispose);
      await c.read(activityControllerProvider.future);
      final controller = c.read(activityControllerProvider.notifier);
      await controller.addActivity(
        title: 'Zálivka',
        date: testNow,
        zoneId: 'zone-1',
      );
      expect(sink.events, isEmpty);

      await c
          .read(settingsControllerProvider.notifier)
          .update((s) => s.copyWith(analyticsConsentAt: () => testNow));
      await controller.addActivity(
        title: 'Zálivka',
        date: testNow,
        zoneId: 'zone-1',
      );
      expect(sink.events, ['activity_logged {type: other, photos: 0}']);
    });

    testWidgets('the consents screen toggles analytics', (tester) async {
      final settings = InMemorySettingsRepository();
      await _pump(
        tester,
        const ConsentsScreen(),
        testOverrides(settings: settings),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Bez souhlasu, nic se neodesílá'),
        findsOneWidget,
      );
      await tester.tap(find.text('Anonymní statistiky používání'));
      await tester.pumpAndSettle();
      expect(settings.current.analyticsConsentAt, testNow);
      expect(find.textContaining('Souhlas udělen'), findsOneWidget);
    });
  });
}
