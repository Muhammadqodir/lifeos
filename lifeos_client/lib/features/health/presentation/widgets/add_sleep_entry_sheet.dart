import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos_client/utils/toast.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../../../core/widgets/time_range_picker.dart';
import '../bloc/sleep_entry_bloc.dart';
import '../bloc/sleep_entry_event.dart';
import '../bloc/sleep_entry_state.dart';
import '../bloc/health_home_bloc.dart';
import '../bloc/health_home_event.dart';

class AddSleepEntrySheet extends StatefulWidget {
  const AddSleepEntrySheet({super.key});

  @override
  State<AddSleepEntrySheet> createState() => _AddSleepEntrySheetState();
}

class _AddSleepEntrySheetState extends State<AddSleepEntrySheet> {
  DateTime _selectedDate = DateTime.now();
  TimeRangeSelection? _selectedTimeRange;
  int _quality = 3; // Default quality (1-5 scale)

  String _formatDateTime(DateTime date, TimeOfDay time) {
    final dateStr = date.toIso8601String().split('T')[0];
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$dateStr $hour:$minute:00';
  }

  void _submitSleepEntry(BuildContext context) {
    if (_selectedTimeRange == null) return;

    // Check if end time is before start time (overnight sleep)
    final startMinutes =
        _selectedTimeRange!.start.hour * 60 + _selectedTimeRange!.start.minute;
    final endMinutes =
        _selectedTimeRange!.end.hour * 60 + _selectedTimeRange!.end.minute;
    final isOvernight = endMinutes <= startMinutes;

    final sleepStart = _formatDateTime(
      _selectedDate,
      _selectedTimeRange!.start,
    );
    // Add 1 day to end date if overnight
    final endDate = isOvernight
        ? _selectedDate.add(const Duration(days: 1))
        : _selectedDate;
    final sleepEnd = _formatDateTime(endDate, _selectedTimeRange!.end);
    final dateStr = _selectedDate.toIso8601String().split('T')[0];

    context.read<SleepEntryBloc>().add(
      CreateSleepEntry(
        date: dateStr,
        sleepStart: sleepStart,
        sleepEnd: sleepEnd,
        quality: _quality,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocConsumer<SleepEntryBloc, SleepEntryState>(
      listener: (context, state) {
        if (state is SleepEntrySuccess) {
          // Refresh the health home data
          context.read<HealthHomeBloc>().add(const HealthHomeRefreshed());

          showToast(
            context: context,
            builder: (ctx, overlay) {
              return Utils.buildToast(
                ctx,
                overlay,
                'Success',
                'Entry created successfully',
              );
            },
            location: ToastLocation.topCenter,
          );
          Navigator.of(context).pop();
        } else if (state is SleepEntryFailure) {
          // Show error
          showToast(
            context: context,
            builder: (ctx, overlay) {
              return Utils.buildToast(
                ctx,
                overlay,
                'Error',
                state.message.contains('already have')
                    ? 'Entry already exists for this date'
                    : 'Failed to create entry',
              );
            },
            location: ToastLocation.topCenter,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is SleepEntryLoading;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Add Sleep Entry',
                      style: theme.typography.large.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.foreground,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Date Picker
              Text(
                'Date',
                style: theme.typography.small.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.foreground,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: DatePicker(
                  value: _selectedDate,
                  mode: PromptMode.dialog,
                  dialogTitle: const Text('Select Date'),
                  stateBuilder: (date) {
                    // if (date.isAfter(DateTime.now())) {
                    //   return DateState.disabled;
                    // }
                    return DateState.enabled;
                  },
                  onChanged: (value) {
                    setState(() {
                      _selectedDate = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Time Range Picker
              Text(
                'Sleep Time',
                style: theme.typography.small.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.foreground,
                ),
              ),
              TimeRangePicker(
                startTime: const TimeOfDay(hour: 0, minute: 0),
                endTime: const TimeOfDay(hour: 24, minute: 0),
                stepMinutes: 30,
                onChanged: (range) {
                  setState(() {
                    _selectedTimeRange = range;
                  });
                },
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: PrimaryButton(
                      onPressed: _selectedTimeRange != null && !isLoading
                          ? () => _submitSleepEntry(context)
                          : null,
                      child: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Add Entry'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
