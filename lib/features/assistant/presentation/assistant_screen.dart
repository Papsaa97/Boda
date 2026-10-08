import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../activity/presentation/screens/activity_form_screen.dart';
import '../domain/assistant_backend.dart';
import '../domain/assistant_message.dart';
import '../domain/safety_check.dart';
import '../../settings/presentation/settings_controller.dart';
import 'assistant_controller.dart';

/// Záložka Bóďa: rozhovor s asistentem (kap. 5.2).
class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // Dotazy uložené bez připojení zkusit poslat při otevření (FR-B7).
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(assistantControllerProvider.future);
      if (mounted) {
        await ref.read(assistantControllerProvider.notifier).retryPending();
      }
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  Future<void> _ask(String text) async {
    if (text.trim().isEmpty) return;
    _input.clear();
    _scrollToEnd();
    await ref.read(assistantControllerProvider.notifier).ask(text);
    if (!mounted) return;
    _reportFailure();
    _scrollToEnd();
  }

  void _reportFailure() {
    if (!ref.read(assistantControllerProvider).hasError) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).assistantSaveFailed)),
    );
  }

  Future<void> _menu(String action) async {
    final controller = ref.read(assistantControllerProvider.notifier);
    if (action == 'new') {
      controller.newConversation();
      return;
    }
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.assistantDeleteConfirmTitle),
        content: Text(l.assistantDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.assistantDeleteConversation),
          ),
        ],
      ),
    );
    if (ok == true) {
      await controller.deleteConversation();
      if (mounted) _reportFailure();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(assistantControllerProvider);
    final isDemo = ref.watch(assistantBackendProvider).isDemo;
    final access = ref.watch(assistantAccessProvider);
    final conversation = async.value;
    final sending = conversation?.sending ?? false;
    final usage = conversation?.usage;
    final pending = conversation?.pending.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.assistantTitle),
        actions: [
          PopupMenuButton<String>(
            onSelected: _menu,
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'new',
                enabled: conversation?.thread != null && !sending,
                child: Text(l.assistantNewConversation),
              ),
              PopupMenuItem(
                value: 'delete',
                enabled: conversation?.thread != null && !sending,
                child: Text(l.assistantDeleteConversation),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (isDemo)
            switch (access) {
              AssistantAccess.noConsent => const _ConsentCard(),
              AssistantAccess.signedOut => const _DemoBanner(signIn: true),
              _ => const _DemoBanner(),
            },
          if (usage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l.assistantUsage(usage.used, usage.limit),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          if (pending > 0)
            ListTile(
              leading: const Icon(Icons.cloud_off_outlined),
              title: Text(l.assistantPendingBanner(pending)),
              trailing: TextButton(
                onPressed: sending
                    ? null
                    : () => ref
                          .read(assistantControllerProvider.notifier)
                          .retryPending(),
                child: Text(l.assistantSendPending),
              ),
            ),
          Expanded(
            child: async.when(
              skipError: true,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Center(child: Text(l.commonErrorWithDetail('$error'))),
              data: (c) => c.messages.isEmpty
                  ? _EmptyState(onAsk: _ask)
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      itemCount: c.messages.length + (c.sending ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (i == c.messages.length) {
                          return const _Thinking();
                        }
                        final m = c.messages[i];
                        return m.isUser
                            ? _UserBubble(message: m)
                            : _AnswerBubble(message: m);
                      },
                    ),
            ),
          ),
          if (sending) const LinearProgressIndicator(minHeight: 2),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 5,
                      maxLength: maxQuestionLength,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: l.assistantInputHint,
                        counterText: '',
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: sending ? null : _ask,
                    ),
                  ),
                  IconButton(
                    tooltip: l.assistantSend,
                    onPressed: sending ? null : () => _ask(_input.text),
                    icon: const Icon(Icons.send),
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

class _DemoBanner extends StatelessWidget {
  const _DemoBanner({this.signIn = false});

  /// Backend je k dispozici, chybí jen přihlášení.
  final bool signIn;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: scheme.tertiaryContainer,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Icon(Icons.science_outlined, color: scheme.onTertiaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              signIn
                  ? AppLocalizations.of(context).assistantDemoBannerSignIn
                  : AppLocalizations.of(context).assistantDemoBanner,
              style: TextStyle(color: scheme.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

/// Souhlas se zpracováním dotazů před prvním odesláním na server.
class _ConsentCard extends ConsumerWidget {
  const _ConsentCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    // Při velkém písmu se karta posouvá a nevytlačí rozhovor z obrazovky.
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.45,
      ),
      child: Card(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        color: scheme.secondaryContainer,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.assistantConsentTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(l.assistantConsentBody),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref
                    .read(settingsControllerProvider.notifier)
                    .update(
                      (s) => s.copyWith(
                        aiConsentAt: () => ref.read(clockProvider)(),
                      ),
                    ),
                child: Text(l.assistantConsentAgree),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAsk});

  final ValueChanged<String> onAsk;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Icon(Icons.eco_outlined, size: 48, color: theme.colorScheme.primary),
        const SizedBox(height: 12),
        Text(
          l.assistantEmptyTitle,
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(l.assistantEmptyBody, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        for (final s in [
          l.assistantSuggestionDose,
          l.assistantSuggestionWeek,
          l.assistantSuggestionStock,
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ActionChip(label: Text(s), onPressed: () => onAsk(s)),
          ),
      ],
    );
  }
}

class _Thinking extends StatelessWidget {
  const _Thinking();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      AppLocalizations.of(context).assistantThinking,
      style: Theme.of(context).textTheme.bodySmall,
    ),
  );
}

