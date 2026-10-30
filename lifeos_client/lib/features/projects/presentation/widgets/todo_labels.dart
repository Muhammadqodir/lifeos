import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/ui/ui.dart';

/// Human labels and colours for todo enums, shared by every todo screen.
abstract final class TodoLabels {
  static String status(String value) => switch (value) {
    'inbox' => 'Inbox',
    'planned' => 'Planned',
    'in_progress' => 'In progress',
    'blocked' => 'Blocked',
    'done' => 'Done',
    _ => value,
  };

  static Color statusColor(BuildContext context, String value) {
    final semantic = context.semantic;
    return switch (value) {
      'planned' => semantic.info,
      'in_progress' => semantic.warning,
      'blocked' => semantic.danger,
      'done' => semantic.success,
      _ => semantic.neutral,
    };
  }

  /// Priority and urgency share the low / middle / high scale.
  static String level(String value) => switch (value) {
    'low' => 'Low',
    'middle' => 'Medium',
    'high' => 'High',
    _ => value,
  };

  static Color levelColor(BuildContext context, String value) {
    final semantic = context.semantic;
    return switch (value) {
      'high' => semantic.danger,
      'middle' => semantic.warning,
      _ => semantic.neutral,
    };
  }

  static String energy(String value) => switch (value) {
    'easy' => 'Easy',
    'medium' => 'Medium',
    'hard' => 'Hard',
    _ => value,
  };
}
