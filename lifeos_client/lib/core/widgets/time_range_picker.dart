import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:lifeos_client/core/widgets/tappable.dart';

class TimeRangeSelection {
  final TimeOfDay start;
  final TimeOfDay end;

  const TimeRangeSelection({required this.start, required this.end});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeRangeSelection &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}

class TimeRangePicker extends StatefulWidget {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int stepMinutes;
  final ValueChanged<TimeRangeSelection?>? onChanged;
  final TimeRangeSelection? initialValue;

  const TimeRangePicker({
    super.key,
    required this.startTime,
    required this.endTime,
    this.stepMinutes = 15,
    this.onChanged,
    this.initialValue,
  });

  @override
  State<TimeRangePicker> createState() => _TimeRangePickerState();
}

class _TimeRangePickerState extends State<TimeRangePicker> {
  TimeOfDay? _selectedStart;
  TimeOfDay? _selectedEnd;
  bool _selectingStart = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _selectedStart = widget.initialValue!.start;
      _selectedEnd = widget.initialValue!.end;
      _selectingStart = false;
    }
  }

  List<TimeOfDay> _generateTimeSlots() {
    final slots = <TimeOfDay>[];
    int startMinutes = widget.startTime.hour * 60 + widget.startTime.minute;
    int endMinutes = widget.endTime.hour * 60 + widget.endTime.minute;

    // Handle overnight range (e.g., 20:00 to 12:00 next day)
    if (endMinutes <= startMinutes) {
      endMinutes += 24 * 60; // Add 24 hours
    }

    for (
      int minutes = startMinutes;
      minutes <= endMinutes;
      minutes += widget.stepMinutes
    ) {
      final actualMinutes = minutes % (24 * 60);
      final hour = actualMinutes ~/ 60;
      final minute = actualMinutes % 60;
      slots.add(TimeOfDay(hour: hour, minute: minute));
    }

    return slots;
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _onTimeSelected(TimeOfDay time) {
    setState(() {
      if (_selectingStart) {
        _selectedStart = time;
        _selectedEnd = null;
        _selectingStart = false;
      } else {
        _selectedEnd = time;
        if (_selectedStart != null && _selectedEnd != null) {
          widget.onChanged?.call(
            TimeRangeSelection(start: _selectedStart!, end: _selectedEnd!),
          );
        }
      }
    });
  }

  void _reset() {
    setState(() {
      _selectedStart = null;
      _selectedEnd = null;
      _selectingStart = true;
      widget.onChanged?.call(null);
    });
  }

  bool _isInRange(TimeOfDay time) {
    if (_selectedStart == null || _selectedEnd == null) return false;

    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = _selectedStart!.hour * 60 + _selectedStart!.minute;
    final endMinutes = _selectedEnd!.hour * 60 + _selectedEnd!.minute;

    if (startMinutes <= endMinutes) {
      return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
    } else {
      // Overnight range
      return timeMinutes >= startMinutes || timeMinutes <= endMinutes;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final slots = _generateTimeSlots();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instructions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedStart != null || _selectedEnd != null)
                    const SizedBox(height: 4),
                  if (_selectedStart != null || _selectedEnd != null)
                    Text(
                      '${_selectedStart != null ? _formatTime(_selectedStart!) : '--:--'} - ${_selectedEnd != null ? _formatTime(_selectedEnd!) : '--:--'}',
                      style: theme.typography.xSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.foreground,
                      ),
                    ),
                ],
              ),
            ),
            if (_selectedStart != null || _selectedEnd != null)
              OutlineButton(
                density: ButtonDensity.compact,
                onPressed: _reset,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('Reset', style: theme.typography.xSmall),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Time slots
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: slots.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final time = slots[index];
              final isSelected = time == _selectedStart || time == _selectedEnd;
              final isInRange = _isInRange(time);

              return Tappable(
                lowerBound: 0.98,
                onTap: () => _onTimeSelected(time),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : isInRange
                        ? colorScheme.primary.withOpacity(0.2)
                        : colorScheme.muted,
                    border: Border.all(
                      color: isSelected || isInRange
                          ? colorScheme.primary
                          : colorScheme.border,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _formatTime(time),
                      style: theme.typography.base.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected
                            ? colorScheme.primaryForeground
                            : colorScheme.foreground,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
