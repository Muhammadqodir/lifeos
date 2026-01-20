import 'package:lifeos_client/core/widgets/color_selector.dart';
import 'package:lifeos_client/core/widgets/icon_selector.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../injection.dart';
import '../../../../utils/toast.dart';
import '../../../navigation/presentation/widgets/custom_app_bar.dart';
import '../bloc/add_project_bloc.dart';
import '../bloc/add_project_event.dart';
import '../bloc/add_project_state.dart';

class AddProjectPage extends StatelessWidget {
  const AddProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AddProjectBloc>(),
      child: const _AddProjectPageContent(),
    );
  }
}

class _AddProjectPageContent extends StatefulWidget {
  const _AddProjectPageContent();

  @override
  State<_AddProjectPageContent> createState() => _AddProjectPageContentState();
}

class _AddProjectPageContentState extends State<_AddProjectPageContent> {
  String _projectTitle = '';
  String _projectDescription = '';
  String _selectedColor = 'FF6B7280'; // Default blue
  XFile? _selectedIconImage;
  final ChipEditingController<String> _tagsController = ChipEditingController();
  List<String> _tags = [];

  @override
  void dispose() {
    _tagsController.dispose();
    super.dispose();
  }

  void _handleFormSubmit(BuildContext context) {
    // Validate project title
    if (_projectTitle.trim().isEmpty) {
      showToast(
        context: context,
        builder: (context, overlay) {
          return Utils.buildToast(
            context,
            overlay,
            'Validation Error',
            'Please enter a project title',
          );
        },
        location: ToastLocation.topCenter,
      );
      return;
    }

    // Submit to BLoC
    context.read<AddProjectBloc>().add(
      AddProjectSubmitted(
        title: _projectTitle.trim(),
        description: _projectDescription.trim().isEmpty
            ? null
            : _projectDescription.trim(),
        color: _selectedColor,
        iconImage: _selectedIconImage,
        tags: _tags.isEmpty ? null : _tags,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outerContext = context;

    return BlocListener<AddProjectBloc, AddProjectState>(
      listener: (context, state) {
        if (state is AddProjectSuccess) {
          showToast(
            context: context,
            builder: (context, overlay) {
              return Utils.buildToast(
                context,
                overlay,
                'Success',
                'Project created successfully',
              );
            },
            location: ToastLocation.topCenter,
          );
          Navigator.of(context).pop(true);
        } else if (state is AddProjectError) {
          print(state.message);
          showToast(
            context: context,
            builder: (context, overlay) {
              return Utils.buildToast(context, overlay, 'Error', state.message);
            },
            location: ToastLocation.bottomCenter,
          );
        }
      },
      child: Scaffold(
        headers: [
          CustomAppBar(
            title: 'Add Project',
            leftActions: [
              AppBarAction(
                icon: HugeIcons.strokeRoundedArrowLeft01,
                tooltip: 'Back',
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
        child: BlocBuilder<AddProjectBloc, AddProjectState>(
          builder: (context, state) {
            final isSubmitting = state is AddProjectSubmitting;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Project Title Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Project Title', style: theme.typography.small),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconSelector(
                            initialIcon: null,
                            onChanged: (image) {
                              setState(() {
                                _selectedIconImage = image;
                              });
                            },
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              initialValue: _projectTitle,
                              placeholder: const Text(
                                'e.g., Mobile App Development',
                              ),
                              onSubmitted: (_) =>
                                  FocusScope.of(context).unfocus(),
                              onChanged: (value) {
                                setState(() {
                                  _projectTitle = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Project Description Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description (Optional)',
                        style: theme.typography.small,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        initialValue: _projectDescription,
                        placeholder: const Text('Describe your project...'),
                        minLines: 3,
                        maxLines: 5,
                        onSubmitted: (_) => FocusScope.of(context).unfocus(),
                        onChanged: (value) {
                          setState(() {
                            _projectDescription = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Color Selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Project Color', style: theme.typography.small),
                      const SizedBox(height: 8),
                      ColorSelector(
                        initialColor: _selectedColor,
                        onChanged: (value) {
                          setState(() {
                            _selectedColor = value;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Tags Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tags (Optional)', style: theme.typography.small),
                      const SizedBox(height: 8),
                      ChipInput<String>(
                        controller: _tagsController,
                        onChipsChanged: (value) {
                          setState(() {
                            _tags = value;
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
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      onPressed: !isSubmitting
                          ? () => _handleFormSubmit(outerContext)
                          : null,
                      child: isSubmitting
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Creating...'),
                              ],
                            )
                          : const Text('Create Project'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
