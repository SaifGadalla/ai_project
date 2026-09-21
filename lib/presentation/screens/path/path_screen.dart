import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_project/l10n/app_localizations.dart';
import 'package:ai_project/presentation/components/day_plan_tile.dart';
import 'package:ai_project/presentation/controller/path/path_cubit.dart';
import 'package:ai_project/presentation/screens/details/day_details_screen.dart';

class PathScreen extends StatelessWidget {
  final String pathId;

  const PathScreen({super.key, required this.pathId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.pathScreenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Path'),
                  content: const Text(
                    'Are you sure you want to delete this learning path?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                if (context.mounted) {
                  final cubit = context.read<PathCubit>();
                  await cubit.deletePath();
                }

                if (context.mounted) {
                  context.pop();
                }
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<PathCubit, PathState>(
        builder: (context, state) {
          if (state is PathLoading || state is PathInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PathError) {
            return Center(
              child: Text(
                '${AppLocalizations.of(context)!.errorTitle}: ${state.message}',
              ),
            );
          }

          if (state is PathNotFound) {
            return Center(
              child: Text(AppLocalizations.of(context)!.errorPathNotFound),
            );
          }

          if (state is PathLoaded) {
            final path = state.path;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    path.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                if (path.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      path.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                const SizedBox(height: 16),
                Builder(
                  builder: (context) {
                    int totalTasks = 0;
                    int completedTasks = 0;
                    for (var day in path.days) {
                      for (var task in day.tasks) {
                        totalTasks++;
                        if (task.isCompleted) {
                          completedTasks++;
                        }
                      }
                    }
                    final progress = totalTasks == 0
                        ? 0.0
                        : completedTasks / totalTasks;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progress',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    );
                  },
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: path.days.length,
                    itemBuilder: (context, index) {
                      final dayPlan = path.days[index];
                      return DayPlanTile(
                        dayPlan: dayPlan,
                        onTap: () {
                          context.push(
                            '/day_details',
                            extra: DayDetailsArgs(
                              dayPlan: dayPlan,
                              pathId: path.id,
                              dayIndex: index,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
