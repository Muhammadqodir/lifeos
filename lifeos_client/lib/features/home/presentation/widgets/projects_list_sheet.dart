import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/ui/ui.dart';
import '../../../projects/presentation/bloc/manage_projects_bloc.dart';
import '../../../projects/presentation/bloc/manage_projects_event.dart';
import '../../../projects/presentation/bloc/manage_projects_state.dart';
import '../../../projects/presentation/widgets/project_leading.dart';

/// Picker shown before creating a todo. Pops with the chosen ProjectDto.
class ProjectsListSheet extends StatefulWidget {
  const ProjectsListSheet({super.key});

  @override
  State<ProjectsListSheet> createState() => _ProjectsListSheetState();
}

class _ProjectsListSheetState extends State<ProjectsListSheet> {
  @override
  void initState() {
    super.initState();
    context.read<ManageProjectsBloc>().add(const ManageProjectsLoad());
  }

  @override
  Widget build(BuildContext context) {
    final height = math.min(MediaQuery.sizeOf(context).height * 0.75, 560.0);

    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Add a todo to…', style: context.text.sectionTitle),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  autofocus: isDesktopPlatform,
                  placeholder: const Text('Search projects'),
                  features: [
                    InputFeature.leading(
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedSearch01,
                        size: AppIconSize.sm,
                        color: context.colors.mutedForeground,
                      ),
                    ),
                  ],
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                  onChanged: (value) {
                    context.read<ManageProjectsBloc>().add(
                      ManageProjectsSearch(query: value.isEmpty ? null : value),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: BlocBuilder<ManageProjectsBloc, ManageProjectsState>(
              builder: (context, state) {
                if (state is ManageProjectsLoading ||
                    state is ManageProjectsInitial) {
                  return const LoadingState(message: 'Loading projects…');
                }
                if (state is ManageProjectsError) {
                  return ErrorState(
                    title: "Couldn't load projects",
                    message: state.message,
                    onRetry: () => context.read<ManageProjectsBloc>().add(
                      const ManageProjectsLoad(),
                    ),
                  );
                }
                final projects = state is ManageProjectsWithData
                    ? state.projects
                    : const [];
                if (projects.isEmpty) {
                  return const EmptyState(
                    icon: HugeIcon(icon: HugeIcons.strokeRoundedFolder01),
                    title: 'No projects found',
                    description:
                        'Create a project in the Projects tab, then add todos to it.',
                  );
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page,
                  ),
                  child: AppListSection(
                    margin: EdgeInsets.zero,
                    children: [
                      for (final project in projects)
                        AppListTile(
                          leading: ProjectLeading(project: project),
                          title: project.title,
                          subtitle: project.pendingTodosCount == 1
                              ? '1 open todo'
                              : '${project.pendingTodosCount} open todos',
                          showChevron: true,
                          onTap: () => Navigator.of(context).pop(project),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
