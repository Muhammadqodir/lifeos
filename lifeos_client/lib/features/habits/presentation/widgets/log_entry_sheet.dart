import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/core/widgets/date_select.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/habits_list_bloc.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/habits_list_event.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/log_entry_bloc.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/log_entry_event.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/log_entry_state.dart';
import 'package:lifeos_client/utils/toast.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class LogEntrySheet extends StatefulWidget {
  final int habitId;

  const LogEntrySheet({super.key, required this.habitId});

  @override
  State<LogEntrySheet> createState() => _LogEntrySheetState();
}

class _LogEntrySheetState extends State<LogEntrySheet> {
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submitEntry(BuildContext context) {
    final dateString = _selectedDate.toIso8601String().split('T')[0];

    context.read<LogEntryBloc>().add(
          LogEntrySubmitted(
            habitId: widget.habitId,
            date: dateString,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<LogEntryBloc, LogEntryState>(
      listener: (context, state) {
        if (state is LogEntrySuccess) {
          // Refresh the habits list
          context.read<HabitsListBloc>().add(const HabitsListRefreshed());

          showToast(
            context: context,
            location: ToastLocation.topCenter,
            builder: (context, overlay) {
              return Utils.buildToast(
                context,
                overlay,
                'Success',
                'Habit entry logged successfully',
              );
            },
          );

          Navigator.of(context).pop();
        } else if (state is LogEntryFailure) {
          showToast(
            context: context,
            location: ToastLocation.topCenter,
            builder: (context, overlay) {
              return Utils.buildToast(
                context,
                overlay,
                'Error',
                state.message,
              );
            },
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state is LogEntryLoading;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Log Habit Entry',
                    style: theme.typography.large.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton.primary(
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedCancel01,
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Date selector
              const Text(
                'Date',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              DateSelect(
                onDateChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Note (optional)
              const Text(
                'Note (Optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                placeholder: const Text('Add a note about this entry...'),
                enabled: !isSubmitting,
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  onPressed: isSubmitting ? null : () => _submitEntry(context),
                  child: isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text('Log Entry'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
