import 'package:flutter/material.dart';
import 'package:jarvis_lite/domain/entities/task_entity.dart';
import 'package:jarvis_lite/ui/theme/app_theme.dart';

/// Task tile widget
class TaskTile extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onComplete;

  const TaskTile({
    Key? key,
    required this.task,
    this.onTap,
    this.onDelete,
    this.onComplete,
  }) : super(key: key);

  Color get _priorityColor {
    switch (task.priority) {
      case TaskPriority.critical:
        return AppTheme.errorRed;
      case TaskPriority.high:
        return AppTheme.warningOrange;
      case TaskPriority.medium:
        return AppTheme.accentCyan;
      case TaskPriority.low:
        return AppTheme.textSecondary;
    }
  }

  String get _statusLabel {
    switch (task.status) {
      case TaskStatus.pending:
        return 'PENDING';
      case TaskStatus.inProgress:
        return 'IN PROGRESS';
      case TaskStatus.completed:
        return 'COMPLETED';
      case TaskStatus.failed:
        return 'FAILED';
      case TaskStatus.archived:
        return 'ARCHIVED';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Container(
          width: 6,
          decoration: BoxDecoration(
            color: _priorityColor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            decoration: task.status == TaskStatus.completed
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null) ...[
              SizedBox(height: 4),
              Text(
                task.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ],
            SizedBox(height: 4),
            Text(
              _statusLabel,
              style: TextStyle(
                color: _priorityColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            if (task.status != TaskStatus.completed)
              PopupMenuItem(
                onTap: onComplete,
                child: Row(
                  children: [
                    Icon(Icons.check, size: 18, color: AppTheme.successGreen),
                    SizedBox(width: 8),
                    Text('Complete'),
                  ],
                ),
              ),
            PopupMenuItem(
              onTap: onDelete,
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: AppTheme.errorRed),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

/// Task progress indicator
class TaskProgressIndicator extends StatelessWidget {
  final List<TaskEntity> tasks;

  const TaskProgressIndicator({Key? key, required this.tasks})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = tasks.length;
    final completed = tasks
        .where((t) => t.status == TaskStatus.completed)
        .length;
    final progress = total > 0 ? completed / total : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tasks Completed',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppTheme.darkCard,
            valueColor: AlwaysStoppedAnimation(AppTheme.accentCyan),
          ),
        ),
        SizedBox(height: 4),
        Text(
          '$completed / $total',
          style: TextStyle(
            color: AppTheme.accentCyan,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
