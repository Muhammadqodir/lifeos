import 'package:lifeos_client/core/ui/ui.dart';
import 'package:lifeos_client/core/widgets/selectable_group.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

enum FeeType {
  none,
  halfPercent,
  onePercent,
  custom;

  String get label {
    switch (this) {
      case FeeType.none:
        return '0%';
      case FeeType.halfPercent:
        return '0.5%';
      case FeeType.onePercent:
        return '1%';
      case FeeType.custom:
        return 'Custom';
    }
  }

  double? get percentage {
    switch (this) {
      case FeeType.none:
        return 0;
      case FeeType.halfPercent:
        return 0.5;
      case FeeType.onePercent:
        return 1.0;
      case FeeType.custom:
        return null; // User will input custom value
    }
  }
}

class FeeSelector extends StatefulWidget {
  final FeeType selectedFeeType;
  final String customFeeValue;
  final ValueChanged<FeeType> onFeeTypeChanged;
  final ValueChanged<String> onCustomFeeChanged;

  const FeeSelector({
    super.key,
    required this.selectedFeeType,
    required this.customFeeValue,
    required this.onFeeTypeChanged,
    required this.onCustomFeeChanged,
  });

  @override
  State<FeeSelector> createState() => _FeeSelectorState();
}

class _FeeSelectorState extends State<FeeSelector> {
  late TextEditingController _customController;

  @override
  void initState() {
    super.initState();
    _customController = TextEditingController(text: widget.customFeeValue);
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _updateFeeTypeFromValue(String value) {
    final numValue = double.tryParse(value);
    if (numValue == null || numValue == 0) {
      widget.onFeeTypeChanged(FeeType.none);
    } else if (numValue == 0.5) {
      widget.onFeeTypeChanged(FeeType.halfPercent);
    } else if (numValue == 1.0) {
      widget.onFeeTypeChanged(FeeType.onePercent);
    } else {
      widget.onFeeTypeChanged(FeeType.custom);
    }
  }

  void _applyPreset(FeeType type) {
    final percentage = type.percentage;
    if (percentage == null) return;
    final valueString = percentage == 0 ? '' : percentage.toString();
    _customController.text = valueString;
    widget.onCustomFeeChanged(valueString);
    _updateFeeTypeFromValue(valueString);
  }

  @override
  Widget build(BuildContext context) {
    final inputValue = double.tryParse(widget.customFeeValue) ?? 0;
    final presets = [FeeType.none, FeeType.halfPercent, FeeType.onePercent];
    final selected = presets
        .where((t) => t.percentage == inputValue)
        .firstOrNull;

    return AppFormField(
      label: 'Transfer fee',
      optional: true,
      hint: 'Deducted from the source wallet.',
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: SelectableGroup<FeeType?>(
              // null = a custom value that matches no preset
              value: selected,
              allowEmpty: true,
              options: [
                for (final type in presets)
                  SelectableGroupOption(value: type, widget: Text(type.label)),
              ],
              onChanged: (type) {
                if (type != null) _applyPreset(type);
              },
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _customController,
              placeholder: const Text('Custom'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              features: [
                InputFeature.trailing(
                  Text('%', style: context.text.itemSubtitle),
                ),
              ],
              onSubmitted: (_) => FocusScope.of(context).unfocus(),
              onChanged: (value) {
                widget.onCustomFeeChanged(value);
                _updateFeeTypeFromValue(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
