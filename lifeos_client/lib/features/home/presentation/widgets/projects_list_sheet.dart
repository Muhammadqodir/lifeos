import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/core/config/app_config.dart';
import 'package:lifeos_client/core/widgets/tappable.dart';
import 'package:lifeos_client/features/projects/presentation/bloc/manage_projects_bloc.dart';
import 'package:lifeos_client/features/projects/presentation/bloc/manage_projects_event.dart';
import 'package:lifeos_client/features/projects/presentation/bloc/manage_projects_state.dart';
import 'package:lifeos_client/features/projects/presentation/widgets/project_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

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
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Select Project',
                  style: Theme.of(context).typography.large.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  features: [
                    InputFeature.trailing(
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedSearch01,
                        size: 20,
                        color: Theme.of(context).colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                  placeholder: const Text("Search projects"),
                  onChanged: (value) {
                    context.read<ManageProjectsBloc>().add(
                      ManageProjectsSearch(query: value.isEmpty ? null : value),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<ManageProjectsBloc, ManageProjectsState>(
              builder: (context, state) {
                if (state is ManageProjectsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ManageProjectsError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Theme.of(context).colorScheme.destructive,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error Loading Projects',
                            style: Theme.of(context).typography.base.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.foreground,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).typography.small.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.mutedForeground,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlineButton(
                            onPressed: () {
                              context.read<ManageProjectsBloc>().add(
                                const ManageProjectsLoad(),
                              );
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is ManageProjectsWithData) {
                  if (state.projects.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const HugeIcon(
                              icon: HugeIcons.strokeRoundedFolder01,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No projects found',
                              style: Theme.of(context).typography.normal
                                  .copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.mutedForeground,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create a project to start organizing your todos',
                              style: Theme.of(context).typography.small
                                  .copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.mutedForeground,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: state.projects.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final project = state.projects[index];
                      return Tappable(
                        lowerBound: 0.98,
                        child: Card(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: [
                              project.icon == null
                                  ? Container(
                                      width: 4,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: _parseColor(project.color),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        imageUrl:
                                            "${AppConfig.serverBaseUrl}/storage/${project.icon ?? ''}",
                                        width: 32,
                                        height: 32,
                                      ),
                                    ),
                              const SizedBox(width: 12),
                              // Title
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      project.title,
                                      style: Theme.of(context).typography.normal
                                          .copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.foreground,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (project.description != null &&
                                        project.description!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        project.description!,
                                        style: Theme.of(context)
                                            .typography
                                            .xSmall
                                            .copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.mutedForeground,
                                            ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () => Navigator.pop(context, project),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      // Remove # if present
      String hex = hexColor.replaceAll('#', '');
      // Add FF for full opacity if not present
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      // Return a default color if parsing fails
      return const Color(0xFF6B7280);
    }
  }
}
