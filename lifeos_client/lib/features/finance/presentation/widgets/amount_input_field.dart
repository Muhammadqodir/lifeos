import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/services.dart';


class AmountInputField extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<String> onChanged;
  final String? placeholder;
  final String? suffix;

  const AmountInputField({
    super.key,
    required this.label,
    this.value,
    required this.onChanged,
    this.placeholder,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final controller = TextEditingController(text: value);
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.foreground,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          placeholder: Text(placeholder ?? 'Enter amount'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}
