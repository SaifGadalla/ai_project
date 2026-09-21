import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_project/l10n/app_localizations.dart';
import 'package:ai_project/data/models/learning_path.dart';
import 'package:ai_project/domain/usecases/auth/get_auth_state_usecase.dart';
import 'package:ai_project/domain/usecases/path/update_task_status_usecase.dart';

class DayDetailsArgs {
  final DayPlan dayPlan;
  final String pathId;
  final int dayIndex;

  DayDetailsArgs({
    required this.dayPlan,
    required this.pathId,
    required this.dayIndex,
  });
}

class DayDetailsScreen extends StatefulWidget {
  final DayPlan day;
  final String pathId;
  final int dayIndex;

  const DayDetailsScreen({
    super.key,
    required this.day,
    required this.pathId,
    required this.dayIndex,
  });

  @override
  State<DayDetailsScreen> createState() => _DayDetailsScreenState();
}

class _DayDetailsScreenState extends State<DayDetailsScreen> {
  late List<Task> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = List.from(widget.day.tasks);
  }

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
              '${AppLocalizations.of(context)!.dayPrefix} ${widget.day.dayNumber}: ${widget.day.title}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            Text(
              AppLocalizations.of(context)!.dayTasksSubtitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (_tasks.isEmpty)
              Text(AppLocalizations.of(context)!.dayNoTasks)
            else
              ..._tasks.asMap().entries.map((entry) {
                final taskIndex = entry.key;
                final task = entry.value;
                return CheckboxListTile(
                  value: task.isCompleted,
                  onChanged: (val) {
                    if (val == null) return;
                    
                    setState(() {
                      _tasks[taskIndex] = Task(
                        title: task.title,
                        isCompleted: val,
                      );
                    });

                    final getAuthState = context.read<GetAuthStateUseCase>();
                    final userId = getAuthState.currentUser?.uid;
                    if (userId != null) {
                      context.read<UpdateTaskStatusUseCase>().call(
                            userId: userId,
                            pathId: widget.pathId,
                            dayIndex: widget.dayIndex,
                            taskIndex: taskIndex,
                            isCompleted: val,
                          );
                    }
                  },
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                );
              }),
          ],
        ),
      ),
    );
  }
}
