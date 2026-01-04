import 'package:shadcn_flutter/shadcn_flutter.dart';

class AnalyticsDatePicker extends StatefulWidget {
  final DateTime dateFrom;
  final DateTime dateTo;
  final Function(DateTime, DateTime) onDateRangeChanged;

  const AnalyticsDatePicker({
    super.key,
    required this.dateFrom,
    required this.dateTo,
    required this.onDateRangeChanged,
  });

  @override
  State<AnalyticsDatePicker> createState() => _AnalyticsDatePickerState();
}

class _AnalyticsDatePickerState extends State<AnalyticsDatePicker> {
  late DateTime _dateFrom;
  late DateTime _dateTo;
  DateTimeRange? _value;

  @override
  void initState() {
    super.initState();
    _dateFrom = widget.dateFrom;
    _dateTo = widget.dateTo;
    _value = DateTimeRange(_dateFrom, _dateTo);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Period', style: Theme.of(context).typography.xSmall),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: DateRangePicker(
            value: _value,
            mode: PromptMode.dialog,
            dialogTitle: const Text('Select Date Range'),
            onChanged: (value) {
              setState(() {
                _value = value;
                if (value != null) {
                  _dateFrom = value.start;
                  _dateTo = value.end;
                }
              });
              if (value != null) {
                widget.onDateRangeChanged(_dateFrom, _dateTo);
              }
            },
          ),
        ),
      ],
    );
  }
}
