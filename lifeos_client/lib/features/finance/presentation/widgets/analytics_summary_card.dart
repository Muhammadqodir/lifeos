import 'package:lifeos_client/features/finance/presentation/widgets/money_text.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../data/models/analytics_summary_dto.dart';

class AnalyticsSummaryCard extends StatelessWidget {
  final AnalyticsSummaryDto analytics;

  const AnalyticsSummaryCard({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: theme.typography.small.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Income', style: theme.typography.xSmall),
                    const SizedBox(height: 4),
                    MoneyText(
                      amount: analytics.totalIncome,
                      currencyCode: analytics.currencyIcon,
                      color: Colors.green.shade600,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Total Expense', style: theme.typography.xSmall),
                    const SizedBox(height: 4),
                    MoneyText(
                      amount: analytics.totalExpense,
                      currencyCode: analytics.currencyIcon,
                      alignment: MainAxisAlignment.end,
                      color: Colors.red.shade600,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.muted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Net Amount',
                  style: theme.typography.small.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                MoneyText(
                  amount: analytics.netAmount,
                  currencyCode: analytics.currencyIcon,
                  color: analytics.netAmount < 0
                      ? Colors.red.shade600
                      : Colors.green.shade600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
