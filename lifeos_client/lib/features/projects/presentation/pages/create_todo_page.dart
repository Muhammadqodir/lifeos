import 'package:flutter/services.dart' show TextInputAction;

import 'package:lifeos_client/core/widgets/date_select.dart';
import 'package:lifeos_client/core/widgets/time_select.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
              headers: [AppHeader(title: 'New todo')],
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page,
                  vertical: AppSpacing.lg,
                ),
                child: ContentWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      AppFormField(
                        label: 'Title',
                        child: TextField(
                          controller: _titleController,
                          placeholder: const Text('Write release notes'),
                          enabled: !isSubmitting,
                          onChanged: (value) {
                            _bloc.add(TitleChanged(value));
                          },
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      // Comment
                      AppFormField(
                        label: 'Description',
                        optional: true,
                        child: TextField(
                          controller: _commentController,
                          placeholder: const Text('Details, links, acceptance criteria'),
                          enabled: !isSubmitting,
                          onChanged: (value) {
                            _bloc.add(CommentChanged(value));
                          },
                          maxLines: 3,
                          textInputAction: TextInputAction.newline,
                        ),
                      ),

                      // Priority
                      AppFormField(
                        label: 'Priority',
                        child: SelectableGroup<String>(
                          initialValue: formState?.priority ?? 'middle',
                          options: [
                            SelectableGroupOption(
                              value: 'low',
                              widget: Text('Low'),
                            ),
                            SelectableGroupOption(
                              value: 'middle',
                              widget: Text('Medium'),
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
                      ),

                      // Urgency
                      AppFormField(
                        label: 'Urgency',
                        child: SelectableGroup<String>(
                          initialValue: formState?.urgency ?? 'middle',
                          options: [
                            SelectableGroupOption(
                              value: 'low',
                              widget: Text('Low'),
                            ),
                            SelectableGroupOption(
                              value: 'middle',
                              widget: Text('Medium'),
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
                      ),

                      // Energy
                      AppFormField(
                        label: 'Energy',
                        child: SelectableGroup<String>(
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
                      ),

                      // Planned Date
                      AppFormField(
                        label: 'Planned for',
                        optional: true,
                        child: Row(
                          children: [
                            Expanded(
                              child: DateSelect(
                                onDateChanged: (value) {
                                  _bloc.add(PlannedDateChanged(value));
                                },
                              ),
                            ),
                            SizedBox(width: 12),
                            TimeSelect(
                              onTimeChanged: (value) {
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
                      ),

                      // Tags
                      AppFormField(
                        label: 'Tags',
                        optional: true,
                        child: ChipInput<String>(
                          controller: _tagsController,
                          enabled: !isSubmitting,
                          onChipsChanged: (value) {
                            _bloc.add(TagsChanged(value));
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

                      FormSubmitButton(
                        label: 'Create todo',
                        loadingLabel: 'Creating…',
                        loading: isSubmitting,
                        onPressed: () =>
                            _bloc.add(SubmitTodo(widget.projectId)),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
