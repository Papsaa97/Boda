import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;
import 'package:zahradnik_boda/core/database/app_database.dart';
import 'package:zahradnik_boda/core/di/providers.dart';
import 'package:zahradnik_boda/core/photos/photo_storage.dart';
import 'package:zahradnik_boda/features/account/domain/auth_service.dart';
import 'package:zahradnik_boda/features/account/presentation/account_screen.dart';
import 'package:zahradnik_boda/features/account/presentation/sync_controller.dart';
import 'package:zahradnik_boda/features/assistant/data/demo_assistant_backend.dart';
import 'package:zahradnik_boda/features/assistant/data/supabase_assistant_backend.dart';
import 'package:zahradnik_boda/features/assistant/domain/assistant_backend.dart';
import 'package:zahradnik_boda/features/settings/data/drift_settings_repository.dart';
import 'package:zahradnik_boda/features/settings/domain/app_settings.dart';
import 'package:zahradnik_boda/features/settings/presentation/settings_controller.dart';
import 'package:zahradnik_boda/features/zones/data/drift_zone_repository.dart';
import 'package:zahradnik_boda/features/zones/domain/zone_entity.dart';
import 'package:zahradnik_boda/l10n/app_localizations.dart';

import '../../helpers/database.dart';
import '../../helpers/fake_auth_service.dart';
import '../../helpers/fake_sync_remote.dart';
import '../../helpers/fakes.dart';

