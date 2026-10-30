import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/sync/sync_engine.dart';
import '../../../../core/ui/ui.dart';
import '../../../../injection.dart';
import '../../data/models/project_dto.dart';
import '../bloc/manage_projects_bloc.dart';
import '../bloc/manage_projects_event.dart';
import '../bloc/manage_projects_state.dart';
import '../widgets/project_card.dart';
import '../widgets/project_leading.dart';
import '../widgets/projects_stats_card.dart';
import 'add_project_page.dart';
import 'project_details_page.dart';

/// Projects tab. The [ManageProjectsBloc] is provided by the app shell.
///
/// On wide windows (iPad landscape, Mac) the selected project's todos open
/// beside a compact list instead of on a pushed page.
class ProjectsMainPage extends StatefulWidget {
  const ProjectsMainPage({super.key});

  @override
  State<ProjectsMainPage> createState() => _ProjectsMainPageState();
}

class _ProjectsMainPageState extends State<ProjectsMainPage> {
  final GlobalKey<RefreshTriggerState> _refreshTriggerKey =
      GlobalKey<RefreshTriggerState>();

  ManageProjectsBloc get _bloc => context.read<ManageProjectsBloc>();

  /// Project shown in the detail pane of the split view.
  String? _selectedId;

  void _refresh() => _bloc.add(const ManageProjectsRefresh());

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SplitView.fits(constraints)
          ? _buildSplit(context)
          : _buildPage(context),
    );
  }

  Widget _deleteListener({required Widget child}) {
    return BlocListener<ManageProjectsBloc, ManageProjectsState>(
      listener: (context, state) {
        if (state is ManageProjectsDeleteSuccess) {
          AppToast.success(context, 'Project deleted');
        } else if (state is ManageProjectsDeleteError) {
          AppToast.error(
            context,
            "Couldn't delete project",
            message: state.message,
          );
        }
      },
      child: child,
    );
  }

  AppHeader _header(BuildContext context) => AppHeader(
    title: 'Projects',
    onRefresh: _refresh,
    actions: [
      HeaderAction(
        icon: HugeIcons.strokeRoundedAdd01,
        tooltip: 'New project',
        label: 'New project',
        primary: true,
        onTap: () => _navigateToAddProject(context),
      ),
    ],
  );

  Widget _buildSplit(BuildContext context) {
    return _deleteListener(
      child: BlocBuilder<ManageProjectsBloc, ManageProjectsState>(
        builder: (context, state) {
          final projects = state is ManageProjectsWithData
              ? state.projects
              : const <ProjectDto>[];
          final selected =
              projects.where((p) => p.id == _selectedId).firstOrNull ??
              projects.firstOrNull;

          final Widget detail;
          if (selected != null) {
            detail = ProjectDetailsPage(
              key: ValueKey(selected.id),
              project: selected,
            );
          } else if (state is ManageProjectsError) {
            detail = const SizedBox.shrink();
          } else {
            detail = Scaffold(
              child: EmptyState(
                title: 'No project selected',
                description: 'Choose a project to see its todos.',
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedFolder01),
              ),
            );
          }

          return SplitView(
            list: Scaffold(
              headers: [_header(context)],
              child: _buildCompactList(context, state, projects, selected),
            ),
            detail: detail,
          );
        },
      ),
    );
  }

  Widget _buildCompactList(
    BuildContext context,
    ManageProjectsState state,
    List<ProjectDto> projects,
    ProjectDto? selected,
  ) {
    if (state is ManageProjectsError) {
      return ErrorState(
        title: "Couldn't load projects",
        message: state.message,
        onRetry: () => _bloc.add(const ManageProjectsLoad()),
      );
    }
    if (state is ManageProjectsLoading || state is ManageProjectsInitial) {
      return const LoadingState(message: 'Loading projects…');
    }
    if (projects.isEmpty) {
      return EmptyState(
        title: 'Start your first project',
        description:
            'Projects group related todos so you can see progress at a glance.',
        icon: const HugeIcon(icon: HugeIcons.strokeRoundedFolder01),
        action: PrimaryButton(
          onPressed: () => _navigateToAddProject(context),
          child: const Text('Create project'),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        AppListSection(
          title: 'Your projects',
          count: projects.length,
          margin: EdgeInsets.zero,
          children: [
            for (final project in projects)
              AppListTile(
                leading: ProjectLeading(project: project),
                title: project.title,
                subtitle: _openTodosLabel(project.pendingTodosCount),
                selected: project.id == selected?.id,
                onTap: () => setState(() => _selectedId = project.id),
                actions: [
                  AppAction(
                    label: 'Delete project',
                    icon: HugeIcons.strokeRoundedDelete02,
                    destructive: true,
                    onSelected: () => _confirmDelete(context, project),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  static String _openTodosLabel(int count) => switch (count) {
    0 => 'No open todos',
    1 => '1 open todo',
    _ => '$count open todos',
  };

  Widget _buildPage(BuildContext context) {
    return _deleteListener(
      child: Scaffold(
        headers: [_header(context)],
        child: RefreshTrigger(
          key: _refreshTriggerKey,
          onRefresh: () => getIt<SyncEngine>().syncNow(),
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<ManageProjectsBloc, ManageProjectsState>(
      builder: (context, state) {
        if (state is ManageProjectsError) {
          return ErrorState(
            title: "Couldn't load projects",
            message: state.message,
            onRetry: () => _bloc.add(const ManageProjectsLoad()),
          );
        }

        final isLoading =
            state is ManageProjectsLoading || state is ManageProjectsInitial;
        final List<ProjectDto> projects = state is ManageProjectsWithData
            ? state.projects
            : const [];

        final activeTodos = projects.fold<int>(
          0,
          (sum, p) => sum + p.pendingTodosCount,
        );
        final completedTodos = projects.fold<int>(
          0,
          (sum, p) => sum + p.completedTodosCount,
        );

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverContentWidth(
              maxWidth: AppLayout.maxWideContentWidth,
              vertical: const EdgeInsets.only(top: AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: ProjectsStatsCard(
                  totalProjects: projects.length,
                  activeTodos: activeTodos,
                  completedTodos: completedTodos,
                  isLoading: isLoading,
                ),
              ),
            ),
            SliverContentWidth(
              maxWidth: AppLayout.maxWideContentWidth,
              vertical: const EdgeInsets.only(top: AppSpacing.section),
              sliver: SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Your projects',
                  count: isLoading ? null : projects.length,
                ),
              ),
            ),
            if (isLoading)
              _grid(
                childCount: 4,
                builder: (_, __) => Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: context.colors.muted,
                    borderRadius: context.theme.cardRadius,
                  ),
                ).asSkeleton(),
              )
            else if (projects.isEmpty)
              SliverToBoxAdapter(
                child: EmptyState(
                  title: 'Start your first project',
                  description:
                      'Projects group related todos so you can see progress at a glance.',
                  icon: const HugeIcon(icon: HugeIcons.strokeRoundedFolder01),
                  action: PrimaryButton(
                    onPressed: () => _navigateToAddProject(context),
                    child: const Text('Create project'),
                  ),
                ),
              )
            else
              _grid(
                childCount: projects.length,
                cellExtent: _cardExtent(projects),
                builder: (context, index) {
                  final project = projects[index];
                  return ProjectCard(
                    project: project,
                    onTap: () => _openProject(context, project),
                    onDelete: () => _confirmDelete(context, project),
                  );
                },
              ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
          ],
        );
      },
    );
  }

  /// One column on iPhone, a responsive grid on iPad and Mac.
  /// Grid cell height that fits the tallest card variant actually present,
  /// so rows don't carry empty space.
  double _cardExtent(List<ProjectDto> projects) {
    final hasDescription = projects.any(
      (p) => p.description != null && p.description!.isNotEmpty,
    );
    final hasTags = projects.any((p) => p.tags.isNotEmpty);
    return 96 + (hasDescription ? 40 : 0) + (hasTags ? 34 : 0);
  }

  Widget _grid({
    required int childCount,
    required NullableIndexedWidgetBuilder builder,
    double cellExtent = 140,
  }) {
    return SliverContentWidth(
      maxWidth: AppLayout.maxWideContentWidth,
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          if (constraints.crossAxisExtent < 560) {
            // Natural-height cards in a single column.
            return SliverList.separated(
              itemCount: childCount,
              itemBuilder: (context, index) => builder(context, index)!,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.md),
            );
          }
          return SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 420,
              mainAxisExtent: cellExtent,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
            ),
            delegate: SliverChildBuilderDelegate(
              // Cards fill their cell so a row's cards share one height.
              (context, index) =>
                  SizedBox.expand(child: builder(context, index)),
              childCount: childCount,
            ),
          );
        },
      ),
    );
  }

  Future<void> _openProject(BuildContext context, ProjectDto project) async {
    await Navigator.of(context).push(
      CupertinoPageRoute(builder: (_) => ProjectDetailsPage(project: project)),
    );
    // Counts change when todos are added or completed inside the project.
    if (mounted) _refresh();
  }

  Future<void> _confirmDelete(BuildContext context, ProjectDto project) async {
    final confirmed = await AppDialogs.confirmDelete(
      context,
      itemName: 'project',
      message:
          '"${project.title}" and all of its todos will be deleted. This can\'t be undone.',
    );
    if (confirmed && mounted) {
      _bloc.add(ManageProjectsDelete(projectId: project.id));
    }
  }

  Future<void> _navigateToAddProject(BuildContext context) async {
    await Navigator.of(
      context,
    ).push<bool>(CupertinoPageRoute(builder: (_) => const AddProjectPage()));
  }
}
