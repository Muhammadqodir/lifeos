import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos_client/utils/toast.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
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
  DateTime _sleepStartTime = DateTime(2001, 7, 30, 22, 30);
  DateTime _sleepEndTime = DateTime(2001, 7, 30, 7, 30);
  int _quality = 3; // Default quality (1-5 scale)

  String _formatDateTime(DateTime date, TimeOfDay time) {
    final dateStr = date.toIso8601String().split('T')[0];
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$dateStr $hour:$minute:00';
  }

  void _submitSleepEntry(BuildContext context) {
    // Check if end time is before start time (overnight sleep)
    final startMinutes = _sleepStartTime.hour * 60 + _sleepStartTime.minute;
    final endMinutes = _sleepEndTime.hour * 60 + _sleepEndTime.minute;
    final isOvernight = endMinutes <= startMinutes;

    final sleepStart = _formatDateTime(
      _selectedDate,
      TimeOfDay(hour: _sleepStartTime.hour, minute: _sleepStartTime.minute),
    );
    // Add 1 day to end date if overnight
    final endDate = isOvernight
        ? _selectedDate.add(const Duration(days: 1))
        : _selectedDate;
    final sleepEnd = _formatDateTime(
      endDate,
      TimeOfDay(hour: _sleepEndTime.hour, minute: _sleepEndTime.minute),
    );
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

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sleep Start Time',
                          style: theme.typography.small.copyWith(
                            fontWeight: FontWeight.w500,
                            color: colorScheme.foreground,
                          ),
                        ),
                        CupertinoTheme(
                          data: CupertinoThemeData(
                            brightness: theme.brightness == Brightness.dark
                                ? Brightness.dark
                                : Brightness.light,
                            textTheme: CupertinoTextThemeData(
                              dateTimePickerTextStyle: theme.typography.small
                                  .copyWith(
                                    color: colorScheme.foreground,
                                    fontWeight: FontWeight.w500,
                                  ),
                              pickerTextStyle: theme.typography.small.copyWith(
                                color: colorScheme.foreground,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          child: SizedBox(
                            height: 130,
                            child: CupertinoDatePicker(
                              initialDateTime: _sleepStartTime,
                              onDateTimeChanged: (value) {
                                setState(() {
                                  _sleepStartTime = value;
                                });
                              },
                              mode: CupertinoDatePickerMode.time,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sleep End Time',
                          style: theme.typography.small.copyWith(
                            fontWeight: FontWeight.w500,
                            color: colorScheme.foreground,
                          ),
                        ),
                        CupertinoTheme(
                          data: CupertinoThemeData(
                            brightness: theme.brightness == Brightness.dark
                                ? Brightness.dark
                                : Brightness.light,
                            textTheme: CupertinoTextThemeData(
                              dateTimePickerTextStyle: theme.typography.small
                                  .copyWith(
                                    color: colorScheme.foreground,
                                    fontWeight: FontWeight.w500,
                                  ),
                              pickerTextStyle: theme.typography.small.copyWith(
                                color: colorScheme.foreground,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          child: SizedBox(
                            height: 130,
                            child: CupertinoDatePicker(
                              initialDateTime: _sleepEndTime,
                              onDateTimeChanged: (value) {
                                setState(() {
                                  _sleepEndTime = value;
                                });
                              },
                              mode: CupertinoDatePickerMode.time,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: PrimaryButton(
                      onPressed: !isLoading
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
