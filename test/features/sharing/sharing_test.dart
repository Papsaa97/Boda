import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:zahradnik_boda/core/di/providers.dart';
import 'package:zahradnik_boda/features/account/domain/auth_service.dart';
import 'package:zahradnik_boda/features/sharing/data/supabase_sharing_remote.dart';
import 'package:zahradnik_boda/features/sharing/domain/sharing.dart';
import 'package:zahradnik_boda/features/sharing/presentation/sharing_controller.dart';
import 'package:zahradnik_boda/features/sharing/presentation/sharing_screen.dart';
import 'package:zahradnik_boda/l10n/app_localizations.dart';

import '../../helpers/fake_auth_service.dart';
import '../../helpers/fakes.dart';

class FakeSharingRemote implements SharingRemote {
  FakeSharingRemote(this.list);

  List<GardenMember> list;
  final removed = <String>[];
  final accepted = <String>[];
  String acceptsInto = 'garden-a';
  SharingFailure? inviteFails;

  @override
  Future<List<GardenMember>> members(String gardenId) async => list;

  @override
  Future<GardenInvite> createInvite(String gardenId) async {
    if (inviteFails != null) throw SharingException(inviteFails!);
    return GardenInvite(code: 'ABCDEFGH', expiresAt: DateTime(2026, 6, 22));
  }

  @override
  Future<String> acceptInvite(String code) async {
    accepted.add(code);
    return acceptsInto;
  }

  @override
  Future<void> removeMember(String gardenId, String userId) async {
    removed.add(userId);
    list = [
      for (final m in list)
        if (m.userId != userId) m,
    ];
  }
}

const owner = GardenMember(
  userId: 'user-1',
  role: GardenRole.owner,
  email: 'papi@example.cz',
);
const babi = GardenMember(
  userId: 'user-2',
  role: GardenRole.editor,
  displayName: 'Babi',
  email: 'babi@example.cz',
);

List<Override> _overrides(FakeSharingRemote remote, {String me = 'user-1'}) => [
  ...testOverrides(),
  gardenIdProvider.overrideWithValue('garden-a'),
  sharingRemoteProvider.overrideWithValue(remote),
  authServiceProvider.overrideWithValue(
    FakeAuthService(
      user: AccountUser(id: me, email: '$me@example.cz'),
    ),
  ),
];

