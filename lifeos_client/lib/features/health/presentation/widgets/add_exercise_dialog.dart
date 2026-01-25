import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lifeos_client/core/widgets/selectable_group.dart';
import 'package:lifeos_client/utils/modal.dart';
import 'package:lifeos_client/utils/toast.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../bloc/exercise_bloc.dart';
import '../bloc/exercise_event.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Add Custom Exercise',
              style: theme.typography.large.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.foreground,
              ),
            ),
            const SizedBox(height: 24),

            // Exercise Name
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exercise Name *',
                  style: theme.typography.small.copyWith(
                    color: colorScheme.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  placeholder: const Text('e.g., Cable Fly'),
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Type Selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Type *',
                  style: theme.typography.small.copyWith(
                    color: colorScheme.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableGroup<String>(
                  initialValue: selectedType,
                  options: ['strength', 'distance', 'time']
                      .map(
                        (type) => SelectableGroupOption(
                          value: type,
                          widget: Text(type.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedType = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Muscle Group Selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Muscle Group (optional)',
                  style: theme.typography.small.copyWith(
                    color: colorScheme.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: muscleGroupController,
                  placeholder: const Text('e.g., Chest, Back'),
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Image Upload
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exercise Image (optional)',
                  style: theme.typography.small.copyWith(
                    color: colorScheme.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                if (selectedImage != null)
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.border,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(selectedImage!.path),
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() => selectedImage = null);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: colorScheme.destructive,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const HugeIcon(
                                icon: HugeIcons.strokeRoundedDelete02,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  OutlineButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 1024,
                        maxHeight: 1024,
                        imageQuality: 85,
                      );
                      if (image != null) {
                        setState(() => selectedImage = image);
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedImage01,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text('Choose Image'),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final muscleGroup = muscleGroupController.text.trim().isEmpty
                      ? null
                      : muscleGroupController.text.trim();

                  if (name.isEmpty) {
                    showToast(
                      context: context,
                      builder: (context, overlay) {
                        return Utils.buildToast(
                          context,
                          overlay,
                          'Validation Error',
                          'Please enter exercise name',
                        );
                      },
                      location: ToastLocation.topCenter,
                    );
                    return;
                  }

                  context.read<ExerciseBloc>().add(
                    CreateExercise(
                      name: name,
                      type: selectedType,
                      muscleGroup: muscleGroup,
                      imagePath: selectedImage?.path,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Create'),
              ),
            ),
          ],
        ),
      ),
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
