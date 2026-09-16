import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_project/presentation/components/app_drawer.dart';
import 'package:ai_project/presentation/components/learning_path_tile.dart';
import 'package:ai_project/data/models/learning_path.dart';
import 'package:ai_project/l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.drawerHome),
      ),
      drawer: const AppDrawer(),
      body: userId == null
          ? Center(child: Text(AppLocalizations.of(context)!.errorNotAuthenticated))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('paths')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('${AppLocalizations.of(context)!.errorTitle}: ${snapshot.error}'));
                  }

                  final paths = snapshot.data?.docs ?? [];

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
                          final path = LearningPath.fromDocument(paths[index]);
                          
                          int currentDayNumber = 1;
                          String displayContent = path.description;
                          
                          if (path.days.isNotEmpty) {
                            // Find the first uncompleted day.
                            // For now, assuming it's the first day since isCompleted isn't fully implemented on days yet.
                            // You can update this logic once isCompleted is available on DayPlan.
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

