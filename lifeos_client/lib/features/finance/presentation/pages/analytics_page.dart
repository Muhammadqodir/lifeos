import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../injection.dart';
import '../../data/models/currency_dto.dart';
import '../../domain/repositories/finance_repository.dart';
import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_event.dart';
import '../bloc/analytics_state.dart';
import '../widgets/pie_chart_section.dart';
import '../../../../core/widgets/range_date_picker.dart';
import '../widgets/analytics_summary_card.dart';
import 'package:lifeos_client/core/ui/ui.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  late DateTime _dateFrom;
  late DateTime _dateTo;
  int? _selectedCurrencyId;
  List<CurrencyDto> _currencies = [];
  bool _isLoadingCurrencies = true;
  int? _defaultCurrencyId;

  @override
  void initState() {
    super.initState();
    // Default to this month
    final now = DateTime.now();
    _dateFrom = DateTime(now.year, now.month, 1); // First day of current month
    _dateTo = DateTime(now.year, now.month + 1, 0); // Last day of current month
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    try {
      final repository = getIt<FinanceRepository>();
      final currencies = await repository.getUserCurrencies();
      final settings = await repository.getFinanceSettings();

      setState(() {
        _currencies = currencies;
        _defaultCurrencyId = settings['base_currency_id'] as int?;
        _selectedCurrencyId = _defaultCurrencyId;
        _isLoadingCurrencies = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCurrencies = false;
      });
    }
  }

  void _onCurrencyChanged(int? value, BuildContext context) {
    setState(() {
      _selectedCurrencyId = value;
    });
    context.read<AnalyticsBloc>().add(
      AnalyticsCurrencyChanged(currencyId: value),
    );
  }

  Widget _buildCurrencyDropdown(BuildContext context) {
    return Select<int>(
      value: _selectedCurrencyId,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      itemBuilder: (context, item) {
        final currency = _currencies.firstWhere((c) => c.id == item);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Text(currency.icon, style: const TextStyle(fontSize: 16)),
            // const SizedBox(width: 8),
            Text(currency.code),
          ],
        );
      },
      onChanged: (value) {
        _onCurrencyChanged(value, context);
      },
      placeholder: const Text('Currency'),
      popup: SelectPopup(
        items: SelectItemList(
          children: _currencies
              .map(
                (currency) => SelectItemButton<int>(
                  value: currency.id,
                  child: Row(
                    children: [
                      // Text(currency.icon, style: const TextStyle(fontSize: 18)),
                      // const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(currency.code, style: context.text.label),
                            Text(currency.name, style: context.text.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ).call,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AnalyticsBloc>()
        ..add(
          AnalyticsLoadData(
            dateFrom: _dateFrom,
            dateTo: _dateTo,
            currencyId: _selectedCurrencyId,
          ),
        ),
      child: Builder(
        builder: (context) => Scaffold(
          headers: [
            AppHeader(
              title: 'Analytics',
              actions: [
                if (_isLoadingCurrencies)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: CircularProgressIndicator(size: 18),
                  )
                else
                  _buildCurrencyDropdown(context),
              ],
            ),
          ],
          child: _AnalyticsPageContent(
            initialDateFrom: _dateFrom,
            initialDateTo: _dateTo,
            selectedCurrencyId: _selectedCurrencyId,
          ),
        ),
      ),
    );
  }
}

class _AnalyticsPageContent extends StatefulWidget {
  final DateTime initialDateFrom;
  final DateTime initialDateTo;
  final int? selectedCurrencyId;

  const _AnalyticsPageContent({
    required this.initialDateFrom,
    required this.initialDateTo,
    required this.selectedCurrencyId,
  });

  @override
  State<_AnalyticsPageContent> createState() => _AnalyticsPageContentState();
}

class _AnalyticsPageContentState extends State<_AnalyticsPageContent> {
  @override
  void initState() {
    super.initState();
  }

  void _onDateRangeChanged(DateTime from, DateTime to) {
    context.read<AnalyticsBloc>().add(
      AnalyticsDateRangeChanged(
        dateFrom: from,
        dateTo: to,
        currencyId: widget.selectedCurrencyId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AnalyticsBloc, AnalyticsState>(
      listener: (context, state) {
        // Handle state changes if needed
      },
      child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoading || state is AnalyticsInitial) {
            return const LoadingState(message: 'Loading analytics…');
          }

          if (state is AnalyticsFailure) {
            return ErrorState(
              title: "Couldn't load analytics",
              message: state.message,
              onRetry: () =>
                  context.read<AnalyticsBloc>().add(const AnalyticsRetried()),
            );
          }

          if (state is AnalyticsEmpty) {
            return _buildEmptyState(context, state);
          }

          if (state is AnalyticsSuccess) {
            final analytics = state.analytics;
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.page,
                vertical: AppSpacing.lg,
              ),
              child: ContentWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RangeDatePicker(
                      dateFrom: state.dateFrom,
                      dateTo: state.dateTo,
                      onDateRangeChanged: _onDateRangeChanged,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AnalyticsSummaryCard(analytics: analytics),
                    const SizedBox(height: AppSpacing.md),
                    PieChartSection(
                      title: 'Expenses by category',
                      categories: analytics.expenseByCategory,
                      totalAmount: analytics.totalExpense,
                      currencyIcon: analytics.currencyIcon,
                    ),
                    if (analytics.incomeByCategory.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      PieChartSection(
                        title: 'Income by category',
                        categories: analytics.incomeByCategory,
                        totalAmount: analytics.totalIncome,
                        currencyIcon: analytics.currencyIcon,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AnalyticsEmpty state) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.page,
        vertical: AppSpacing.lg,
      ),
      child: ContentWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RangeDatePicker(
              dateFrom: state.dateFrom,
              dateTo: state.dateTo,
              onDateRangeChanged: _onDateRangeChanged,
            ),
            const Expanded(
              child: EmptyState(
                icon: HugeIcon(icon: HugeIcons.strokeRoundedPieChart),
                title: 'Nothing to analyse yet',
                description:
                    'Add income or expenses in this period to see the breakdown.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
