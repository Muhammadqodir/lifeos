import 'package:flutter/cupertino.dart'
    show
        CupertinoDatePicker,
        CupertinoDatePickerMode,
        CupertinoTextThemeData,
        CupertinoTheme,
        CupertinoThemeData;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../bloc/sleep_entry_bloc.dart';
import '../bloc/sleep_entry_event.dart';
import '../bloc/sleep_entry_state.dart';
import '../bloc/health_home_bloc.dart';
import '../bloc/health_home_event.dart';
import 'package:lifeos_client/core/ui/ui.dart';
import 'package:lifeos_client/core/widgets/selectable_group.dart';

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
    return BlocConsumer<SleepEntryBloc, SleepEntryState>(
      listener: (context, state) {
        if (state is SleepEntrySuccess) {
          // Refresh the health home data
          context.read<HealthHomeBloc>().add(const HealthHomeRefreshed());

          AppToast.success(context, 'Entry created');
          Navigator.of(context).pop();
        } else if (state is SleepEntryFailure) {
          // Show error
          AppToast.error(
            context,
            'Something went wrong',
            message: state.message.contains('already have')
                ? 'You already logged sleep for this night.'
                : "Couldn't save the entry. Try again.",
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is SleepEntryLoading;

        return FormSheet(
          title: 'Log sleep',
          description: 'When you fell asleep, woke up, and how it felt.',
          submit: FormSubmitButton(
            label: 'Save sleep',
            loadingLabel: 'Saving…',
            loading: isLoading,
            onPressed: () => _submitSleepEntry(context),
          ),
          children: [
            AppFormField(
              label: 'Night of',
              child: DatePicker(
                value: _selectedDate,
                mode: PromptMode.dialog,
                dialogTitle: const Text('Night of'),
                stateBuilder: (date) => date.isAfter(DateTime.now())
                    ? DateState.disabled
                    : DateState.enabled,
                onChanged: (value) {
                  if (value != null) setState(() => _selectedDate = value);
                },
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppFormField(
                    label: 'Fell asleep',
                    child: _timeWheel(
                      context,
                      _sleepStartTime,
                      (value) => setState(() => _sleepStartTime = value),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppFormField(
                    label: 'Woke up',
                    child: _timeWheel(
                      context,
                      _sleepEndTime,
                      (value) => setState(() => _sleepEndTime = value),
                    ),
                  ),
                ),
              ],
            ),
            AppFormField(
              label: 'Quality',
              hint: '1 is restless, 5 is deeply rested.',
              child: SelectableGroup<int>(
                initialValue: _quality,
                options: [
                  for (var q = 1; q <= 5; q++)
                    SelectableGroupOption(value: q, widget: Text('$q')),
                ],
                onChanged: (value) => setState(() => _quality = value),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _timeWheel(
    BuildContext context,
    DateTime value,
    ValueChanged<DateTime> onChanged,
  ) {
    final theme = Theme.of(context);
    final style = context.text.itemTitle;
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withValues(alpha: 0.5),
        borderRadius: theme.controlRadius,
      ),
      child: CupertinoTheme(
        data: CupertinoThemeData(
          brightness: theme.brightness,
          textTheme: CupertinoTextThemeData(
            dateTimePickerTextStyle: style,
            pickerTextStyle: style,
          ),
        ),
        child: CupertinoDatePicker(
          initialDateTime: value,
          use24hFormat: true,
          mode: CupertinoDatePickerMode.time,
          onDateTimeChanged: onChanged,
        ),
      ),
    );
  }
}
