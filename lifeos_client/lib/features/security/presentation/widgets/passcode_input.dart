import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/ui/ui.dart';

class PasscodeInput extends StatefulWidget {
  final Function(String) onCompleted;
  final VoidCallback? onChanged;
  final bool isError;
  final int length;

  const PasscodeInput({
    super.key,
    required this.onCompleted,
    this.onChanged,
    this.isError = false,
    this.length = 6,
  });

  @override
  State<PasscodeInput> createState() => _PasscodeInputState();
}

class _PasscodeInputState extends State<PasscodeInput> {
  final List<String> _passcode = [];

  void _addDigit(String digit) {
    if (_passcode.length < widget.length) {
      setState(() {
        _passcode.add(digit);
      });
      widget.onChanged?.call();

      if (_passcode.length == widget.length) {
        widget.onCompleted(_passcode.join());
      }
    }
  }

  void _removeDigit() {
    if (_passcode.isNotEmpty) {
      setState(() {
        _passcode.removeLast();
      });
      widget.onChanged?.call();
    }
  }

  /// Hardware keyboard (Mac, iPad keyboard): digits type, Backspace deletes.
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      _removeDigit();
      return KeyEventResult.handled;
    }
    final char = event.character;
    if (char != null && RegExp(r'^[0-9]$').hasMatch(char)) {
      _addDigit(char);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var index = 0; index < widget.length; index++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: AnimatedContainer(
                    duration: AppDurations.fast,
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < _passcode.length
                          ? (widget.isError
                                ? colors.destructive
                                : colors.foreground)
                          : colors.foreground.withValues(alpha: 0),
                      border: Border.all(
                        color: widget.isError
                            ? colors.destructive
                            : colors.mutedForeground,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            width: 264,
            child: Column(
              children: [
                for (final row in const [
                  ['1', '2', '3'],
                  ['4', '5', '6'],
                  ['7', '8', '9'],
                  ['', '0', 'del'],
                ]) ...[
                  _buildNumberRow(row),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final number in numbers)
          number.isEmpty
              ? const SizedBox(width: 72, height: 72)
              : _buildNumberButton(number),
      ],
    );
  }

  Widget _buildNumberButton(String number) {
    final colors = context.colors;
    final isDelete = number == 'del';
    return AppPressable(
      onTap: isDelete ? _removeDigit : () => _addDigit(number),
      borderRadius: BorderRadius.circular(36),
      semanticLabel: isDelete ? 'Delete digit' : number,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDelete ? null : colors.muted,
        ),
        alignment: Alignment.center,
        child: isDelete
            ? Icon(
                Icons.backspace_outlined,
                size: AppIconSize.lg,
                color: colors.foreground,
              )
            : Text(
                number,
                style: context.theme.typography.x2Large.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colors.foreground,
                ),
              ),
      ),
    );
  }
}