Future<void> _pump(WidgetTester tester, List<Override> overrides) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: const MaterialApp(
        locale: Locale('cs'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: SharingScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('invite codes are normalized and shown in two halves', () {
    expect(normalizeInviteCode(' abcd-efgh '), 'ABCDEFGH');
    expect(normalizeInviteCode('ABCD EFG2'), 'ABCDEFG2');
    // 0, O, 1, I a L v kódu nejsou (pletou se).
    expect(normalizeInviteCode('ABCD-EFG0'), isNull);
    expect(normalizeInviteCode('ABCD-EFGI'), isNull);
    expect(normalizeInviteCode('ABCDEFG'), isNull);
    expect(
      GardenInvite(code: 'ABCDEFGH', expiresAt: DateTime(2026)).display,
      'ABCD-EFGH',
    );
  });

  test('server errors map to failures', () {
    expect(sharingFailureFor('premium_required'), SharingFailure.notPremium);
    expect(sharingFailureFor('not_owner'), SharingFailure.notOwner);
    expect(sharingFailureFor('invalid_invite'), SharingFailure.invalidCode);
    expect(sharingFailureFor('něco jiného'), SharingFailure.failed);
  });

  test('member label falls back to email', () {
    expect(babi.label, 'Babi');
    expect(owner.label, 'papi@example.cz');
  });

  test('controller loads members, invites and removes', () async {
    final remote = FakeSharingRemote([owner, babi]);
    final c = ProviderContainer(overrides: _overrides(remote));
    addTearDown(c.dispose);
    c.listen(sharingControllerProvider, (_, _) {});
    final state = await c.read(sharingControllerProvider.future);
    expect(state.myRole, GardenRole.owner);
    expect(state.isOwner, isTrue);

    final invite = await c.read(sharingControllerProvider.notifier).invite();
    expect(invite.display, 'ABCD-EFGH');
    expect(c.read(sharingControllerProvider).value!.invite, invite);

    await c.read(sharingControllerProvider.notifier).remove('user-2');
    expect(remote.removed, ['user-2']);
    expect(c.read(sharingControllerProvider).value!.members, [owner]);
  });

  test('a member is not the owner', () async {
    final remote = FakeSharingRemote([owner, babi]);
    final c = ProviderContainer(overrides: _overrides(remote, me: 'user-2'));
    addTearDown(c.dispose);
    c.listen(sharingControllerProvider, (_, _) {});
    final state = await c.read(sharingControllerProvider.future);
    expect(state.myRole, GardenRole.editor);
    expect(state.isOwner, isFalse);
  });

  test('a garden not yet on the server has no members', () async {
    final remote = _NotOwnerRemote();
    final c = ProviderContainer(overrides: _overrides(remote));
    addTearDown(c.dispose);
    c.listen(sharingControllerProvider, (_, _) {});
    final state = await c.read(sharingControllerProvider.future);
    expect(state.onServer, isFalse);
    expect(state.members, isEmpty);
  });

  test('without a backend sharing is unavailable', () async {
    final c = ProviderContainer(
      overrides: [
        ...testOverrides(),
        gardenIdProvider.overrideWithValue('garden-a'),
      ],
    );
    addTearDown(c.dispose);
    c.listen(sharingControllerProvider, (_, _) {});
    await Future<void>.delayed(Duration.zero);
    expect(
      c.read(sharingControllerProvider).error,
      isA<SharingException>().having(
        (e) => e.failure,
        'failure',
        SharingFailure.unavailable,
      ),
    );
  });

  test('joining the same garden again keeps the data', () async {
    final remote = FakeSharingRemote([owner, babi]);
    final c = ProviderContainer(overrides: _overrides(remote));
    addTearDown(c.dispose);
    c.listen(sharingControllerProvider, (_, _) {});
    await c.read(sharingControllerProvider.future);
    final notifier = c.read(sharingControllerProvider.notifier);
    expect(() => notifier.join('nic'), throwsA(isA<SharingException>()));
    expect(await notifier.join('abcd-efgh'), JoinResult.alreadyHere);
    expect(remote.accepted, ['ABCDEFGH']);
  });

  testWidgets('owner sees members, creates an invite and removes a member', (
    tester,
  ) async {
    final remote = FakeSharingRemote([owner, babi]);
    await _pump(tester, _overrides(remote));

    expect(find.text('papi@example.cz (ty)'), findsOneWidget);
    expect(find.text('Babi'), findsOneWidget);
    expect(find.text('Vlastník'), findsOneWidget);
    expect(find.text('Člen'), findsOneWidget);
    expect(find.text('Opustit sdílenou zahradu'), findsNothing);

    await tester.tap(find.text('Pozvat člena'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(SelectableText, 'ABCD-EFGH'), findsOneWidget);
    expect(find.text('Platí do 22. 6. 2026'), findsOneWidget);

    await tester.tap(find.text('Odebrat'));
    await tester.pumpAndSettle();
    expect(find.text('Odebrat člena?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Odebrat'));
    await tester.pumpAndSettle();
    expect(remote.removed, ['user-2']);
    expect(find.text('Babi'), findsNothing);
    expect(find.text('Člen odebrán'), findsOneWidget);
  });

  testWidgets('invite without Premium explains why', (tester) async {
    final remote = FakeSharingRemote([owner])
      ..inviteFails = SharingFailure.notPremium;
    await _pump(tester, _overrides(remote));
    await tester.tap(find.text('Pozvat člena'));
    await tester.pumpAndSettle();
    expect(find.text('Pozvat člena může vlastník s Premium.'), findsOneWidget);
  });

  testWidgets('member cannot invite but can leave; bad code is rejected', (
    tester,
  ) async {
    final remote = FakeSharingRemote([owner, babi]);
    await _pump(tester, _overrides(remote, me: 'user-2'));
    expect(find.text('Babi (ty)'), findsOneWidget);
    expect(find.text('Pozvat člena'), findsNothing);
    expect(find.text('Odebrat'), findsNothing);
    expect(find.text('Opustit sdílenou zahradu'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'ABC');
    await tester.tap(find.widgetWithText(OutlinedButton, 'Připojit se'));
    await tester.pumpAndSettle();
    expect(
      find.text('Kód má 8 písmen a číslic, například ABCD-EFGH.'),
      findsOneWidget,
    );
    expect(remote.accepted, isEmpty);
  });

  testWidgets('signed out user is asked to sign in', (tester) async {
    await _pump(tester, [
      ...testOverrides(),
      gardenIdProvider.overrideWithValue('garden-a'),
      sharingRemoteProvider.overrideWithValue(FakeSharingRemote([])),
      authServiceProvider.overrideWithValue(FakeAuthService()),
    ]);
    expect(find.text('Pro sdílení se nejdřív přihlas.'), findsOneWidget);
  });
}

class _NotOwnerRemote extends FakeSharingRemote {
  _NotOwnerRemote() : super([]);

  @override
  Future<List<GardenMember>> members(String gardenId) async =>
      throw const SharingException(SharingFailure.notOwner);
}
