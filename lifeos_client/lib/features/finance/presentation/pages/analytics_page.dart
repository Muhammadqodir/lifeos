import 'package:flutter_bloc/flutter_bloc.dart';
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

  void _onCurrencyChanged(int? value) {
    setState(() {
      _selectedCurrencyId = value;
    });
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
                  Select<int>(
                    value: _selectedCurrencyId,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    itemBuilder: (context, item) {
                      final currency = _currencies.firstWhere(
                        (c) => c.id == item,
                      );
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currency.icon,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            currency.code,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      );
                    },
                    onChanged: (value) {
                      _onCurrencyChanged(value);
                      context.read<AnalyticsBloc>().add(
                        AnalyticsCurrencyChanged(currencyId: value),
                      );
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
                                  Text(
                                    currency.icon,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                ),
              ],
            ),
          ],
          child: _AnalyticsPageContent(onDateRangeChanged: _onDateRangeChanged),
        ),
      ),
    );
  }

  void _onDateRangeChanged(DateTime from, DateTime to) {
    setState(() {
      _dateFrom = from;
      _dateTo = to;
    });
    context.read<AnalyticsBloc>().add(
      AnalyticsDateRangeChanged(
        dateFrom: from,
        dateTo: to,
        currencyId: _selectedCurrencyId,
      ),
    );
  }
}

class _AnalyticsPageContent extends StatelessWidget {
  final Function(DateTime, DateTime) onDateRangeChanged;

  const _AnalyticsPageContent({required this.onDateRangeChanged});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AnalyticsBloc, AnalyticsState>(
      listener: (context, state) {
        // Handle state changes if needed
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
