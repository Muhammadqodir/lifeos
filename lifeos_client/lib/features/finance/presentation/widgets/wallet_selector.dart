import 'package:hugeicons/hugeicons.dart';
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

  dynamic _getWalletTypeIcon(WalletType type) {
    switch (type) {
      case WalletType.card:
        return HugeIcons.strokeRoundedCreditCard;
      case WalletType.bankAccount:
        return HugeIcons.strokeRoundedBank;
      case WalletType.cash:
        return HugeIcons.strokeRoundedMoneyBag01;
      case WalletType.other:
        return HugeIcons.strokeRoundedWallet03;
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedWalletId;
  }

  @override
  void didUpdateWidget(WalletSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedWalletId != oldWidget.selectedWalletId) {
      _selectedValue = widget.selectedWalletId;
    }
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
          style: theme.typography.small.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.foreground,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: Select<int?>(
            itemBuilder: (context, item) {
              if (item == null) {
                return Text(
                  widget.placeholder ?? 'Select wallet',
                  style: Theme.of(context).typography.small,
                );
              }
              final wallet = widget.wallets.firstWhere((w) => w.id == item);
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  HugeIcon(icon: _getWalletTypeIcon(wallet.type), size: 18),
                  const SizedBox(width: 8),
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
                        HugeIcon(
                          icon: _getWalletTypeIcon(wallet.type),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
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
            ).call,
          ),
        ),
      ],
    );
  }
}
