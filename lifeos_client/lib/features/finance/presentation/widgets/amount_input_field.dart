import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/services.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all spaces
    String newText = newValue.text.replaceAll(' ', '');

    // Only allow numbers and one decimal point
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(newText)) {
      return oldValue;
    }

    // Split by decimal point
    final parts = newText.split('.');
    String integerPart = parts[0];
    String? decimalPart = parts.length > 1 ? parts[1] : null;

    // Format integer part with spaces
    String formatted = '';
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        formatted += ' ';
      }
      formatted += integerPart[i];
    }

    // Add decimal part if exists
    if (decimalPart != null) {
      formatted += '.$decimalPart';
    }

    // Calculate new cursor position
    int selectionIndex = newValue.selection.end;
    int originalSpaces = oldValue.text.substring(0, oldValue.selection.end).split(' ').length - 1;
    int newSpaces = formatted.substring(0, formatted.length.clamp(0, selectionIndex + (formatted.split(' ').length - 1 - originalSpaces))).split(' ').length - 1;
    
    // Adjust cursor position accounting for added/removed spaces
    selectionIndex = (selectionIndex + newSpaces - originalSpaces).clamp(0, formatted.length);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

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
    
    // Format the initial value if provided
    String? formattedValue;
    if (value != null && value!.isNotEmpty) {
      final cleanValue = value!.replaceAll(' ', '');
      final parts = cleanValue.split('.');
      String integerPart = parts[0];
      String? decimalPart = parts.length > 1 ? parts[1] : null;
      
      String formatted = '';
      for (int i = 0; i < integerPart.length; i++) {
        if (i > 0 && (integerPart.length - i) % 3 == 0) {
          formatted += ' ';
        }
        formatted += integerPart[i];
      }
      
      if (decimalPart != null) {
        formatted += '.$decimalPart';
      }
      formattedValue = formatted;
    }
    
    final controller = TextEditingController(text: formattedValue ?? value);
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.typography.small.copyWith(
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
            ThousandsSeparatorInputFormatter(),
          ],
          onChanged: (formatted) {
            // Remove spaces before passing to parent
            final cleanValue = formatted.replaceAll(' ', '');
            onChanged(cleanValue);
          },
        ),
      ],
    );
  }
}
