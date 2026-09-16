import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_project/l10n/app_localizations.dart';
import 'package:ai_project/data/models/learning_path.dart';
import 'package:ai_project/presentation/controller/auth/auth_bloc.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

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
                if (FirebaseAuth.instance.currentUser?.email != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    FirebaseAuth.instance.currentUser!.email!,
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
          if (userId != null)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('paths')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return ListTile(
                    title: Text(
                      '${AppLocalizations.of(context)!.errorTitle}: ${snapshot.error}',
                    ),
                  );
                }

                final paths = snapshot.data?.docs ?? [];

                if (paths.isEmpty) {
                  return ListTile(
                    title: Text(AppLocalizations.of(context)!.drawerNoPaths),
                  );
                }

                return Column(
                  children: paths.map((doc) {
                    final path = LearningPath.fromDocument(doc);
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
              },
            ),
          if (userId != null) const Divider(),
          if (userId != null)
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
