import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../sharing/presentation/sharing_screen.dart';
import '../../../core/di/providers.dart';
import '../../../core/formatting/dates.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/auth_service.dart';
import 'sync_controller.dart';

/// Účet a synchronizace (spec 5.5, kap. 9): přihlášení kódem z e-mailu,
/// stav synchronizace, převzetí zahrady z účtu, odhlášení, smazání účtu.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final auth = ref.watch(authServiceProvider);
    final user = ref.watch(currentUserProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(l.accountTitle)),
      body: !auth.available
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l.accountUnavailable),
            )
          : user == null
          ? const _SignIn()
          : _SignedIn(user: user),
    );
  }
}

String authErrorText(AppLocalizations l, AuthFailureKind kind) =>
    switch (kind) {
      AuthFailureKind.invalidEmail => l.accountErrorEmail,
      AuthFailureKind.invalidCode => l.accountErrorCode,
      AuthFailureKind.rateLimited => l.accountErrorRate,
      AuthFailureKind.offline => l.accountErrorOffline,
      AuthFailureKind.unknown => l.accountErrorUnknown,
    };

class _SignIn extends ConsumerStatefulWidget {
  const _SignIn();

  @override
  ConsumerState<_SignIn> createState() => _SignInState();
}

class _SignInState extends ConsumerState<_SignIn> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  String? _sentTo;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() op) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final l = AppLocalizations.of(context);
    try {
      await op();
    } on AuthFailure catch (e) {
      _error = authErrorText(l, e.kind);
    } on Exception {
      _error = l.accountErrorUnknown;
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _send() => _run(() async {
    final email = _email.text.trim();
    await ref.read(authServiceProvider).sendCode(email);
    _sentTo = email;
  });

  Future<void> _verify() => _run(
    () => ref.read(authServiceProvider).verifyCode(_sentTo!, _code.text),
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final sentTo = _sentTo;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l.accountIntro),
        const SizedBox(height: 16),
        if (sentTo == null) ...[
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(
              labelText: l.accountEmailLabel,
              errorText: _error,
            ),
            onSubmitted: (_) => _busy ? null : _send(),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _send,
            child: Text(l.accountSendCode),
          ),
        ] else ...[
          Text(l.accountCodeSent(sentTo)),
          const SizedBox(height: 8),
          TextField(
            controller: _code,
            keyboardType: TextInputType.number,
            autofillHints: const [AutofillHints.oneTimeCode],
            decoration: InputDecoration(
              labelText: l.accountCodeLabel,
              errorText: _error,
            ),
            onSubmitted: (_) => _busy ? null : _verify(),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _verify,
            child: Text(l.accountVerify),
          ),
          TextButton(
            onPressed: _busy
                ? null
                : () => setState(() {
                    _sentTo = null;
                    _error = null;
                    _code.clear();
                  }),
            child: Text(l.accountChangeEmail),
          ),
        ],
        if (_busy)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }
}

class _SignedIn extends ConsumerWidget {
  const _SignedIn({required this.user});

  final AccountUser user;

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

  Future<void> _adopt(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    if (!await _confirm(
      context,
      title: l.accountConflictConfirmTitle,
      body: l.accountConflictConfirmBody,
      action: l.accountConflictConfirm,
    )) {
      return;
    }
    await ref.read(syncControllerProvider.notifier).adoptAccountGarden();
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    if (!await _confirm(
      context,
      title: l.accountSignOut,
      body: l.accountSignOutBody,
      action: l.accountSignOut,
    )) {
      return;
    }
    await ref.read(authServiceProvider).signOut();
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!await _confirm(
      context,
      title: l.accountDeleteTitle,
      body: l.accountDeleteBody,
      action: l.accountDeleteConfirm,
    )) {
      return;
    }
    try {
      await ref.read(authServiceProvider).deleteAccount();
      messenger.showSnackBar(SnackBar(content: Text(l.accountDeleted)));
    } on AuthFailure catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(authErrorText(l, e.kind))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final sync = ref.watch(syncControllerProvider);
    final last = sync.lastSyncAt;
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        ListTile(
          leading: const Icon(Icons.account_circle_outlined),
          title: Text(l.accountSignedInAs(user.email ?? '')),
        ),
        if (sync.conflictGardenId != null)
          Card(
            margin: const EdgeInsets.all(16),
            color: scheme.tertiaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.accountConflictTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(l.accountConflictBody),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: sync.running ? null : () => _adopt(context, ref),
                    child: Text(l.accountConflictUse),
                  ),
                ],
              ),
            ),
          ),
        if (sync.lostAccess)
          Card(
            margin: const EdgeInsets.all(16),
            color: scheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.accountLostAccessTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(l.accountLostAccessBody),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: sync.running
                        ? null
                        : () => ref
                              .read(syncControllerProvider.notifier)
                              .startOwnGarden(l.sharingNewGardenName),
                    child: Text(l.accountLostAccessStart),
                  ),
                ],
              ),
            ),
          ),
        ListTile(
          leading: const Icon(Icons.sync),
          title: Text(sync.running ? l.accountSyncRunning : l.accountSyncNow),
          subtitle: Text(switch (sync.problem) {
            SyncProblem.offline => l.accountSyncOffline,
            SyncProblem.failed => l.accountSyncFailed,
            null =>
              last == null
                  ? l.accountSyncNever
                  : l.accountSyncLast(formatDateTime(last)),
          }),
          enabled: !sync.running,
          onTap: () => ref.read(syncControllerProvider.notifier).syncNow(),
        ),
        ListTile(
          leading: const Icon(Icons.group_outlined),
          title: Text(l.sharingTitle),
          subtitle: Text(l.sharingTileSubtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SharingScreen())),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: Text(l.accountSignOut),
          onTap: () => _signOut(context, ref),
        ),
        ListTile(
          leading: Icon(Icons.delete_forever_outlined, color: scheme.error),
          title: Text(l.accountDelete, style: TextStyle(color: scheme.error)),
          onTap: () => _delete(context, ref),
        ),
      ],
    );
  }
}
