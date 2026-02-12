import 'package:flutter/cupertino.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../injection.dart';
import '../../../../utils/dialogs.dart';
import '../../../../utils/toast.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../navigation/presentation/widgets/custom_app_bar.dart';
import '../../data/models/project_dto.dart';
import '../bloc/manage_projects_bloc.dart';
import '../bloc/manage_projects_event.dart';
import '../bloc/manage_projects_state.dart';
import '../widgets/projects_stats_card.dart';
import '../widgets/project_card.dart';
import 'add_project_page.dart';
import '../../../projects/presentation/pages/project_details_page.dart';

class ProjectsMainPage extends StatefulWidget {
  const ProjectsMainPage({super.key});

  @override
  State<ProjectsMainPage> createState() => _ProjectsMainPageState();
}

class _ProjectsMainPageState extends State<ProjectsMainPage> {
  late final ManageProjectsBloc _projectsBloc;

  @override
  void initState() {
    super.initState();
    _projectsBloc = getIt<ManageProjectsBloc>()
      ..add(const ManageProjectsLoad());
  }

  @override
  void dispose() {
    _projectsBloc.close();
    super.dispose();
  }

  final GlobalKey<RefreshTriggerState> _refreshTriggerKey =
      GlobalKey<RefreshTriggerState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ManageProjectsBloc>.value(
      value: _projectsBloc,
      child: BlocListener<ManageProjectsBloc, ManageProjectsState>(
        listener: (context, state) {
          // When project is deleted, show toast
          if (state is ManageProjectsDeleteSuccess) {
            showToast(
              context: context,
              location: ToastLocation.topCenter,
              builder: (context, overlay) {
                return Utils.buildToast(
                  context,
                  overlay,
                  'Project Deleted',
                  'The project has been deleted successfully.',
                );
              },
            );
          } else if (state is ManageProjectsDeleteError) {
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
        child: Column(
          children: [
            CustomAppBar(
              title: "Projects",
              rightActions: [
                AppBarAction(
                  icon: HugeIcons.strokeRoundedAdd01,
                  tooltip: 'Add Project',
                  onTap: () {
                    _navigateToAddProject(context);
                  },
                ),
              ],
            ),
            Expanded(
              child: RefreshTrigger(
                key: _refreshTriggerKey,
                onRefresh: () async {
                  _projectsBloc.add(const ManageProjectsRefresh());
                  // Wait a bit for the refresh to complete
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: _buildBody(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<ManageProjectsBloc, ManageProjectsState>(
      builder: (context, state) {
        // Get projects data
        final List<ProjectDto> projects = state is ManageProjectsWithData
            ? state.projects
            : [];

        // Calculate summary
        final totalProjects = projects.length;
        final activeTodos = projects.fold<int>(
          0,
          (sum, project) => sum + project.pendingTodosCount,
        );
        final completedTodos = projects.fold<int>(
          0,
          (sum, project) => sum + project.completedTodosCount,
        );

        return CustomScrollView(
          slivers: [
            // Stats Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ProjectsStatsCard(
                  totalProjects: totalProjects,
                  activeTodos: activeTodos,
                  completedTodos: completedTodos,
                  isLoading: state is ManageProjectsLoading,
                ),
              ).asSkeleton(enabled: state is ManageProjectsLoading),
            ),

            // Projects section header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Your Projects',
                  style: theme.typography.normal.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.foreground,
                  ),
                ),
              ),
            ),

            // Projects list
            if (projects.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final project = projects[index];
                    return ProjectCard(
                      project: project,
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => ProjectDetailsPage(project: project),
                          ),
                        );
                      },
                      onDelete: () async {
                        bool? confirmed = await Dialogs.showConfirmDialog(
                          context: context,
                          title: 'Delete Project',
                          message:
                              'Are you sure you want to delete "${project.title}"? All associated todos will also be deleted.',
                        );
                        if (confirmed == true) {
                          if (context.mounted) {
                            _projectsBloc.add(
                              ManageProjectsDelete(projectId: project.id),
                            );
                          }
                        }
                      },
                    );
                  },
                  childCount: projects.length,
                ),
              )
            else if (state is ManageProjectsLoading)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: colorScheme.muted,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  childCount: 3,
                ),
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: EmptyState(
                    title: 'No Projects',
                    description:
                        'Create your first project to start organizing your tasks',
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedFolder01,
                      size: 32,
                    ),
                    action: Button.primary(
                      onPressed: () {
                        _navigateToAddProject(context);
                      },
                      child: const Text('Create Project'),
                    ),
                  ),
                ),
              ),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        );
      },
    );
  }

  /// Navigate to Add Project page
  Future<void> _navigateToAddProject(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(builder: (_) => const AddProjectPage()),
    );
    if (result == true && context.mounted) {
      _projectsBloc.add(const ManageProjectsRefresh());
    }
  }
}
