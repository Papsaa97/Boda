import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/formatting/dates.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/sharing.dart';
import 'sharing_controller.dart';

String sharingFailureText(AppLocalizations l, SharingFailure f) => switch (f) {
  SharingFailure.unavailable => l.sharingUnavailable,
  SharingFailure.notSignedIn => l.sharingNotSignedIn,
  SharingFailure.notPremium => l.sharingNotPremium,
  SharingFailure.notOwner => l.sharingNotOwner,
  SharingFailure.invalidCode => l.sharingInvalidCode,
  SharingFailure.offline => l.sharingOffline,
  SharingFailure.failed => l.sharingFailed,
};

String _roleText(AppLocalizations l, GardenRole r) => switch (r) {
  GardenRole.owner => l.sharingRoleOwner,
  GardenRole.editor => l.sharingRoleEditor,
  GardenRole.viewer => l.sharingRoleViewer,
};

Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
}) async {
  final l = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(action),
        ),
      ],
    ),
  );
  return ok == true;
}

/// Sdílení zahrady v rodině (V2): členové, pozvánka, připojení kódem.
class SharingScreen extends ConsumerWidget {
  const SharingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(sharingControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.sharingTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              e is SharingException
                  ? sharingFailureText(l, e.failure)
                  : l.commonLoadFailed,
            ),
            if (e is SharingException &&
                (e.failure == SharingFailure.offline ||
                    e.failure == SharingFailure.failed))
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => ref.invalidate(sharingControllerProvider),
                  child: Text(l.weatherRetry),
                ),
              ),
          ],
        ),
        data: (s) => ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l.sharingIntro),
            ),
            if (!s.onServer)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(l.sharingNotSynced),
              ),
            if (s.members.isNotEmpty) ...[
              _Header(l.sharingMembers),
              for (final m in s.members) _MemberTile(member: m, state: s),
            ],
            if (s.onServer && s.isOwner) _InviteSection(state: s),
            const Divider(height: 32),
            const _JoinSection(),
            if (s.myRole != null && s.myRole != GardenRole.owner) ...[
              const Divider(height: 32),
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  l.sharingLeave,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () => _leave(context, ref),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _leave(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!await _confirm(
      context,
      title: l.sharingLeaveTitle,
      body: l.sharingLeaveBody,
      action: l.sharingLeaveConfirm,
    )) {
      return;
    }
    try {
      await ref
          .read(sharingControllerProvider.notifier)
          .leave(l.sharingNewGardenName);
    } on SharingException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(sharingFailureText(l, e.failure))),
      );
    }
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}

class _MemberTile extends ConsumerWidget {
  const _MemberTile({required this.member, required this.state});

  final GardenMember member;
  final SharingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final me = member.userId == state.myId;
    final canRemove =
        state.myRole == GardenRole.owner && member.role != GardenRole.owner;
    return ListTile(
      leading: Icon(
        member.role == GardenRole.owner
            ? Icons.workspace_premium_outlined
            : Icons.person_outline,
      ),
      title: Text(me ? l.sharingYou(member.label) : member.label),
      subtitle: Text(_roleText(l, member.role)),
      trailing: canRemove
          ? TextButton(
              onPressed: () => _remove(context, ref),
              child: Text(l.sharingRemove),
            )
          : null,
    );
  }

  Future<void> _remove(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!await _confirm(
      context,
      title: l.sharingRemoveTitle,
      body: l.sharingRemoveBody(member.label),
      action: l.sharingRemove,
    )) {
      return;
    }
    try {
      await ref.read(sharingControllerProvider.notifier).remove(member.userId);
      messenger.showSnackBar(SnackBar(content: Text(l.sharingRemoved)));
    } on SharingException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(sharingFailureText(l, e.failure))),
      );
    }
  }
}

class _InviteSection extends ConsumerStatefulWidget {
  const _InviteSection({required this.state});

  final SharingState state;

  @override
  ConsumerState<_InviteSection> createState() => _InviteSectionState();
}

class _InviteSectionState extends ConsumerState<_InviteSection> {
  bool _busy = false;

  Future<void> _create() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(sharingControllerProvider.notifier).invite();
    } on SharingException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(sharingFailureText(l, e.failure))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share(GardenInvite invite) async {
    final l = AppLocalizations.of(context);
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        text: l.sharingInviteShareText(
          invite.display,
          formatDate(invite.expiresAt),
        ),
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final invite = widget.state.invite;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.sharingInviteHelp, style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          if (invite == null)
            FilledButton.icon(
              onPressed: _busy ? null : _create,
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: Text(l.sharingInvite),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.sharingInviteCode,
                      style: theme.textTheme.labelLarge,
                    ),
                    SelectableText(
                      invite.display,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        letterSpacing: 2,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(l.sharingInviteValid(formatDate(invite.expiresAt))),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: () => _share(invite),
                          icon: const Icon(Icons.share_outlined),
                          label: Text(l.sharingInviteShare),
                        ),
                        IconButton(
                          tooltip: MaterialLocalizations.of(
                            context,
                          ).copyButtonLabel,
                          icon: const Icon(Icons.copy),
                          onPressed: () => Clipboard.setData(
                            ClipboardData(text: invite.display),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _JoinSection extends ConsumerStatefulWidget {
  const _JoinSection();

  @override
  ConsumerState<_JoinSection> createState() => _JoinSectionState();
}

class _JoinSectionState extends ConsumerState<_JoinSection> {
  final _code = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (normalizeInviteCode(_code.text) == null) {
      setState(() => _error = l.sharingJoinInvalid);
      return;
    }
    setState(() => _error = null);
    if (!await _confirm(
      context,
      title: l.sharingJoinConfirmTitle,
      body: l.sharingJoinConfirmBody,
      action: l.sharingJoinConfirm,
    )) {
      return;
    }
    setState(() => _busy = true);
    try {
      final result = await ref
          .read(sharingControllerProvider.notifier)
          .join(_code.text);
      if (result == JoinResult.alreadyHere) {
        messenger.showSnackBar(SnackBar(content: Text(l.sharingJoinAlready)));
      }
    } on SharingException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(sharingFailureText(l, e.failure))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.sharingJoin, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(l.sharingJoinHelp),
          const SizedBox(height: 8),
          TextField(
            controller: _code,
            textCapitalization: TextCapitalization.characters,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: l.sharingJoinCode,
              hintText: 'ABCD-EFGH',
              errorText: _error,
            ),
            onSubmitted: (_) => _join(),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _busy ? null : _join,
            child: Text(l.sharingJoinConfirm),
          ),
        ],
      ),
    );
  }
}