String _failureText(AppLocalizations l, MessageMeta meta) =>
    switch (meta.failure) {
      AssistantFailureKind.notSignedIn => l.assistantFailureNotSignedIn,
      AssistantFailureKind.limitReached => l.assistantFailureLimit(
        meta.usage?.limit ?? 0,
      ),
      AssistantFailureKind.notConfigured => l.assistantFailureNotConfigured,
      AssistantFailureKind.offline => l.assistantStatusPending,
      _ => l.assistantFailureUpstream,
    };

class _UserBubble extends ConsumerWidget {
  const _UserBubble({required this.message});

  final AssistantMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final small = Theme.of(context).textTheme.bodySmall;
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.85,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.text,
                style: TextStyle(color: scheme.onPrimaryContainer),
              ),
            ),
            if (message.status == MessageStatus.pending)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.schedule, size: 16),
                  const SizedBox(width: 4),
                  Flexible(child: Text(l.assistantStatusPending, style: small)),
                ],
              ),
            if (message.status == MessageStatus.failed) ...[
              Text(
                _failureText(l, message.meta),
                style: small?.copyWith(color: scheme.error),
                textAlign: TextAlign.end,
              ),
              if (message.meta.failure != AssistantFailureKind.limitReached)
                TextButton(
                  onPressed: () => ref
                      .read(assistantControllerProvider.notifier)
                      .retry(message.id),
                  child: Text(l.assistantRetry),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnswerBubble extends ConsumerStatefulWidget {
  const _AnswerBubble({required this.message});

  final AssistantMessage message;

  @override
  ConsumerState<_AnswerBubble> createState() => _AnswerBubbleState();
}

class _AnswerBubbleState extends ConsumerState<_AnswerBubble> {
  /// Akce, které uživatel v téhle odpovědi už uložil.
  final _done = <AssistantAction>{};

  Future<void> _apply(AssistantAction action) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final controller = ref.read(assistantControllerProvider.notifier);
    switch (action) {
      case ActivityAction():
        final saved = await Navigator.of(context).push<Object?>(
          MaterialPageRoute(
            builder: (_) => ActivityFormScreen(
              draft: ActivityDraft(
                title: action.title,
                type: action.type,
                zoneId: action.zoneId,
              ),
            ),
          ),
        );
        if (saved != null && mounted) setState(() => _done.add(action));
        return;
      case TaskAction():
        try {
          await controller.createTask(action);
          if (!mounted) return;
          setState(() => _done.add(action));
          messenger.showSnackBar(
            SnackBar(content: Text(l.assistantActionTaskDone)),
          );
        } on Exception {
          messenger.showSnackBar(
            SnackBar(content: Text(l.assistantActionFailed)),
          );
        }
      case ShoppingAction():
        try {
          await controller.addToShopping(action);
          if (!mounted) return;
          setState(() => _done.add(action));
          messenger.showSnackBar(
            SnackBar(content: Text(l.assistantActionShoppingDone)),
          );
        } on Exception {
          messenger.showSnackBar(
            SnackBar(content: Text(l.assistantActionFailed)),
          );
        }
    }
  }

  Future<void> _feedback(AnswerFeedback value) async {
    final controller = ref.read(assistantControllerProvider.notifier);
    final message = widget.message;
    if (message.feedback == value) {
      await controller.setFeedback(message.id, null);
      return;
    }
    String? comment;
    if (value == AnswerFeedback.down) {
      comment = await showDialog<String>(
        context: context,
        builder: (_) => const _CommentDialog(),
      );
      if (comment == null || !mounted) return;
    }
    await controller.setFeedback(message.id, value, comment: comment);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).assistantFeedbackThanks),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final message = widget.message;
    final meta = message.meta;
    // Material místo dekorace: rozbalovací „Z čeho vycházím“ kreslí
    // odezvu na dotyk na nejbližší Material.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (meta.demo)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    l.assistantDemoLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.tertiary,
                    ),
                  ),
                ),
              SelectableText(message.text),
              for (final w in meta.warnings) _WarningCard(warning: w),
              if (meta.context case final summary?)
                Theme(
                  data: theme.copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(bottom: 8),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    leading: const Icon(Icons.info_outline),
                    title: Text(l.assistantSourcesTitle),
                    children: [
                      if (summary.zoneNames.isNotEmpty)
                        Text(
                          l.assistantSourcesZones(summary.zoneNames.join(', ')),
                        ),
                      Text(
                        l.assistantSourcesCounts(
                          summary.activityCount,
                          summary.taskCount,
                          summary.inventoryCount,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (summary.calculations.isEmpty)
                        Text(l.assistantSourcesNone)
                      else ...[
                        Text(
                          l.assistantSourcesCalculations,
                          style: theme.textTheme.titleSmall,
                        ),
                        for (final c in summary.calculations)
                          Text(
                            '• ${l.assistantCalculationLine(c.label, c.result, c.source)}',
                          ),
                      ],
                    ],
                  ),
                ),
              if (meta.actions.isNotEmpty) ...[
                const SizedBox(height: 4),
                for (final a in meta.actions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: OutlinedButton.icon(
                      onPressed: _done.contains(a) ? null : () => _apply(a),
                      icon: Icon(
                        _done.contains(a)
                            ? Icons.check
                            : switch (a) {
                                TaskAction() => Icons.add_task,
                                ShoppingAction() =>
                                  Icons.shopping_cart_outlined,
                                ActivityAction() => Icons.edit_note,
                              },
                      ),
                      label: Text(switch (a) {
                        TaskAction(:final title) => l.assistantActionTask(
                          title,
                        ),
                        ShoppingAction(:final name) =>
                          l.assistantActionShopping(name),
                        ActivityAction(:final title) =>
                          l.assistantActionActivity(title),
                      }, textAlign: TextAlign.start),
                    ),
                  ),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: l.assistantFeedbackUp,
                    isSelected: message.feedback == AnswerFeedback.up,
                    icon: const Icon(Icons.thumb_up_outlined),
                    selectedIcon: const Icon(Icons.thumb_up),
                    onPressed: () => _feedback(AnswerFeedback.up),
                  ),
                  IconButton(
                    tooltip: l.assistantFeedbackDown,
                    isSelected: message.feedback == AnswerFeedback.down,
                    icon: const Icon(Icons.thumb_down_outlined),
                    selectedIcon: const Icon(Icons.thumb_down),
                    onPressed: () => _feedback(AnswerFeedback.down),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({required this.warning});

  final SafetyWarning warning;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber, color: scheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(switch (warning) {
              UnverifiedDose(:final text) => l.assistantWarningUnverifiedDose(
                text,
              ),
              ProfessionalOnly(:final product) =>
                l.assistantWarningProfessionalOnly(product),
              MissingPhi(:final product) => l.assistantWarningMissingPhi(
                product,
              ),
            }, style: TextStyle(color: scheme.onErrorContainer)),
          ),
        ],
      ),
    );
  }
}

class _CommentDialog extends StatefulWidget {
  const _CommentDialog();

  @override
  State<_CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends State<_CommentDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.assistantFeedbackCommentTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 3,
        maxLength: 500,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(hintText: l.assistantFeedbackCommentHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(l.commonSave),
        ),
      ],
    );
  }
}
