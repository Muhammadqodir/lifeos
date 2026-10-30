import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lifeos_client/core/widgets/selectable_group.dart';
import 'package:lifeos_client/utils/modal.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../bloc/exercise_bloc.dart';
import '../bloc/exercise_event.dart';
import 'package:lifeos_client/core/ui/ui.dart';

class AddExerciseDialog extends StatefulWidget {
  const AddExerciseDialog({super.key});

  @override
  State<AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<AddExerciseDialog> {
  final nameController = TextEditingController();
  final muscleGroupController = TextEditingController();
  String selectedType = 'strength';
  XFile? selectedImage;

  @override
  void dispose() {
    nameController.dispose();
    muscleGroupController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image != null) setState(() => selectedImage = image);
  }

  void _submit() {
    final name = nameController.text.trim();
    final muscleGroup = muscleGroupController.text.trim();
    if (name.isEmpty) {
      AppToast.error(context, 'Check the form', message: 'Enter an exercise name.');
      return;
    }
    context.read<ExerciseBloc>().add(
      CreateExercise(
        name: name,
        type: selectedType,
        muscleGroup: muscleGroup.isEmpty ? null : muscleGroup,
        imagePath: selectedImage?.path,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FormSheet(
      title: 'New exercise',
      description: 'Add a custom exercise to use in workouts.',
      submit: FormSubmitButton(label: 'Create exercise', onPressed: _submit),
      children: [
        AppFormField(
          label: 'Name',
          child: TextField(
            controller: nameController,
            placeholder: const Text('Cable fly'),
          ),
        ),
        AppFormField(
          label: 'Type',
          child: SelectableGroup<String>(
            initialValue: selectedType,
            options: const [
              SelectableGroupOption(value: 'strength', widget: Text('Strength')),
              SelectableGroupOption(value: 'distance', widget: Text('Distance')),
              SelectableGroupOption(value: 'time', widget: Text('Time')),
            ],
            onChanged: (value) => setState(() => selectedType = value),
          ),
        ),
        AppFormField(
          label: 'Muscle group',
          optional: true,
          child: TextField(
            controller: muscleGroupController,
            placeholder: const Text('Chest'),
          ),
        ),
        AppFormField(
          label: 'Image',
          optional: true,
          child: selectedImage == null
              ? OutlineButton(
                  onPressed: _pickImage,
                  leading: const HugeIcon(
                    icon: HugeIcons.strokeRoundedImage01,
                    size: AppIconSize.sm,
                  ),
                  child: const Text('Choose image'),
                )
              : Stack(
                  children: [
                    ClipRRect(
                      borderRadius: theme.controlRadius,
                      child: Image.file(
                        File(selectedImage!.path),
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: IconButton.secondary(
                        size: ButtonSize.small,
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedDelete02,
                          size: AppIconSize.sm,
                        ),
                        onPressed: () => setState(() => selectedImage = null),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

void showAddExerciseDialog(BuildContext context) {
  final exerciseBloc = context.read<ExerciseBloc>();

  BottomSheetModal.openSheet(
    context: context,
    builder: (sheetContext) => BlocProvider.value(
      value: exerciseBloc,
      child: const AddExerciseDialog(),
    ),
  );
}