Widget _screen(List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: const MaterialApp(
    locale: Locale('cs'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: AccountScreen(),
  ),
);

/// Počká, až synchronizace doběhne (běží na pozadí po přihlášení).
Future<SyncStatus> _settled(ProviderContainer c) async {
  for (var i = 0; i < 200; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final s = c.read(syncControllerProvider);
    if (!s.running && (s.lastSyncAt != null || s.conflictGardenId != null)) {
      return s;
    }
  }
  return c.read(syncControllerProvider);
}

void main() {
  group('sign in', () {
    testWidgets('without a backend the account is not offered', (tester) async {
      await tester.pumpWidget(_screen(testOverrides()));
      await tester.pumpAndSettle();
      expect(find.textContaining('Účet v této verzi'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('email, code, signed in, sign out', (tester) async {
      final auth = FakeAuthService();
      await tester.pumpWidget(
        _screen([
          ...testOverrides(),
          authServiceProvider.overrideWithValue(auth),
        ]),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'není e-mail');
      await tester.tap(find.text('Poslat kód'));
      await tester.pumpAndSettle();
      expect(find.text('Tohle nevypadá jako e-mail.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'papi@example.cz');
      await tester.tap(find.text('Poslat kód'));
      await tester.pumpAndSettle();
      expect(auth.sentTo, ['papi@example.cz']);
      expect(find.textContaining('papi@example.cz'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '000000');
      await tester.tap(find.text('Přihlásit'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Kód nesedí'), findsOneWidget);

      await tester.enterText(find.byType(TextField), FakeAuthService.code);
      await tester.tap(find.text('Přihlásit'));
      await tester.pumpAndSettle();
      expect(find.text('Účet papi@example.cz'), findsOneWidget);
      // Bez serveru pro synchronizaci se nic nesynchronizuje.
      expect(find.text('Ještě se nesynchronizovalo.'), findsOneWidget);

      await tester.tap(find.text('Odhlásit se'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Odhlásit se'));
      await tester.pumpAndSettle();
      expect(auth.currentUser, isNull);
      expect(find.text('Poslat kód'), findsOneWidget);
    });

    testWidgets('deleting the account asks first', (tester) async {
      final auth = FakeAuthService(
        user: const AccountUser(id: 'user-1', email: 'papi@example.cz'),
      );
      await tester.pumpWidget(
        _screen([
          ...testOverrides(),
          authServiceProvider.overrideWithValue(auth),
        ]),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Smazat účet'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Zrušit'));
      await tester.pumpAndSettle();
      expect(auth.deleted, isFalse);

      await tester.tap(find.text('Smazat účet'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Smazat natrvalo'));
      await tester.pumpAndSettle();
      expect(auth.deleted, isTrue);
      expect(find.textContaining('Účet je smazaný.'), findsOneWidget);
    });
  });

  group('sync controller', () {
    late AppDatabase db;
    late FakeSyncRemote server;
    late FakeAuthService auth;
    var restarts = 0;

    setUp(() async {
      db = memoryDatabase();
      await db.ensureDefaultGarden(newId: () => 'garden-a', now: testNow);
      server = FakeSyncRemote();
      auth = FakeAuthService();
      restarts = 0;
    });

    tearDown(() => db.close());

    ProviderContainer container() {
      final c = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          gardenIdProvider.overrideWithValue('garden-a'),
          clockProvider.overrideWithValue(() => testNow),
          photoStorageProvider.overrideWithValue(PhotoStorage('')),
          authServiceProvider.overrideWithValue(auth),
          syncRemoteProvider.overrideWithValue(server),
          restartAppProvider.overrideWithValue(() => restarts++),
        ],
      );
      addTearDown(c.dispose);
      c.listen(syncControllerProvider, (_, _) {});
      return c;
    }

    test('signing in uploads the garden', () async {
      await DriftZoneRepository(
        db,
        'garden-a',
        () => testNow,
      ).saveZone(const ZoneEntity(id: 'zone-1', name: 'Zelenina'));
      final c = container();
      await auth.verifyCode('papi@example.cz', FakeAuthService.code);
      final status = await _settled(c);
      expect(status.problem, isNull);
      expect(status.lastSyncAt, testNow);
      expect(server.table('zones').keys, ['zone-1']);
    });

    test('offline sync reports the problem and keeps the queue', () async {
      server.offline = true;
      final c = container();
      await auth.verifyCode('papi@example.cz', FakeAuthService.code);
      for (var i = 0; i < 100; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
        if (c.read(syncControllerProvider).problem != null) break;
      }
      expect(c.read(syncControllerProvider).problem, SyncProblem.offline);
      expect(await db.select(db.syncOutbox).get(), isNotEmpty);
    });

    test('an account with another garden asks, then adopts it', () async {
      server.table('gardens')['garden-x'] = {
        'id': 'garden-x',
        'name': 'Zahrada z účtu',
        'created_at': '2026-10-01T08:00:00.000Z',
        'updated_at': '2026-10-01T08:00:00.000Z',
        'server_updated_at': '2026-10-01T08:00:00.000Z',
      };
      final c = container();
      await auth.verifyCode('papi@example.cz', FakeAuthService.code);
      final status = await _settled(c);
      expect(status.conflictGardenId, 'garden-x');
      expect(server.table('gardens').keys, ['garden-x']);

      await c.read(syncControllerProvider.notifier).adoptAccountGarden();
      expect(restarts, 1);
      final gardens = await db.select(db.gardens).get();
      expect(gardens.map((g) => g.id), ['garden-x']);
    });

    test('signing out forgets the sync state', () async {
      final c = container();
      await auth.verifyCode('papi@example.cz', FakeAuthService.code);
      await _settled(c);
      await auth.signOut();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(c.read(syncControllerProvider), const SyncStatus());
    });
  });

  group('assistant access', () {
    test('real AI only with backend, account and consent', () async {
      final client = SupabaseClient('https://example.supabase.co', 'pk');
      addTearDown(client.dispose);
      final auth = FakeAuthService();
      final settings = InMemorySettingsRepository();
      final c = ProviderContainer(
        overrides: [
          ...testOverrides(settings: settings),
          supabaseClientProvider.overrideWithValue(client),
          authServiceProvider.overrideWithValue(auth),
        ],
      );
      addTearDown(c.dispose);
      c.listen(currentUserProvider, (_, _) {});
      await c.read(currentUserProvider.future);

      expect(c.read(assistantAccessProvider), AssistantAccess.signedOut);
      expect(c.read(assistantBackendProvider), isA<DemoAssistantBackend>());

      await auth.verifyCode('papi@example.cz', FakeAuthService.code);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(c.read(assistantAccessProvider), AssistantAccess.noConsent);
      expect(c.read(assistantBackendProvider).isDemo, isTrue);

      await c
          .read(settingsControllerProvider.notifier)
          .update((s) => s.copyWith(aiConsentAt: () => testNow));
      expect(c.read(assistantAccessProvider), AssistantAccess.ready);
      expect(c.read(assistantBackendProvider), isA<SupabaseAssistantBackend>());
      expect(settings.current.aiConsentAt, testNow);
    });

    test('without a backend the assistant stays in demo mode', () {
      final c = ProviderContainer(overrides: testOverrides());
      addTearDown(c.dispose);
      expect(c.read(assistantAccessProvider), AssistantAccess.noBackend);
      expect(c.read(assistantBackendProvider).isDemo, isTrue);
    });

    test('server errors map to failures the app can explain', () {
      expect(
        assistantFailureFor(401, null).kind,
        AssistantFailureKind.notSignedIn,
      );
      final limit = assistantFailureFor(429, {
        'error': 'limit',
        'usage': {'used': 30, 'limit': 30, 'plan': 'free'},
      });
      expect(limit.kind, AssistantFailureKind.limitReached);
      expect(limit.usage?.limit, 30);
      expect(assistantFailureFor(429, 'text').usage, isNull);
      expect(
        assistantFailureFor(503, null).kind,
        AssistantFailureKind.notConfigured,
      );
      expect(
        assistantFailureFor(500, null).kind,
        AssistantFailureKind.upstream,
      );
    });
  });

  test('AI consent survives a restart', () async {
    final db = memoryDatabase();
    addTearDown(db.close);
    final repo = await DriftSettingsRepository.open(db);
    final at = DateTime(2026, 10, 8, 9, 30);
    await repo.save(const AppSettings().copyWith(aiConsentAt: () => at));
    expect((await DriftSettingsRepository.open(db)).load().aiConsentAt, at);
    await repo.save(repo.load().copyWith(aiConsentAt: () => null));
    expect((await DriftSettingsRepository.open(db)).load().aiConsentAt, isNull);
  });
}
