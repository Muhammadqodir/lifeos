import 'package:flutter/cupertino.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class TimeSelect extends StatefulWidget {
  const TimeSelect({super.key, this.onTimeChanged});
  final ValueChanged<TimeOfDay?>? onTimeChanged;

  @override
  State<TimeSelect> createState() => _TimeSelectState();
}

class _TimeSelectState extends State<TimeSelect> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: TextField(
        controller: _controller,
        readOnly: true,
        style: Theme.of(
          context,
        ).typography.small.copyWith(fontWeight: FontWeight.w500),
        features: [
          InputFeature.clear(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedCancel01,
              size: 18,
              strokeWidth: 2,
            ),
          ),
          InputFeature.leading(
            HugeIcon(
              icon: HugeIcons.strokeRoundedTime02,
              size: 18,
              strokeWidth: 2,
            ),
          ),
        ],
        placeholder: Text(
          '__:__',
          style: Theme.of(
            context,
          ).typography.small.copyWith(fontWeight: FontWeight.w500),
        ),
        onTap: () async {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              DateTime tempDate = DateTime.now();
              return AlertDialog(
                content: Container(
                  height: 216,
                  padding: const EdgeInsets.only(top: 6.0),
                  margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  color: CupertinoColors.systemBackground.resolveFrom(context),
                  child: SafeArea(
                    top: false,
                    child: CupertinoDatePicker(
                      initialDateTime: tempDate,
                      mode: CupertinoDatePickerMode.time,
                      use24hFormat: true,
                      onDateTimeChanged: (DateTime newDate) {
                        tempDate = newDate;
                      },
                    ),
                  ),
                ),
                actions: [
                  SecondaryButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  PrimaryButton(
                    onPressed: () {
                      setState(() {
                        _controller.text = _formatTime(tempDate);
                      });
                      // Notify parent of the time change
                      if (widget.onTimeChanged != null) {
                        widget.onTimeChanged!(TimeOfDay(
                          hour: tempDate.hour,
                          minute: tempDate.minute,
                        ));
                      }
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
