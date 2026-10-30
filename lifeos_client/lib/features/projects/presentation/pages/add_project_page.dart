import 'package:lifeos_client/core/widgets/color_selector.dart';
import 'package:lifeos_client/core/widgets/icon_selector.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection.dart';
import '../bloc/add_project_bloc.dart';
import '../bloc/add_project_event.dart';
import '../bloc/add_project_state.dart';
import 'package:lifeos_client/core/ui/ui.dart';

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
  String _selectedColor = 'FF6B7280';
  XFile? _selectedIconImage;
  final ChipEditingController<String> _tagsController = ChipEditingController();
  List<String> _tags = [];

  @override
  void dispose() {
    _tagsController.dispose();
    super.dispose();
  }

  void _handleFormSubmit(BuildContext context) {
    if (_projectTitle.trim().isEmpty) {
      AppToast.error(
        context,
        'Check the form',
        message: 'Enter a project title.',
      );
      return;
    }

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
    final outerContext = context;

    return BlocListener<AddProjectBloc, AddProjectState>(
      listener: (context, state) {
        if (state is AddProjectSuccess) {
          AppToast.success(context, 'Project created');
          Navigator.of(context).pop(true);
        } else if (state is AddProjectError) {
          AppToast.error(
            context,
            'Something went wrong',
            message: state.message,
          );
        }
      },
      child: Scaffold(
        headers: [AppHeader(title: 'New project')],
        child: BlocBuilder<AddProjectBloc, AddProjectState>(
          builder: (context, state) {
            final isSubmitting = state is AddProjectSubmitting;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.page,
                vertical: AppSpacing.lg,
              ),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: ContentWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppFormField(
                      label: 'Name',
                      hint: 'Tap the image button to add an icon.',
                      child: Row(
                        children: [
                          IconSelector(
                            initialIcon: null,
                            onChanged: (image) =>
                                setState(() => _selectedIconImage = image),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: TextField(
                              initialValue: _projectTitle,
                              placeholder: const Text('Mobile app'),
                              onChanged: (value) =>
                                  setState(() => _projectTitle = value),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppFormField(
                      label: 'Description',
                      optional: true,
                      child: TextField(
                        initialValue: _projectDescription,
                        placeholder: const Text('What this project is about'),
                        minLines: 3,
                        maxLines: 5,
                        onChanged: (value) =>
                            setState(() => _projectDescription = value),
                      ),
                    ),
                    AppFormField(
                      label: 'Colour',
                      child: ColorSelector(
                        initialColor: _selectedColor,
                        onChanged: (value) =>
                            setState(() => _selectedColor = value),
                      ),
                    ),
                    AppFormField(
                      label: 'Tags',
                      optional: true,
                      child: ChipInput<String>(
                        controller: _tagsController,
                        onChipsChanged: (value) => setState(() => _tags = value),
                        onChipSubmitted: (value) => '#$value',
                        chipBuilder: (context, chip) => Text(chip),
                        placeholder: const Text('Add a tag'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    FormSubmitButton(
                      label: 'Create project',
                      loadingLabel: 'Creating…',
                      loading: isSubmitting,
                      onPressed: () => _handleFormSubmit(outerContext),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
