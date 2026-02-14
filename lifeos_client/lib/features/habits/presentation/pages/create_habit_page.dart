import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/core/widgets/color_selector.dart';
import 'package:lifeos_client/core/widgets/multi_selectable_group.dart';
import 'package:lifeos_client/core/widgets/selectable_group.dart';
import 'package:lifeos_client/core/widgets/time_select.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/create_habit_bloc.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/create_habit_event.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/create_habit_state.dart';
import 'package:lifeos_client/features/navigation/presentation/widgets/custom_app_bar.dart';
import 'package:lifeos_client/utils/toast.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

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
      showToast(
        context: context,
        location: ToastLocation.topCenter,
        builder: (context, overlay) {
          return Utils.buildToast(
            context,
            overlay,
            'Error',
            'Please enter a habit title',
          );
        },
      );
      return;
    }

    // Strip FF alpha channel from color if present (backend expects 6-char hex)
    String colorForBackend = _selectedColor;
    if (_selectedColor.length == 8 && _selectedColor.toUpperCase().startsWith('FF')) {
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
          showToast(
            context: context,
            location: ToastLocation.topCenter,
            builder: (context, overlay) {
              return Utils.buildToast(
                context,
                overlay,
                'Success',
                'Habit created successfully',
              );
            },
          );
          Navigator.of(context).pop(true);
        } else if (state is CreateHabitFailure) {
          showToast(
            context: context,
            location: ToastLocation.topCenter,
            builder: (context, overlay) {
              return Utils.buildToast(context, overlay, 'Error', state.message);
            },
          );
        }
      },
      child: BlocBuilder<CreateHabitBloc, CreateHabitState>(
        builder: (context, state) {
          final isSubmitting = state is CreateHabitLoading;

          return Scaffold(
            headers: [
              CustomAppBar(
                title: 'Create Habit',
                leftActions: [
                  AppBarAction(
                    icon: HugeIcons.strokeRoundedArrowLeft01,
                    tooltip: 'Back',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
                rightActions: [
                  AppBarAction(
                    icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                    tooltip: 'Create',
                    onTap: isSubmitting ? null : _submitForm,
                  ),
                ],
              ),
            ],
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'Title',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    placeholder: const Text('Enter habit title'),
                    enabled: !isSubmitting,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    placeholder: const Text('Enter description (optional)'),
                    enabled: !isSubmitting,
                    maxLines: 3,
                    textInputAction: TextInputAction.newline,
                  ),
                  const SizedBox(height: 16),

                  // Color
                  const Text(
                    'Color',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  ColorSelector(
                    initialColor: _selectedColor,
                    onChanged: (color) {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Frequency
                  const Text(
                    'Frequency',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  SelectableGroup<String>(
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
                  const SizedBox(height: 16),

                  // Days selection for weekly
                  if (_selectedFrequency == 'weekly') ...[
                    const Text(
                      'Days',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    MultiSelectableGroup<int>(
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
                    const SizedBox(height: 16),
                  ],

                  // Reminder Time
                  const Text(
                    'Reminder Time (Optional)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TimeSelect(
                      onTimeChanged: (value) {
                        setState(() {
                          _selectedTime = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Goal Duration
                  const Text(
                    'Goal Duration',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  SelectableGroup<int?>(
                    initialValue: null,
                    options: const [
                      SelectableGroupOption(value: null, widget: Text('Unlm.')),
                      SelectableGroupOption(value: 21, widget: Text('21 d.')),
                      SelectableGroupOption(value: 30, widget: Text('30 d.')),
                      SelectableGroupOption(value: 60, widget: Text('60 d.')),
                      SelectableGroupOption(value: 90, widget: Text('90 d.')),
                    ],
                    onChanged: isSubmitting
                        ? (_) {}
                        : (value) {
                            setState(() {
                              _goalDuration = value;
                            });
                          },
                  ),
                  const SizedBox(height: 16),

                  // Tags
                  const Text(
                    'Tags (Optional)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  ChipInput<String>(
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
                    placeholder: const Text('Add a tag...'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
