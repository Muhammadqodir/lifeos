import 'package:flutter/services.dart' show TextInputAction;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos_client/core/widgets/date_select.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/habits_list_bloc.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/habits_list_event.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/log_entry_bloc.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/log_entry_event.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/log_entry_state.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:lifeos_client/core/ui/ui.dart';

class LogEntrySheet extends StatefulWidget {
  final String habitId;

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
    return BlocConsumer<LogEntryBloc, LogEntryState>(
      listener: (context, state) {
        if (state is LogEntrySuccess) {
          // Refresh the habits list
          context.read<HabitsListBloc>().add(const HabitsListRefreshed());

          AppToast.success(context, 'Habit entry logged');

          Navigator.of(context).pop();
        } else if (state is LogEntryFailure) {
          AppToast.error(
            context,
            'Something went wrong',
            message: state.message,
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state is LogEntryLoading;

        return FormSheet(
          title: 'Check in',
          description: 'Log this habit for a day, with an optional note.',
          submit: FormSubmitButton(
            label: 'Log entry',
            loadingLabel: 'Saving…',
            loading: isSubmitting,
            onPressed: () => _submitEntry(context),
          ),
          children: [
            AppFormField(
              label: 'Date',
              hint: 'Leave empty for today.',
              child: DateSelect(
                onDateChanged: (date) => setState(() => _selectedDate = date),
              ),
            ),
            AppFormField(
              label: 'Note',
              optional: true,
              child: TextField(
                controller: _noteController,
                placeholder: const Text('How did it go?'),
                enabled: !isSubmitting,
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
            ),
          ],
        );
      },
    );
  }
}
