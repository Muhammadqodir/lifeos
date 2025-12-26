import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../data/models/wallet_dto.dart';

class WalletSelector extends StatefulWidget {
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
  State<WalletSelector> createState() => _WalletSelectorState();
}

class _WalletSelectorState extends State<WalletSelector> {
  int? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedWalletId;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.foreground,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: Select<int?>(
            itemBuilder: (context, item) {
              if (item == null) return Text(widget.placeholder ?? 'Select wallet');
              final wallet = widget.wallets.firstWhere((w) => w.id == item);
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
            onChanged: (value) {
              setState(() {
                _selectedValue = value;
              });
              widget.onChanged(value);
            },
            value: _selectedValue,
            placeholder: Text(widget.placeholder ?? 'Select wallet'),
            popup: SelectPopup(
              items: SelectItemList(
                children: widget.wallets.map((wallet) {
                  return SelectItemButton(
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
              ),
            ),
          ),
        ),
      ],
    );
  }
}
