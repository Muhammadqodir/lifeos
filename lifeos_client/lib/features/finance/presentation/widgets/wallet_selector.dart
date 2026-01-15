import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/core/extension/extensions.dart';
import 'package:lifeos_client/features/finance/data/datasources/constants.dart';
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
                  HugeIcon(
                    icon: FinanceConstants.getWalletTypeIcon(wallet.type),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [Text(wallet.name)],
                    ),
                  ),
                  Text(
                    wallet.currency.code,
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
                          icon: FinanceConstants.getWalletTypeIcon(wallet.type),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(wallet.name),
                              Text(
                                '${wallet.currency.icon} ${wallet.balance.toMoneyFormat()}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          wallet.currency.code,
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
