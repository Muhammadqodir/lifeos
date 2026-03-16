import 'package:shadcn_flutter/shadcn_flutter.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Passcode dots display
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.length,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < _passcode.length
                      ? (widget.isError
                          ? theme.colorScheme.destructive
                          : theme.colorScheme.primary)
                      : theme.colorScheme.muted,
                  border: Border.all(
                    color: widget.isError
                        ? theme.colorScheme.destructive
                        : theme.colorScheme.border,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 48),
        // Number pad
        SizedBox(
          width: 280,
          child: Column(
            children: [
              _buildNumberRow(['1', '2', '3']),
              const SizedBox(height: 16),
              _buildNumberRow(['4', '5', '6']),
              const SizedBox(height: 16),
              _buildNumberRow(['7', '8', '9']),
              const SizedBox(height: 16),
              _buildNumberRow(['', '0', 'del']),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNumberRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) {
        if (number.isEmpty) {
          return const SizedBox(width: 72, height: 72);
        }
        return _buildNumberButton(number);
      }).toList(),
    );
  }

  Widget _buildNumberButton(String number) {
    final theme = Theme.of(context);

    if (number == 'del') {
      return GestureDetector(
        onTap: _removeDigit,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.muted.withOpacity(0.5),
          ),
          child: Icon(
            Icons.backspace,
            color: theme.colorScheme.foreground,
            size: 24,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _addDigit(number),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.muted.withOpacity(0.5),
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.foreground,
            ),
          ),
        ),
      ),
    );
  }
}
