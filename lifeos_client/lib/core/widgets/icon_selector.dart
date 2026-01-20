import 'dart:io';
import 'package:lifeos_client/core/widgets/tappable.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';

class IconSelector extends StatefulWidget {
  final String? initialIcon;
  final ValueChanged<XFile?> onChanged;

  const IconSelector({super.key, this.initialIcon, required this.onChanged});

  @override
  State<IconSelector> createState() => _IconSelectorState();
}

class _IconSelectorState extends State<IconSelector> {
  XFile? selectedImage;

  @override
  void initState() {
    super.initState();
    // If there's an initial icon path, we could load it here
    // For now, we start with no image
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        selectedImage = image;
      });
      widget.onChanged(image);
    }
  }

  void _removeImage() {
    setState(() {
      selectedImage = null;
    });
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (selectedImage != null)
          // Show selected image with remove option
          Tappable(
            onTap: () {
              _pickImage();
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.border, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(selectedImage!.path), fit: BoxFit.cover),
              ),
            ),
          )
        else
          // Show button to pick image
          IconButton.outline(
            onPressed: _pickImage,
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedImage01,
              size: 20,
            ),
          ),
      ],
    );
  }
}
