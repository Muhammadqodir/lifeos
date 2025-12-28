import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../injection.dart';
import '../../../navigation/presentation/widgets/custom_app_bar.dart';
import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_event.dart';
import '../bloc/analytics_state.dart';
import '../widgets/pie_chart_section.dart';
import '../widgets/analytics_date_picker.dart';
import '../widgets/analytics_summary_card.dart';
import '../widgets/analytics_loading_skeleton.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  late DateTime _dateFrom;
  late DateTime _dateTo;
  final GlobalKey<RefreshTriggerState> _refreshTriggerKey =
      GlobalKey<RefreshTriggerState>();

  @override
  void initState() {
    super.initState();
    // Default to this month
    final now = DateTime.now();
    _dateFrom = DateTime(now.year, now.month, 1); // First day of current month
    _dateTo = DateTime(now.year, now.month + 1, 0); // Last day of current month
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<AnalyticsBloc>()
            ..add(AnalyticsLoadData(dateFrom: _dateFrom, dateTo: _dateTo)),
      child: _AnalyticsPageContent(
        onDateRangeChanged: _onDateRangeChanged,
        refreshTriggerKey: _refreshTriggerKey,
      ),
    );
  }

  void _onDateRangeChanged(DateTime from, DateTime to) {
    setState(() {
      _dateFrom = from;
      _dateTo = to;
    });
    context.read<AnalyticsBloc>().add(
      AnalyticsDateRangeChanged(dateFrom: from, dateTo: to),
    );
  }
}

class _AnalyticsPageContent extends StatelessWidget {
  final Function(DateTime, DateTime) onDateRangeChanged;
  final GlobalKey<RefreshTriggerState> refreshTriggerKey;

  const _AnalyticsPageContent({
    required this.onDateRangeChanged,
    required this.refreshTriggerKey,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<AnalyticsBloc, AnalyticsState>(
      listener: (context, state) {
        // Handle state changes if needed
      },
      child: Scaffold(
        headers: [
          CustomAppBar(
            title: "Analytics",
            rightActions: [
              AppBarAction(
                icon: HugeIcons.strokeRoundedRefresh,
                tooltip: 'Refresh',
                onTap: () {
                  context.read<AnalyticsBloc>().add(const AnalyticsRefreshed());
                },
              ),
            ],
          ),
        ],
        child: RefreshTrigger(
          key: refreshTriggerKey,
          onRefresh: () async {
            context.read<AnalyticsBloc>().add(const AnalyticsRefreshed());
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
            builder: (context, state) {
              if (state is AnalyticsLoading || state is AnalyticsInitial) {
                return const AnalyticsLoadingSkeleton();
              }

              if (state is AnalyticsFailure) {
                return _buildErrorState(context, state);
              }

              if (state is AnalyticsEmpty) {
                return _buildEmptyState(context);
              }

              if (state is AnalyticsSuccess) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Range Selector
                        AnalyticsDatePicker(
                          dateFrom: state.dateFrom,
                          dateTo: state.dateTo,
                          onDateRangeChanged: onDateRangeChanged,
                        ),
                        const SizedBox(height: 20),

                        // Summary Cards
                        AnalyticsSummaryCard(analytics: state.analytics),
                        const SizedBox(height: 20),

                        // Income by Category Pie Chart
                        if (state.analytics.incomeByCategory.isNotEmpty) ...[
                          Text(
                            'Income by Category',
                            style: Theme.of(context).typography.large,
                          ),
                          const SizedBox(height: 12),
                          PieChartSection(
                            title: 'Income Distribution',
                            categories: state.analytics.incomeByCategory,
                            totalAmount: state.analytics.totalIncome,
                            currencyIcon: state.analytics.currencyIcon,
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Expense by Category Pie Chart
                        if (state.analytics.expenseByCategory.isNotEmpty) ...[
                          Text(
                            'Expense by Category',
                            style: Theme.of(context).typography.large,
                          ),
                          const SizedBox(height: 12),
                          PieChartSection(
                            title: 'Expense Distribution',
                            categories: state.analytics.expenseByCategory,
                            totalAmount: state.analytics.totalExpense,
                            currencyIcon: state.analytics.currencyIcon,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, AnalyticsFailure state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HugeIcon(icon: HugeIcons.strokeRoundedAlert02, size: 48),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).typography.large,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: Theme.of(context).typography.base,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              onPressed: () {
                context.read<AnalyticsBloc>().add(const AnalyticsRetried());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HugeIcon(icon: HugeIcons.strokeRoundedPieChart, size: 48),
            const SizedBox(height: 16),
            Text(
              'No data available',
              style: Theme.of(context).typography.large,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add some transactions to see analytics',
              style: Theme.of(context).typography.base,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
