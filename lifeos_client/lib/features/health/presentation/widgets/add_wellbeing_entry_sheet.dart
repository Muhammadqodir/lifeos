import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../bloc/wellbeing_entry_bloc.dart';
import '../bloc/wellbeing_entry_event.dart';
import '../bloc/wellbeing_entry_state.dart';
import '../bloc/health_home_bloc.dart';
import '../bloc/health_home_event.dart';
import 'package:lifeos_client/core/ui/ui.dart';
import 'package:lifeos_client/core/widgets/selectable_group.dart';

class AddWellbeingEntrySheet extends StatefulWidget {
  const AddWellbeingEntrySheet({super.key});

  @override
  State<AddWellbeingEntrySheet> createState() => _AddWellbeingEntrySheetState();
}

class _AddWellbeingEntrySheetState extends State<AddWellbeingEntrySheet> {
  DateTime _selectedDate = DateTime.now();
  int _energy = 3; // Default energy (1-5 scale)
  int _stress = 3; // Default stress (1-5 scale)

  void _submitWellbeingEntry(BuildContext context) {
    final dateStr = _selectedDate.toIso8601String().split('T')[0];

    context.read<WellbeingEntryBloc>().add(
      CreateWellbeingEntry(date: dateStr, energy: _energy, stress: _stress),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WellbeingEntryBloc, WellbeingEntryState>(
      listener: (context, state) {
        if (state is WellbeingEntrySuccess) {
          // Refresh the health home data
          context.read<HealthHomeBloc>().add(const HealthHomeRefreshed());

          AppToast.success(context, 'Entry created');
          Navigator.of(context).pop();
        } else if (state is WellbeingEntryFailure) {
          AppToast.error(
            context,
            'Something went wrong',
            message: state.message,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is WellbeingEntryLoading;

        return FormSheet(
          title: 'Log wellbeing',
          description: 'A quick check-in on energy and stress.',
          submit: FormSubmitButton(
            label: 'Save check-in',
            loadingLabel: 'Saving…',
            loading: isLoading,
            onPressed: () => _submitWellbeingEntry(context),
          ),
          children: [
            AppFormField(
              label: 'Date',
              child: DatePicker(
                value: _selectedDate,
                mode: PromptMode.dialog,
                dialogTitle: const Text('Date'),
                stateBuilder: (date) => date.isAfter(DateTime.now())
                    ? DateState.disabled
                    : DateState.enabled,
                onChanged: (value) {
                  if (value != null) setState(() => _selectedDate = value);
                },
              ),
            ),
            AppFormField(
              label: 'Energy',
              hint: _getEnergyLabel(_energy),
              child: _scale(_energy, (v) => setState(() => _energy = v)),
            ),
            AppFormField(
              label: 'Stress',
              hint: _getStressLabel(_stress),
              child: _scale(_stress, (v) => setState(() => _stress = v)),
            ),
          ],
        );
      },
    );
  }

  /// 1–5 rating as a segmented control.
  Widget _scale(int value, ValueChanged<int> onChanged) {
    return SelectableGroup<int>(
      value: value,
      initialValue: value,
      options: [
        for (var level = 1; level <= 5; level++)
          SelectableGroupOption(value: level, widget: Text('$level')),
      ],
      onChanged: onChanged,
    );
  }

  String _getEnergyLabel(int energy) {
    switch (energy) {
      case 1:
        return 'Very Low';
      case 2:
        return 'Low';
      case 3:
        return 'Medium';
      case 4:
        return 'High';
      case 5:
        return 'Very High';
      default:
        return 'Medium';
    }
  }

  String _getStressLabel(int stress) {
    switch (stress) {
      case 1:
        return 'Very Low';
      case 2:
        return 'Low';
      case 3:
        return 'Medium';
      case 4:
        return 'High';
      case 5:
        return 'Very High';
      default:
        return 'Medium';
    }
  }
}
