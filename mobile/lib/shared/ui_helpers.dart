import 'package:flutter/material.dart';

import 'theme.dart';

/// "Just now", "5m ago", "3h ago", "2d ago", then a short date.
String timeAgo(DateTime time, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).difference(time);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final sameYear = time.year == (now ?? DateTime.now()).year;
  return '${months[time.month - 1]} ${time.day}${sameYear ? '' : ', ${time.year}'}';
}

/// A confirm dialog for destructive actions. Resolves to true on confirm.
Future<bool> confirmDestructive(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      return AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          title,
          style: JemenaiTheme.fontDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          message,
          style: JemenaiTheme.fontBody(
            fontSize: 14,
            color: theme.jColors.mutedForeground,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: JemenaiTheme.fontBody(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              confirmLabel,
              style: JemenaiTheme.fontBody(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      );
    },
  );
  return result == true;
}
