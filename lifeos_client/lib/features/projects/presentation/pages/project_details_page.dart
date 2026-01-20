import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:lifeos_client/core/config/app_config.dart';
import 'package:lifeos_client/core/widgets/error_state.dart';
import 'package:lifeos_client/core/widgets/selectable_group.dart';
import 'package:lifeos_client/utils/dialogs.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../injection.dart';
import '../../../../utils/toast.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../navigation/presentation/widgets/custom_app_bar.dart';
import '../../../projects/data/models/project_dto.dart';
import '../../../projects/presentation/bloc/manage_todos_bloc.dart';
import '../../../projects/presentation/bloc/manage_todos_event.dart';
import '../../../projects/presentation/bloc/manage_todos_state.dart';
import '../../../projects/data/models/todo_dto.dart';
import '../widgets/todo_card.dart';
import 'create_todo_page.dart';

class ProjectDetailsPage extends StatefulWidget {
  final ProjectDto project;

  const ProjectDetailsPage({super.key, required this.project});

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  late final ManageTodosBloc _todosBloc;
  int _selectedTabIndex = 0;
  final List<String> _statuses = [
    'inbox',
    'planned',
    'in_progress',
    'blocked',
    'done',
  ];

  @override
  void initState() {
    super.initState();
    _todosBloc = getIt<ManageTodosBloc>();
    // Load all tabs at once with a single event
    _todosBloc.add(
      LoadAllStatuses(projectId: widget.project.id, statuses: _statuses),
    );
  }

  void _loadCurrentTab() {
    final status = _statuses[_selectedTabIndex];
    _todosBloc.add(
      LoadTodosByStatus(projectId: widget.project.id, status: status),
    );
  }

  @override
  void dispose() {
    _todosBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ManageTodosBloc>.value(
      value: _todosBloc,
      child: BlocListener<ManageTodosBloc, ManageTodosState>(
        listener: (context, state) {
          if (state is ManageTodosError) {
            showToast(
              context: context,
              location: ToastLocation.topCenter,
              builder: (context, overlay) {
                return Utils.buildToast(
                  context,
                  overlay,
                  'Error',
                  state.message,
                );
              },
            );
          }
        },
        child: Scaffold(
          headers: [
            CustomAppBar(
              showBorder: false,
              title: widget.project.title,
              rightActions: [
                AppBarAction(
                  icon: HugeIcons.strokeRoundedAdd01,
                  tooltip: 'Add Todo',
                  onTap: () {
                    _navigateToCreateTodo(context);
                  },
                ),
              ],
              leftActions: [
                AppBarAction(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  tooltip: 'Back',
                  onTap: () => Navigator.of(context).pop(),
                ),
                if (widget.project.icon != null) ...[
                  SizedBox(width: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl:
                          '${AppConfig.serverBaseUrl}/storage/${widget.project.icon!}',
                      width: 28,
                      height: 28,
                    ),
                  ),
                ],
              ],
            ),
          ],
          child: BlocBuilder<ManageTodosBloc, ManageTodosState>(
            builder: (context, state) {
              if (state is ManageTodosLoading || state is ManageTodosInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ManageTodosError) {
                return ErrorState(message: state.message);
              }

              if (state is ManageTodosLoaded) {
                final todosByStatus = state.todosByStatus;
                final hasMoreByStatus = state.hasMoreByStatus;
                final isLoadingMoreByStatus = state.isLoadingMoreByStatus;

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).colorScheme.border,
                            width: 1,
                          ),
                        ),
                      ),
                      child: SelectableGroup<int>(
                        scrollable: true,
                        initialValue: _selectedTabIndex,
                        options: [
                          SelectableGroupOption(
                            value: 0,
                            widget: _buildTabOption(
                              HugeIcons.strokeRoundedInboxDownload,
                              'Inbox',
                              todosByStatus['inbox']?.length ?? 0,
                            ),
                          ),
                          SelectableGroupOption(
                            value: 1,
                            widget: _buildTabOption(
                              HugeIcons.strokeRoundedCalendar03,
                              'Planned',
                              todosByStatus['planned']?.length ?? 0,
                            ),
                          ),
                          SelectableGroupOption(
                            value: 2,
                            widget: _buildTabOption(
                              HugeIcons.strokeRoundedLoading03,
                              'In Progress',
                              todosByStatus['in_progress']?.length ?? 0,
                            ),
                          ),
                          SelectableGroupOption(
                            value: 3,
                            widget: _buildTabOption(
                              HugeIcons.strokeRoundedAlertCircle,
                              'Blocked',
                              todosByStatus['blocked']?.length ?? 0,
                            ),
                          ),
                          SelectableGroupOption(
                            value: 4,
                            widget: _buildTabOption(
                              HugeIcons.strokeRoundedCheckmarkCircle02,
                              'Done',
                              todosByStatus['done']?.length ?? 0,
                            ),
                          ),
                        ],
                        onChanged: (v) {
                          setState(() {
                            _selectedTabIndex = v;
                          });
                          _loadCurrentTab();
                        },
                      ),
                    ),
                    Expanded(
                      child: IndexedStack(
                        index: _selectedTabIndex,
                        children: _statuses.map((status) {
                          final todos = todosByStatus[status] ?? [];
                          final hasMore = hasMoreByStatus[status] ?? false;
                          final isLoadingMore =
                              isLoadingMoreByStatus[status] ?? false;
                          return _buildTodoList(
                            todos,
                            status,
                            hasMore,
                            isLoadingMore,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTodoList(
    List<TodoDto> todos,
    String status,
    bool hasMore,
    bool isLoadingMore,
  ) {
    if (todos.isEmpty) {
      return EmptyState(
        icon: const HugeIcon(icon: HugeIcons.strokeRoundedTask01),
        title: 'No ${status.replaceAll('_', ' ')} todos',
        description: 'Start by creating a new todo',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: todos.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == todos.length) {
          // Load more indicator
          if (isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: PrimaryButton(
                  onPressed: () {
                    _todosBloc.add(LoadMoreTodos(status: status));
                  },
                  child: const Text('Load More'),
                ),
              ),
            );
          }
        }

        final todo = todos[index];
        return TodoCard(
          todo: todo,
          onTap: () {
            // TODO: Navigate to todo details
          },
          onStatusChanged: ({required String status, DateTime? plannedDate}) {
            if(status == 'planned' && plannedDate != null) {
              
            }
            _todosBloc.add(UpdateTodoStatus(todoId: todo.id, status: status));
          },
          onDelete: () {
            _confirmDelete(context, todo);
          },
        );
      },
    );
  }

  Future<void> _navigateToCreateTodo(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(
        builder: (context) => CreateTodoPage(projectId: widget.project.id),
      ),
    );

    if (result == true) {
      _todosBloc.add(const RefreshTodos());
    }
  }

  Future<void> _confirmDelete(BuildContext context, TodoDto todo) async {
    final confirmed = await Dialogs.showConfirmDialog(
      context: context,
      title: "Delete Todo",
      message: 'Are you sure you want to delete "${todo.title}"?',
    );

    if (confirmed == true) {
      _todosBloc.add(DeleteTodo(todo.id));
    }
  }

  Widget _buildTabOption(List<List<dynamic>> icon, String label, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        HugeIcon(icon: icon, size: 16),
        SizedBox(width: 6),
        Text(label),
        if (count > 0) ...[
          SizedBox(width: 6),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.mutedForeground.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ],
    );
  }
}
