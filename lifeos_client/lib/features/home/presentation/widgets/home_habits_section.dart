import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos_client/features/habits/data/models/habit_dto.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/log_entry_bloc.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/log_entry_event.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/log_entry_state.dart';
import 'package:lifeos_client/features/habits/presentation/pages/habits_main_page.dart';
import 'package:lifeos_client/features/habits/presentation/widgets/habit_card.dart';
import 'package:lifeos_client/features/home/presentation/bloc/home_bloc.dart';
import 'package:lifeos_client/features/home/presentation/bloc/home_event.dart';
import 'package:lifeos_client/features/home/presentation/widgets/home_section_header.dart';
import 'package:lifeos_client/injection.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class HomeHabitsSection extends StatefulWidget {
  final List<HabitDto> habits;

  const HomeHabitsSection({super.key, required this.habits});

  @override
  State<HomeHabitsSection> createState() => _HomeHabitsSectionState();
}

class _HomeHabitsSectionState extends State<HomeHabitsSection> {
  int? _updatingHabitId;

  @override
  Widget build(BuildContext context) {
    if (widget.habits.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(
          title: 'Habits for Today',
          onViewAll: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const HabitsMainPage(),
                transitionsBuilder: (_, animation, __, child) =>
                    FadeTransition(opacity: animation, child: child),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        ...widget.habits.map((habit) {
          final isUpdating = _updatingHabitId == habit.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: HabitCard(
              habit: habit,
              isUpdating: isUpdating,
              onCheckIn: () {
                if (!isUpdating) {
                  _toggleHabitCompletion(context, habit.id);
                }
              },
            ),
          );
        }),
        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _toggleHabitCompletion(
    BuildContext context,
    int habitId,
  ) async {
    setState(() => _updatingHabitId = habitId);

    try {
      final logEntryBloc = getIt<LogEntryBloc>();
      final now = DateTime.now();
      final dateString =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final completedAtString =
          '$dateString ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

      logEntryBloc.add(
        LogEntrySubmitted(
          habitId: habitId,
          date: dateString,
          completedAt: completedAtString,
          note: null,
        ),
      );

      await for (final state in logEntryBloc.stream) {
        if (state is LogEntrySuccess) {
          if (mounted) {
            setState(() => _updatingHabitId = null);
            context.read<HomeBloc>().add(const HomeRefreshed());
          }
          break;
        } else if (state is LogEntryFailure) {
          if (mounted) setState(() => _updatingHabitId = null);
          break;
        }
      }

      logEntryBloc.close();
    } catch (_) {
      if (mounted) setState(() => _updatingHabitId = null);
    }
  }
}
