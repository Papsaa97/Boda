import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../account/presentation/sync_controller.dart';
import '../domain/sharing.dart';

class SharingState extends Equatable {
  const SharingState({
    this.members = const [],
    this.invite,
    this.myId,
    this.onServer = true,
  });

  final List<GardenMember> members;

  /// Poslední vytvořená pozvánka (jen v této obrazovce).
  final GardenInvite? invite;
  final String? myId;

  /// Zahrada už je na serveru (jinak ji nejdřív musí nahrát synchronizace).
  final bool onServer;

  GardenRole? get myRole =>
      members.where((m) => m.userId == myId).firstOrNull?.role;

  bool get isOwner => myRole == GardenRole.owner || members.isEmpty;

  SharingState copyWith({List<GardenMember>? members, GardenInvite? invite}) =>
      SharingState(
        members: members ?? this.members,
        invite: invite ?? this.invite,
        myId: myId,
        onServer: onServer,
      );

  @override
  List<Object?> get props => [members, invite, myId, onServer];
}

/// Výsledek zadání kódu pozvánky.
enum JoinResult {
  /// Telefon přešel na sdílenou zahradu (aplikace se znovu načte).
  switched,

  /// Uživatel už členem této zahrady je.
  alreadyHere,
}

/// Sdílení zahrady v rodině (V2, DECLOG D89).
class SharingController extends AsyncNotifier<SharingState> {
  @override
  Future<SharingState> build() async {
    final remote = ref.watch(sharingRemoteProvider);
    if (remote == null) {
      throw const SharingException(SharingFailure.unavailable);
    }
    final user = await ref.watch(currentUserProvider.future);
    if (user == null) throw const SharingException(SharingFailure.notSignedIn);
    try {
      final members = await remote.members(ref.watch(gardenIdProvider));
      return SharingState(members: members, myId: user.id);
    } on SharingException catch (e) {
      // Zahrada, kterou synchronizace ještě nenahrála, nemá členy.
      if (e.failure == SharingFailure.notOwner) {
        return SharingState(myId: user.id, onServer: false);
      }
      rethrow;
    }
  }

  SharingRemote get _remote {
    final remote = ref.read(sharingRemoteProvider);
    if (remote == null) {
      throw const SharingException(SharingFailure.unavailable);
    }
    return remote;
  }

  /// Nová pozvánka (jen vlastník s Premium). Hází [SharingException].
  Future<GardenInvite> invite() async {
    final invite = await _remote.createInvite(ref.read(gardenIdProvider));
    final current = state.value ?? const SharingState();
    state = AsyncData(current.copyWith(invite: invite));
    return invite;
  }

  /// Přijme pozvánku. Před převzetím sdílené zahrady se odešlou změny
  /// v telefonu, ať se z vlastní zahrady nic neztratí. Hází
  /// [SharingException].
  Future<JoinResult> join(String input) async {
    final code = normalizeInviteCode(input);
    if (code == null) throw const SharingException(SharingFailure.invalidCode);
    final sync = ref.read(syncControllerProvider.notifier);
    await sync.syncNow();
    if (ref.read(syncControllerProvider).problem == SyncProblem.offline) {
      throw const SharingException(SharingFailure.offline);
    }
    final gardenId = await _remote.acceptInvite(code);
    if (gardenId == ref.read(gardenIdProvider)) {
      ref.invalidateSelf();
      return JoinResult.alreadyHere;
    }
    if (!await sync.adoptGarden(gardenId)) {
      throw const SharingException(SharingFailure.failed);
    }
    return JoinResult.switched;
  }

  /// Vlastník odebere člena. Hází [SharingException].
  Future<void> remove(String userId) async {
    await _remote.removeMember(ref.read(gardenIdProvider), userId);
    final current = state.value ?? const SharingState();
    state = AsyncData(
      current.copyWith(
        members: [
          for (final m in current.members)
            if (m.userId != userId) m,
        ],
      ),
    );
  }

  /// Člen opustí sdílenou zahradu; telefon začne novou prázdnou zahradu
  /// pojmenovanou [newGardenName]. Hází [SharingException].
  Future<void> leave(String newGardenName) async {
    final me = state.value?.myId;
    if (me == null) throw const SharingException(SharingFailure.notSignedIn);
    await _remote.removeMember(ref.read(gardenIdProvider), me);
    if (!await ref
        .read(syncControllerProvider.notifier)
        .startOwnGarden(newGardenName)) {
      throw const SharingException(SharingFailure.failed);
    }
  }
}

final sharingControllerProvider =
    AsyncNotifierProvider<SharingController, SharingState>(
      SharingController.new,
    );
