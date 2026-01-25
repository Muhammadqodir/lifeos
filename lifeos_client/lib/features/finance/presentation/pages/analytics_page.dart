import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos_client/core/widgets/loading_state.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../injection.dart';
import '../../../navigation/presentation/widgets/custom_app_bar.dart';
import '../../data/models/currency_dto.dart';
import '../../domain/repositories/finance_repository.dart';
import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_event.dart';
import '../bloc/analytics_state.dart';
import '../widgets/pie_chart_section.dart';
import '../../../../core/widgets/range_date_picker.dart';
import '../widgets/analytics_summary_card.dart';

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
            Text(currency.code, style: const TextStyle(fontSize: 14)),
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
                            Text(
                              currency.code,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              currency.name,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
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
            CustomAppBar(
              title: "Analytics",
              leftActions: [
                AppBarAction(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
              rightActions: [
                if (_isLoadingCurrencies)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
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
            return const LoadingState(message: 'Loading analytics data...');
          }

          if (state is AnalyticsFailure) {
            return _buildErrorState(context, state);
          }

          if (state is AnalyticsEmpty) {
            return _buildEmptyState(context, state);
          }

          if (state is AnalyticsSuccess) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Range Selector
                    RangeDatePicker(
                      dateFrom: state.dateFrom,
                      dateTo: state.dateTo,
                      onDateRangeChanged: _onDateRangeChanged,
                    ),
                    const SizedBox(height: 20),

                    // Summary Cards
                    AnalyticsSummaryCard(analytics: state.analytics),
                    const SizedBox(height: 20),

                    // Expense by Category Pie Chart
                    if (state.analytics.expenseByCategory.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      PieChartSection(
                        title: 'Expense Distribution',
                        categories: state.analytics.expenseByCategory,
                        totalAmount: state.analytics.totalExpense,
                        currencyIcon: state.analytics.currencyIcon,
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Income by Category Pie Chart
                    if (state.analytics.incomeByCategory.isNotEmpty) ...[
                      PieChartSection(
                        title: 'Income Distribution',
                        categories: state.analytics.incomeByCategory,
                        totalAmount: state.analytics.totalIncome,
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

  Widget _buildEmptyState(BuildContext context, AnalyticsEmpty state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RangeDatePicker(
            dateFrom: state.dateFrom,
            dateTo: state.dateTo,
            onDateRangeChanged: _onDateRangeChanged,
          ),
          const SizedBox(height: 20),
          Expanded(
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
        ],
      ),
    );
  }
}
