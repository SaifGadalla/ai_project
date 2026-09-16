import 'package:flutter/material.dart';
import 'package:ai_project/l10n/app_localizations.dart';
import 'package:ai_project/data/models/learning_path.dart';

class DayDetailsScreen extends StatelessWidget {
  final DayPlan day;

  const DayDetailsScreen({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.dayDetailsTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppLocalizations.of(context)!.dayPrefix} ${day.dayNumber}: ${day.title}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            Text(
              AppLocalizations.of(context)!.dayTasksSubtitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (day.tasks.isEmpty)
              Text(AppLocalizations.of(context)!.dayNoTasks)
            else
              ...day.tasks.map((task) => CheckboxListTile(
                    value: task.isCompleted,
                    onChanged: (val) {
                      // Note: Updating task completion status in Firestore would go here.
                      // For now, it's read-only in this simple stateless representation.
                    },
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  )),
          ],
        ),
      ),
    );
  }
}
