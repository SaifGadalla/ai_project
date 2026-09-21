import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_project/presentation/controller/path/paths_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_project/presentation/components/app_drawer.dart';
import 'package:ai_project/presentation/components/learning_path_tile.dart';
import 'package:ai_project/presentation/controller/auth/auth_bloc.dart';
import 'package:ai_project/l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.drawerHome),
      ),
      drawer: const AppDrawer(),
      body: user == null
          ? Center(child: Text(AppLocalizations.of(context)!.errorNotAuthenticated))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: BlocBuilder<PathsCubit, PathsState>(
                builder: (context, state) {
                  if (state is PathsLoading || state is PathsInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is PathsError) {
                    return Center(child: Text('${AppLocalizations.of(context)!.errorTitle}: ${state.message}'));
                  }

                  if (state is PathsLoaded) {
                    final paths = state.paths;

                    if (paths.isEmpty) {
                      return Center(child: Text(AppLocalizations.of(context)!.homeNoPathsCreateOne));
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: paths.length,
                          itemBuilder: (context, index) {
                            final path = paths[index];
                            
                            int currentDayNumber = 1;
                            String displayContent = path.description;
                            
                            if (path.days.isNotEmpty) {
                              final currentDay = path.days.first;
                              currentDayNumber = currentDay.dayNumber;
                              displayContent = currentDay.title;
                              
                              if (currentDay.tasks.isNotEmpty) {
                                displayContent += '\n• ${currentDay.tasks.map((t) => t.title).join('\n• ')}';
                              }
                            }

                            return LearningPathTile(
                              title: path.title,
                              description: displayContent,
                              currentDay: currentDayNumber,
                              onTap: () {
                                context.push('/path/${path.id}');
                              },
                            );
                          },
                        );
                      },
                    );
                  }
                  
                  return const SizedBox.shrink();
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/creation');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

