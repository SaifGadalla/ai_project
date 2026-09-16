import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_project/l10n/app_localizations.dart';
import 'package:ai_project/presentation/components/day_plan_tile.dart';
import 'package:ai_project/data/models/learning_path.dart';

class PathScreen extends StatelessWidget {
  final String pathId;
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;

  const PathScreen({
    super.key, 
    required this.pathId,
    this.auth,
    this.firestore,
  });

  @override
  Widget build(BuildContext context) {
    final authInstance = auth ?? FirebaseAuth.instance;
    final firestoreInstance = firestore ?? FirebaseFirestore.instance;
    
    final userId = authInstance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.errorTitle)),
        body: Center(child: Text(AppLocalizations.of(context)!.errorNotAuthenticated)),
      );
    }

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
                  content: const Text('Are you sure you want to delete this learning path?'),
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
                await firestoreInstance
                    .collection('users')
                    .doc(userId)
                    .collection('paths')
                    .doc(pathId)
                    .delete();
                
                if (context.mounted) {
                  context.pop();
                }
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: firestoreInstance
            .collection('users')
            .doc(userId)
            .collection('paths')
            .doc(pathId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text(AppLocalizations.of(context)!.errorPathNotFound));
          }

          final path = LearningPath.fromDocument(snapshot.data!);

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
              Expanded(
                child: ListView.builder(
                  itemCount: path.days.length,
                  itemBuilder: (context, index) {
                    final dayPlan = path.days[index];
                    return DayPlanTile(
                      dayPlan: dayPlan,
                      onTap: () {
                        context.push('/day_details', extra: dayPlan);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
