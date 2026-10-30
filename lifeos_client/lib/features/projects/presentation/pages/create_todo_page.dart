import 'package:flutter/services.dart' show TextInputAction;

import 'package:lifeos_client/core/widgets/date_select.dart';
import 'package:lifeos_client/core/widgets/time_select.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/widgets/selectable_group.dart';
import '../../../../injection.dart';
import '../bloc/create_todo_bloc.dart';
import '../bloc/create_todo_event.dart';
import '../bloc/create_todo_state.dart';
import 'package:lifeos_client/core/ui/ui.dart';

class CreateTodoPage extends StatefulWidget {
  final int projectId;

  const CreateTodoPage({super.key, required this.projectId});

  @override
  State<CreateTodoPage> createState() => _CreateTodoPageState();
}

class _CreateTodoPageState extends State<CreateTodoPage> {
  late final CreateTodoBloc _bloc;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final ChipEditingController<String> _tagsController = ChipEditingController();
  List<String> _selectedTags = [];
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<CreateTodoBloc>();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    _tagsController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateTodoBloc>.value(
      value: _bloc,
      child: BlocListener<CreateTodoBloc, CreateTodoState>(
        listener: (context, state) {
          if (state is CreateTodoSuccess) {
            AppToast.success(context, 'Todo created');
            Navigator.of(context).pop(true);
          } else if (state is CreateTodoError) {
            AppToast.error(
              context,
              'Something went wrong',
              message: state.message,
            );
          }
        },
        child: BlocBuilder<CreateTodoBloc, CreateTodoState>(
          builder: (context, state) {
            final isSubmitting = state is CreateTodoSubmitting;
            final formState = state is CreateTodoInitial ? state : null;

            return Scaffold(
              headers: [
                AppHeader(
                  title: 'Create Todo',
                  actions: [
                    HeaderAction(
                      icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                      tooltip: 'Create',
                      onTap: isSubmitting
                          ? null
                          : () {
                              _bloc.add(SubmitTodo(widget.projectId));
                            },
                    ),
                  ],
                ),
              ],
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.all(16.0),
                child: ContentWidth(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'Title',
                      style: context.text.label,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      placeholder: const Text('Enter todo title'),
                      enabled: !isSubmitting,
                      onChanged: (value) {
                        _bloc.add(TitleChanged(value));
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    // Comment
                    Text(
                      'Description',
                      style: context.text.label,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _commentController,
                      placeholder: const Text('Enter description (optional)'),
                      enabled: !isSubmitting,
                      onChanged: (value) {
                        _bloc.add(CommentChanged(value));
                      },
                      maxLines: 3,
                      textInputAction: TextInputAction.newline,
                    ),
                    const SizedBox(height: 12),

                    // Priority
                    Text(
                      'Priority',
                      style: context.text.label,
                    ),
                    const SizedBox(height: 8),
                    SelectableGroup<String>(
                      initialValue: formState?.priority ?? 'middle',
                      options: [
                        SelectableGroupOption(
                          value: 'low',
                          widget: Text('Low'),
                        ),
                        SelectableGroupOption(
                          value: 'middle',
                          widget: Text('Middle'),
                        ),
                        SelectableGroupOption(
                          value: 'high',
                          widget: Text('High'),
                        ),
                      ],
                      onChanged: isSubmitting
                          ? (_) {}
                          : (value) => _bloc.add(PriorityChanged(value)),
                    ),
                    const SizedBox(height: 12),

                    // Urgency
                    Text(
                      'Urgency',
                      style: context.text.label,
                    ),
                    const SizedBox(height: 8),
                    SelectableGroup<String>(
                      initialValue: formState?.urgency ?? 'middle',
                      options: [
                        SelectableGroupOption(
                          value: 'low',
                          widget: Text('Low'),
                        ),
                        SelectableGroupOption(
                          value: 'middle',
                          widget: Text('Middle'),
                        ),
                        SelectableGroupOption(
                          value: 'high',
                          widget: Text('High'),
                        ),
                      ],
                      onChanged: isSubmitting
                          ? (_) {}
                          : (value) => _bloc.add(UrgencyChanged(value)),
                    ),
                    const SizedBox(height: 12),

                    // Energy
                    Text(
                      'Energy',
                      style: context.text.label,
                    ),
                    const SizedBox(height: 8),
                    SelectableGroup<String>(
                      initialValue: formState?.energy ?? 'medium',
                      options: [
                        SelectableGroupOption(
                          value: 'easy',
                          widget: Text('Easy'),
                        ),
                        SelectableGroupOption(
                          value: 'medium',
                          widget: Text('Medium'),
                        ),
                        SelectableGroupOption(
                          value: 'hard',
                          widget: Text('Hard'),
                        ),
                      ],
                      onChanged: isSubmitting
                          ? (_) {}
                          : (value) => _bloc.add(EnergyChanged(value)),
                    ),
                    const SizedBox(height: 12),

                    // Planned Date
                    Text(
                      'Planned Date & time',
                      style: context.text.label,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DateSelect(
                            onDateChanged: (value) {
                              setState(() {
                                _selectedDate = value;
                              });
                              _bloc.add(PlannedDateChanged(value));
                            },
                          ),
                        ),
                        SizedBox(width: 12),
                        TimeSelect(
                          onTimeChanged: (value) {
                            setState(() {
                              _selectedTime = value;
                            });
                            if (value != null) {
                              // Format TimeOfDay as HH:mm
                              final formattedTime =
                                  '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
                              _bloc.add(PlannedTimeChanged(formattedTime));
                            } else {
                              _bloc.add(PlannedTimeChanged(null));
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Tags
                    Text(
                      'Tags (Optional)',
                      style: context.text.label,
                    ),
                    const SizedBox(height: 8),
                    ChipInput<String>(
                      controller: _tagsController,
                      enabled: !isSubmitting,
                      onChipsChanged: (value) {
                        setState(() {
                          _selectedTags = value;
                        });
                        _bloc.add(TagsChanged(value));
                      },
                      onChipSubmitted: (value) {
                        return '#$value';
                      },
                      chipBuilder: (context, chip) {
                        return Text(chip);
                      },
                      placeholder: const Text('Add a tag...'),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        onPressed: isSubmitting
                            ? null
                            : () {
                                _bloc.add(SubmitTodo(widget.projectId));
                              },
                        child: isSubmitting
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Creating...'),
                                ],
                              )
                            : const Text('Create Todo'),
                      ),
                    ),
                  ],
                )),
              ),
            );
          },
        ),
      ),
    );
  }
}
