import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/formatting/dates.dart';
import '../../../core/telemetry/telemetry.dart';
import '../../../l10n/app_localizations.dart';
import '../../account/presentation/account_screen.dart';
import '../domain/premium.dart';
import 'premium_controller.dart';

/// Popisek tarifu do Nastavení.
String planLabel(
  AppLocalizations l,
  AsyncValue<Entitlement> async,
  DateTime now,
) {
  final e = async.value;
  if (e == null) {
    return async.hasError ? l.premiumTileUnknown : l.premiumTileFree;
  }
  if (!e.isPremiumAt(now)) return l.premiumTileFree;
  final until = e.validUntil;
  return until == null
      ? l.premiumTilePremium
      : l.premiumTilePremiumUntil(formatDate(until.toLocal()));
}

/// Nabídka Premium (spec 11.2): srovnání tarifů, ceny a nákup.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  BillingPeriod _period = BillingPeriod.yearly;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    ref.read(analyticsProvider).track(AnalyticsEvent.paywallViewed);
  }

  Future<void> _run(Future<void> Function() op, String success) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    String? message = success;
    try {
      await op();
    } on PurchaseFailure catch (f) {
      message = switch (f.kind) {
        PurchaseFailureKind.cancelled => null,
        PurchaseFailureKind.pending => l.premiumPending,
        PurchaseFailureKind.offline => l.premiumOffline,
        PurchaseFailureKind.notSignedIn => l.premiumSignInFirst,
        PurchaseFailureKind.unavailable => l.premiumNotYet,
        PurchaseFailureKind.unknown => l.premiumFailed,
      };
    } on Exception {
      message = l.premiumFailed;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (message != null) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final now = ref.watch(clockProvider)();
    final purchases = ref.watch(purchaseServiceProvider);
    final user = ref.watch(currentUserProvider).value;
    final entitlement = ref.watch(premiumControllerProvider).value;
    final isPremium = entitlement?.isPremiumAt(now) ?? false;
    final offers = ref.watch(premiumOffersProvider).value ?? const [];
    PremiumOffer? offerFor(BillingPeriod p) =>
        offers.where((o) => o.period == p).firstOrNull;
    final selected = offerFor(_period);
    final trialDays = selected?.trialDays ?? specTrialDays;
    final canBuy =
        purchases.available && user != null && selected != null && !isPremium;

    return Scaffold(
      appBar: AppBar(title: Text(l.premiumTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(l.premiumHeadline, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(l.premiumIntro),
          const SizedBox(height: 8),
          Text(
            isPremium ? l.premiumCurrentPremium : l.premiumCurrentFree,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 16),
          _Comparison(l: l),
          const SizedBox(height: 24),
          if (!isPremium) ...[
            for (final period in BillingPeriod.values)
              _PriceTile(
                period: period,
                price:
                    offerFor(period)?.price ??
                    (period == BillingPeriod.yearly
                        ? specYearlyPrice
                        : specMonthlyPrice),
                selected: _period == period,
                onTap: () => setState(() => _period = period),
              ),
            const SizedBox(height: 8),
            if (!purchases.available)
              _Note(text: l.premiumNotYet)
            else if (user == null) ...[
              _Note(text: l.premiumSignInFirst),
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AccountScreen()),
                ),
                child: Text(l.premiumSignIn),
              ),
            ],
            const SizedBox(height: 8),
            FilledButton(
              onPressed: canBuy && !_busy
                  ? () => _run(
                      () => ref
                          .read(premiumControllerProvider.notifier)
                          .purchase(selected),
                      l.premiumThanks,
                    )
                  : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text('${l.premiumBuy} (${l.premiumTrial(trialDays)})'),
            ),
          ],
          TextButton(
            onPressed: purchases.available && user != null && !_busy
                ? () => _run(
                    () =>
                        ref.read(premiumControllerProvider.notifier).restore(),
                    l.premiumRestored,
                  )
                : null,
            child: Text(l.premiumRestore),
          ),
          if (_busy) const LinearProgressIndicator(),
          const SizedBox(height: 8),
          Text(l.premiumRenewal, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _Comparison extends StatelessWidget {
  const _Comparison({required this.l});

  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final header = theme.textTheme.labelLarge;
    TableRow row(String label, String free, String premium, {TextStyle? s}) =>
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(label, style: s),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(free, style: s, textAlign: TextAlign.center),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(premium, style: s, textAlign: TextAlign.center),
            ),
          ],
        );
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(),
        2: FlexColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder(
        horizontalInside: BorderSide(color: theme.dividerColor),
      ),
      children: [
        row('', l.premiumColumnFree, l.premiumColumnPremium, s: header),
        row(l.premiumRowDiary, l.premiumYes, l.premiumYes),
        row(l.premiumRowGardens, l.premiumFreeGardens, l.premiumUnlimited),
        row(l.premiumRowPhotos, l.premiumFreePhotos, l.premiumUnlimited),
        row(l.premiumRowBoda, l.premiumFreeBoda, l.premiumPremiumBoda),
        row(l.premiumRowV2, l.premiumNo, l.premiumYes),
      ],
    );
  }
}

class _PriceTile extends StatelessWidget {
  const _PriceTile({
    required this.period,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  final BillingPeriod period;
  final String price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final yearly = period == BillingPeriod.yearly;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: ListTile(
        selected: selected,
        onTap: onTap,
        leading: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        ),
        title: Text(yearly ? l.premiumYearly : l.premiumMonthly),
        subtitle: Text(
          yearly ? l.premiumPerYear(price) : l.premiumPerMonth(price),
        ),
        trailing: yearly ? Chip(label: Text(l.premiumBestValue)) : null,
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
