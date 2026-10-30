import 'package:flutter/services.dart' show TextInputAction;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos_client/core/widgets/color_selector.dart';
import 'package:lifeos_client/core/widgets/multi_selectable_group.dart';
import 'package:lifeos_client/core/widgets/selectable_group.dart';
import 'package:lifeos_client/core/widgets/time_select.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/create_habit_bloc.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/create_habit_event.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/create_habit_state.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:lifeos_client/core/ui/ui.dart';

class CreateHabitPage extends StatefulWidget {
  const CreateHabitPage({super.key});

  @override
  State<CreateHabitPage> createState() => _CreateHabitPageState();
}

class _CreateHabitPageState extends State<CreateHabitPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ChipEditingController<String> _tagsController = ChipEditingController();

  String _selectedColor = '3b82f6';
  String _selectedFrequency = 'daily';
  List<int> _selectedDays = [];
  List<String> _selectedTags = [];
  TimeOfDay? _selectedTime;
  int? _goalDuration;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_titleController.text.trim().isEmpty) {
      AppToast.error(
        context,
        'Check the form',
        message: 'Enter a habit title.',
      );
      return;
    }

    // Strip FF alpha channel from color if present (backend expects 6-char hex)
    String colorForBackend = _selectedColor;
    if (_selectedColor.length == 8 &&
        _selectedColor.toUpperCase().startsWith('FF')) {
      colorForBackend = _selectedColor.substring(2);
    }

    context.read<CreateHabitBloc>().add(
      CreateHabitSubmitted(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        color: colorForBackend,
        frequency: _selectedFrequency,
        frequencyDays: _selectedDays.isEmpty ? null : _selectedDays,
        reminderTime: _selectedTime != null
            ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
            : null,
        goalDuration: _goalDuration,
        tags: _selectedTags.isEmpty ? null : _selectedTags,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateHabitBloc, CreateHabitState>(
      listener: (context, state) {
        if (state is CreateHabitSuccess) {
          AppToast.success(context, 'Habit created');
          Navigator.of(context).pop(true);
        } else if (state is CreateHabitFailure) {
          AppToast.error(
            context,
            'Something went wrong',
            message: state.message,
          );
        }
      },
      child: BlocBuilder<CreateHabitBloc, CreateHabitState>(
        builder: (context, state) {
          final isSubmitting = state is CreateHabitLoading;

          return Scaffold(
            headers: [AppHeader(title: 'New habit')],
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.page,
                vertical: AppSpacing.lg,
              ),
              child: ContentWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    AppFormField(
                      label: 'Title',
                      child: TextField(
                        controller: _titleController,
                        placeholder: const Text('Morning run'),
                        enabled: !isSubmitting,
                        textInputAction: TextInputAction.next,
                      ),
                    ),

                    // Description
                    AppFormField(
                      label: 'Description',
                      child: TextField(
                        controller: _descriptionController,
                        placeholder: const Text(
                          'Why this habit matters to you',
                        ),
                        enabled: !isSubmitting,
                        maxLines: 3,
                        textInputAction: TextInputAction.newline,
                      ),
                    ),

                    // Color
                    AppFormField(
                      label: 'Colour',
                      child: ColorSelector(
                        initialColor: _selectedColor,
                        onChanged: (color) {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                      ),
                    ),

                    // Frequency
                    AppFormField(
                      label: 'Frequency',
                      child: SelectableGroup<String>(
                        initialValue: _selectedFrequency,
                        options: const [
                          SelectableGroupOption(
                            value: 'daily',
                            widget: Text('Daily'),
                          ),
                          SelectableGroupOption(
                            value: 'weekly',
                            widget: Text('Weekly'),
                          ),
                        ],
                        onChanged: isSubmitting
                            ? (_) {}
                            : (value) {
                                setState(() {
                                  _selectedFrequency = value;
                                  _selectedDays = [];
                                });
                              },
                      ),
                    ),

                    // Days selection for weekly
                    if (_selectedFrequency == 'weekly') ...[
                      AppFormField(
                        label: 'Days',
                        child: MultiSelectableGroup<int>(
                          initialValues: _selectedDays,
                          options: const [
                            MultiSelectableGroupOption(
                              value: 0,
                              widget: Text('Mon'),
                            ),
                            MultiSelectableGroupOption(
                              value: 1,
                              widget: Text('Tue'),
                            ),
                            MultiSelectableGroupOption(
                              value: 2,
                              widget: Text('Wed'),
                            ),
                            MultiSelectableGroupOption(
                              value: 3,
                              widget: Text('Thu'),
                            ),
                            MultiSelectableGroupOption(
                              value: 4,
                              widget: Text('Fri'),
                            ),
                            MultiSelectableGroupOption(
                              value: 5,
                              widget: Text('Sat'),
                            ),
                            MultiSelectableGroupOption(
                              value: 6,
                              widget: Text('Sun'),
                            ),
                          ],
                          onChanged: (values) {
                            setState(() {
                              _selectedDays = values;
                            });
                          },
                        ),
                      ),
                    ],

                    // Reminder Time
                    AppFormField(
                      label: 'Reminder time',
                      optional: true,
                      child: SizedBox(
                        width: double.infinity,
                        child: TimeSelect(
                          onTimeChanged: (value) {
                            setState(() {
                              _selectedTime = value;
                            });
                          },
                        ),
                      ),
                    ),

                    // Goal Duration
                    AppFormField(
                      label: 'Goal',
                      child: SelectableGroup<int?>(
                        initialValue: null,
                        options: const [
                          SelectableGroupOption(
                            value: null,
                            widget: Text('No limit'),
                          ),
                          SelectableGroupOption(
                            value: 21,
                            widget: Text('21 days'),
                          ),
                          SelectableGroupOption(
                            value: 30,
                            widget: Text('30 days'),
                          ),
                          SelectableGroupOption(
                            value: 60,
                            widget: Text('60 days'),
                          ),
                          SelectableGroupOption(
                            value: 90,
                            widget: Text('90 days'),
                          ),
                        ],
                        onChanged: isSubmitting
                            ? (_) {}
                            : (value) {
                                setState(() {
                                  _goalDuration = value;
                                });
                              },
                      ),
                    ),

                    // Tags
                    AppFormField(
                      label: 'Tags',
                      optional: true,
                      child: ChipInput<String>(
                        controller: _tagsController,
                        enabled: !isSubmitting,
                        onChipsChanged: (tags) {
                          setState(() {
                            _selectedTags = tags;
                          });
                        },
                        onChipSubmitted: (value) {
                          return '#$value';
                        },
                        chipBuilder: (context, chip) {
                          return Text(chip);
                        },
                        placeholder: const Text('Add a tag'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    FormSubmitButton(
                      label: 'Create habit',
                      loadingLabel: 'Creating…',
                      loading: isSubmitting,
                      onPressed: _submitForm,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
