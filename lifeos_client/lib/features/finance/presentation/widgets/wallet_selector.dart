import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../data/models/wallet_dto.dart';

class WalletSelector extends StatelessWidget {
  final String label;
  final List<WalletDto> wallets;
  final int? selectedWalletId;
  final ValueChanged<int?> onChanged;
  final String? placeholder;

  const WalletSelector({
    super.key,
    required this.label,
    required this.wallets,
    this.selectedWalletId,
    required this.onChanged,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final colorScheme = theme.colorScheme;

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
        SizedBox(
          width: double.infinity,
          child: ShadSelect<int>(
            placeholder: Text(placeholder ?? 'Select wallet'),
            options: wallets.map((wallet) {
              return ShadOption(
                value: wallet.id,
                child: Row(
                  children: [
                    Text(wallet.name),
                    const SizedBox(width: 8),
                    Text(
                      '(${wallet.currency.code})',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            selectedOptionBuilder: (context, value) {
              final wallet = wallets.firstWhere((w) => w.id == value);
              return Row(
                children: [
                  Text(wallet.name),
                  const SizedBox(width: 8),
                  Text(
                    '(${wallet.currency.code})',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.mutedForeground,
                    ),
                  ),
                ],
              );
            },
            onChanged: onChanged,
            initialValue: selectedWalletId,
          ),
        ),
      ],
    );
  }
}
