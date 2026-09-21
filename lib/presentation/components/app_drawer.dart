import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_project/presentation/controller/path/paths_cubit.dart';
import 'package:ai_project/l10n/app_localizations.dart';
import 'package:ai_project/presentation/controller/auth/auth_bloc.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState.user;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  AppLocalizations.of(context)!.drawerAppTitle,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                if (user?.email != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    user!.email!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(AppLocalizations.of(context)!.drawerHome),
            onTap: () {
              Navigator.pop(context); // Close drawer
              context.go('/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(AppLocalizations.of(context)!.drawerSettings),
            onTap: () {
              Navigator.pop(context); // Close drawer
              context.push('/settings');
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              AppLocalizations.of(context)!.drawerYourPaths,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          if (user != null)
            BlocBuilder<PathsCubit, PathsState>(
              builder: (context, state) {
                if (state is PathsLoading || state is PathsInitial) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is PathsError) {
                  return ListTile(
                    title: Text(
                      '${AppLocalizations.of(context)!.errorTitle}: ${state.message}',
                    ),
                  );
                }

                if (state is PathsLoaded) {
                  final paths = state.paths;

                  if (paths.isEmpty) {
                    return ListTile(
                      title: Text(AppLocalizations.of(context)!.drawerNoPaths),
                    );
                  }

                  return Column(
                    children: paths.map((path) {
                      return ListTile(
                        leading: const Icon(Icons.route),
                        title: Text(
                          path.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          Navigator.pop(context); // Close drawer
                          context.push('/path/${path.id}');
                        },
                      );
                    }).toList(),
                  );
                }
                
                return const SizedBox.shrink();
              },
            ),
          if (user != null) const Divider(),
          if (user != null)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text(
                'Logout',
              ), // Using hardcoded text as no localized key is provided, usually would use AppLocalizations
              onTap: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
            ),
        ],
      ),
    );
  }
}
