import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/core/widgets/empty_state.dart';
import 'package:lifeos_client/core/widgets/error_state.dart';
import 'package:lifeos_client/core/widgets/loading_state.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/log_entry_bloc.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/log_entry_event.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/log_entry_state.dart';
import 'package:lifeos_client/features/habits/presentation/widgets/habit_card.dart';
import 'package:lifeos_client/features/home/presentation/bloc/home_bloc.dart';
import 'package:lifeos_client/features/home/presentation/bloc/home_event.dart';
import 'package:lifeos_client/features/home/presentation/bloc/home_state.dart';
import 'package:lifeos_client/features/navigation/presentation/widgets/custom_app_bar.dart';
import 'package:lifeos_client/features/habits/presentation/pages/habits_main_page.dart';
import 'package:lifeos_client/features/projects/presentation/bloc/manage_todos_bloc.dart';
import 'package:lifeos_client/features/projects/presentation/bloc/manage_todos_event.dart';
import 'package:lifeos_client/features/projects/presentation/bloc/manage_todos_state.dart';
import 'package:lifeos_client/features/projects/presentation/bloc/manage_projects_bloc.dart';
import 'package:lifeos_client/features/projects/presentation/pages/create_todo_page.dart';
import 'package:lifeos_client/features/projects/presentation/widgets/todo_card.dart';
import 'package:lifeos_client/features/home/presentation/widgets/projects_list_sheet.dart';
import 'package:lifeos_client/injection.dart';
import 'package:lifeos_client/utils/modal.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<RefreshTriggerState> _refreshTriggerKey =
      GlobalKey<RefreshTriggerState>();

  int? _updatingTodoId;
  int? _deletingTodoId;
  int? _updatingHabitId;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ManageTodosBloc, ManageTodosState>(
      listener: (context, state) {
        if (state is TodoStatusUpdating) {
          setState(() {
            _updatingTodoId = state.todoId;
          });
        } else if (state is TodoStatusUpdated) {
          context.read<HomeBloc>().add(const HomeRefreshed());
        } else if (state is TodoDeleting) {
          setState(() {
            _deletingTodoId = state.todoId;
          });
        } else if (state is ManageTodosLoaded) {
          context.read<HomeBloc>().add(const HomeRefreshed());
        } else if (state is ManageTodosError) {
          setState(() {
            _updatingTodoId = null;
            _deletingTodoId = null;
          });
        }
      },
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeSuccess) {
            setState(() {
              _deletingTodoId = null;
              _updatingTodoId = null;
            });
          }
        },
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return Scaffold(
              headers: [
                CustomAppBar(
                  title: _getGreeting(),
                  rightActions: [
                    AppBarAction(
                      icon: HugeIcons.strokeRoundedAdd01,
                      tooltip: 'Quick Add',
                      onTap: () => _showQuickAddMenu(context),
                    ),
                  ],
                ),
              ],
              child: RefreshTrigger(
                key: _refreshTriggerKey,
                onRefresh: () async {
                  context.read<HomeBloc>().add(const HomeRefreshed());
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: _buildBody(context, state),
              ),
            );
          },
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  Widget _buildBody(BuildContext context, HomeState state) {
    if (state is HomeLoading || state is HomeInitial) {
      return const LoadingState(message: "Loading your day...");
    }

    if (state is HomeFailure) {
      return ErrorState(
        message: state.message,
        onRetry: () {
          context.read<HomeBloc>().add(const HomeRetried());
        },
      );
    }

    if (state is HomeEmpty) {
      return const EmptyState(
        title: "Welcome to LifeOS",
        description: "Start by creating your first habit or todo!",
      );
    }

    if (state is HomeSuccess) {
      return _buildSuccessContent(context, state);
    }

    return const SizedBox.shrink();
  }

  Widget _buildSuccessContent(BuildContext context, HomeSuccess state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date display
          _buildDateCard(context, theme, colorScheme),
          const SizedBox(height: 12),

          // Overdue Todos
          ..._buildTodoSection(context, theme, 'Overdue', state.overdueTodos),

          // Todos for Today
          ..._buildTodoSection(
            context,
            theme,
            'Planned for Today',
            state.todosToday,
          ),

          // In Progress Todos
          ..._buildTodoSection(
            context,
            theme,
            'In Progress',
            state.inProgressTodos,
          ),

          // Inbox Todos
          ..._buildTodoSection(context, theme, 'Inbox', state.inboxTodos),

          // Habits for Today
          if (state.habitsToday.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              theme,
              'Habits for Today',
              onViewAll: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(builder: (_) => const HabitsMainPage()),
                );
              },
            ),
            const SizedBox(height: 12),
            ...state.habitsToday.map((habit) {
              final isUpdating = _updatingHabitId == habit.id;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: HabitCard(
                  habit: habit,
                  isUpdating: isUpdating,
                  onCheckIn: () {
                    if (!isUpdating) {
                      _toggleHabitCompletion(
                        context,
                        habit.id,
                        habit.isCompletedToday ?? false,
                      );
                    }
                  },
                ),
              );
            }),
            const SizedBox(height: 24),
          ],

          // Empty state if all sections are empty
          if (state.habitsToday.isEmpty &&
              state.todosToday.isEmpty &&
              state.overdueTodos.isEmpty &&
              state.inProgressTodos.isEmpty &&
              state.inboxTodos.isEmpty) ...[
            const SizedBox(height: 40),
            const Center(
              child: EmptyState(
                title: "All Clear!",
                description: "You have no tasks or habits scheduled for today.",
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, MMMM d');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedCalendar03,
            color: colorScheme.primaryForeground,
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateFormat.format(now),
                style: theme.typography.p.copyWith(
                  color: colorScheme.primaryForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Today',
                style: theme.typography.xSmall.copyWith(
                  color: colorScheme.primaryForeground.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    ThemeData theme,
    String title, {
    VoidCallback? onViewAll,
  }) {
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Text(
          title,
          style: theme.typography.normal.copyWith(fontWeight: FontWeight.w600),
        ),
        if (onViewAll != null) ...[
          const Spacer(),
          GestureDetector(
            onTap: onViewAll,
            child: Text(
              'View All',
              style: theme.typography.small.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showQuickAddMenu(BuildContext context) {
    BottomSheetModal.openSheet(
      context: context,
      builder: (context) {
        return BlocProvider(
          create: (_) => getIt<ManageProjectsBloc>(),
          child: const ProjectsListSheet(),
        );
      },
    ).then((selectedProject) {
      if (selectedProject != null && mounted) {
        _navigateToCreateTodo(context, selectedProject.id);
      }
    });
  }

  Future<void> _navigateToCreateTodo(
    BuildContext context,
    int projectId,
  ) async {
    final result = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(
        builder: (context) => CreateTodoPage(projectId: projectId),
      ),
    );

    if (result == true && mounted) {
      context.read<HomeBloc>().add(const HomeRefreshed());
    }
  }

  List<Widget> _buildTodoSection(
    BuildContext context,
    ThemeData theme,
    String title,
    List<dynamic> todos,
  ) {
    if (todos.isEmpty) return [];

    return [
      _buildSectionHeader(context, theme, title),
      const SizedBox(height: 12),
      ...todos.map((todo) {
        final isUpdating =
            _updatingTodoId == todo.id || _deletingTodoId == todo.id;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TodoCard(
            padding: const EdgeInsets.all(0),
            todo: todo,
            showProject: true,
            isUpdating: isUpdating,
            onTap: () {
              // TODO: Navigate to todo details page
            },
            onStatusChanged: ({plannedDate, required status}) {
              if (!isUpdating) {
                _handleTodoStatusChanged(
                  context,
                  todo.id,
                  todo.status,
                  status,
                  plannedDate,
                );
              }
            },
            onDelete: () {
              if (!isUpdating) {
                _handleTodoDelete(context, todo.id);
              }
            },
          ),
        );
      }),
      const SizedBox(height: 12),
    ];
  }

  void _handleTodoStatusChanged(
    BuildContext context,
    int todoId,
    String oldStatus,
    String newStatus,
    DateTime? plannedDate,
  ) {
    if (newStatus == 'planned' && plannedDate == null) {
      // Show date picker before changing status to planned
      showDialog<DateTime>(
        context: context,
        builder: (context) {
          DateTime selectedDate = DateTime.now();
          return AlertDialog(
            title: Text("Select Planned Date"),
            content: DatePickerDialog(
              initialViewType: CalendarViewType.date,
              selectionMode: CalendarSelectionMode.single,
              onChanged: (value) {
                if (value is DateTime) {
                  Navigator.of(context).pop(value);
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              PrimaryButton(
                child: const Text('Select'),
                onPressed: () {
                  Navigator.of(context).pop(selectedDate);
                },
              ),
            ],
          );
        },
      ).then((selectedDate) {
        if (selectedDate != null) {
          context.read<ManageTodosBloc>().add(
            UpdateTodoStatus(
              todoId: todoId,
              status: newStatus,
              oldStatus: oldStatus,
              plannedDate: selectedDate,
            ),
          );
        }
      });
    } else {
      context.read<ManageTodosBloc>().add(
        UpdateTodoStatus(
          todoId: todoId,
          status: newStatus,
          oldStatus: oldStatus,
        ),
      );
    }
  }

  void _handleTodoDelete(BuildContext context, int todoId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Todo'),
        content: const Text('Are you sure you want to delete this todo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<ManageTodosBloc>().add(DeleteTodo(todoId));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleHabitCompletion(
    BuildContext context,
    int habitId,
    bool isCompleted,
  ) async {
    setState(() {
      _updatingHabitId = habitId;
    });

    try {
      final logEntryBloc = getIt<LogEntryBloc>();

      // Create log entry for today
      final now = DateTime.now();
      final dateString =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      // Backend expects completed_at in "Y-m-d H:i:s" format
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

      // Wait for the result
      await for (final state in logEntryBloc.stream) {
        if (state is LogEntrySuccess) {
          setState(() {
            _updatingHabitId = null;
          });
          context.read<HomeBloc>().add(const HomeRefreshed());
          break;
        } else if (state is LogEntryFailure) {
          setState(() {
            _updatingHabitId = null;
          });
          if (mounted) {
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(content: Text('Failed to update habit: ${state.message}')),
            // );
          }
          break;
        }
      }

      logEntryBloc.close();
    } catch (e) {
      setState(() {
        _updatingHabitId = null;
      });
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Error: $e')),
        // );
      }
    }
  }
}
