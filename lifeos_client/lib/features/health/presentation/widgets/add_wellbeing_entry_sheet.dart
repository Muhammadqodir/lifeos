import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos_client/utils/toast.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../bloc/wellbeing_entry_bloc.dart';
import '../bloc/wellbeing_entry_event.dart';
import '../bloc/wellbeing_entry_state.dart';
import '../bloc/health_home_bloc.dart';
import '../bloc/health_home_event.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocConsumer<WellbeingEntryBloc, WellbeingEntryState>(
      listener: (context, state) {
        if (state is WellbeingEntrySuccess) {
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
        } else if (state is WellbeingEntryFailure) {
          showToast(
            context: context,
            builder: (ctx, overlay) {
              return Utils.buildToast(ctx, overlay, 'Error', state.message);
            },
            location: ToastLocation.topCenter,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is WellbeingEntryLoading;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
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
                      'Add Wellbeing Entry',
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

              // Energy Level
              Text(
                'Energy Level',
                style: theme.typography.small.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.foreground,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  final level = index + 1;
                  final isSelected = _energy == level;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: index < 4 ? 8 : 0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _energy = level;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.muted,
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.border,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              level.toString(),
                              style: theme.typography.base.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? colorScheme.primaryForeground
                                    : colorScheme.foreground,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                _getEnergyLabel(_energy),
                style: theme.typography.small.copyWith(
                  color: colorScheme.mutedForeground,
                ),
              ),
              const SizedBox(height: 24),

              // Stress Level
              Text(
                'Stress Level',
                style: theme.typography.small.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.foreground,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  final level = index + 1;
                  final isSelected = _stress == level;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: index < 4 ? 8 : 0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _stress = level;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.muted,
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.border,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              level.toString(),
                              style: theme.typography.base.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? colorScheme.primaryForeground
                                    : colorScheme.foreground,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                _getStressLabel(_stress),
                style: theme.typography.small.copyWith(
                  color: colorScheme.mutedForeground,
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: PrimaryButton(
                      onPressed: !isLoading
                          ? () => _submitWellbeingEntry(context)
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
