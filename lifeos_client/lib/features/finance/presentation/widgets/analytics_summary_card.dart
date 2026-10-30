import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/extension/extensions.dart';
import '../../../../core/ui/ui.dart';
import '../../data/models/analytics_summary_dto.dart';
import '../providers/amount_visibility_provider.dart';

/// Income, expenses and net for the selected period.
class AnalyticsSummaryCard extends StatelessWidget {
  final AnalyticsSummaryDto analytics;

  const AnalyticsSummaryCard({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    final semantic = context.semantic;
    final visible =
        context.watch<AmountVisibilityProvider?>()?.isVisible ?? true;
    String money(double value) => visible
        ? '${value.toMoneyFormat()} ${analytics.currencyIcon}'
        : '•••• ${analytics.currencyIcon}';

    return StatGrid(
      minTileWidth: 150,
      children: [
        StatTile(
          label: 'Income',
          value: money(analytics.totalIncome),
          icon: HugeIcons.strokeRoundedArrowDownLeft01,
          color: semantic.success,
        ),
        StatTile(
          label: 'Expenses',
          value: money(analytics.totalExpense.abs()),
          icon: HugeIcons.strokeRoundedArrowUpRight01,
          color: semantic.danger,
        ),
        StatTile(
          label: 'Net',
          value: money(analytics.netAmount),
          icon: HugeIcons.strokeRoundedBalanceScale,
          color: semantic.amount(analytics.netAmount),
        ),
      ],
    );
  }
}
