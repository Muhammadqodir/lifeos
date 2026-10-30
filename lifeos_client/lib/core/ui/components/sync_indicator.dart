import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../sync/sync_engine.dart';
import 'app_header.dart';

/// Gives [AppHeader]s the sync status. The app shell provides it; without
/// one (tests, sign-in screens) headers show no indicator.
class SyncStatusScope extends InheritedWidget {
  const SyncStatusScope({
    super.key,
    required this.status,
    required this.onRetry,
    required super.child,
  });

  final ValueListenable<SyncStatus> status;
  final VoidCallback onRetry;

  static SyncStatusScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SyncStatusScope>();

  @override
  bool updateShouldNotify(SyncStatusScope oldWidget) =>
      status != oldWidget.status;
}

/// A header button that appears only when sync needs attention: offline
/// (changes are kept on the device) or the server keeps failing. Tapping it
/// retries. Normal syncing stays invisible, since nothing waits on it.
class SyncIndicator extends StatelessWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = SyncStatusScope.maybeOf(context);
    if (scope == null) return const SizedBox.shrink();

    return ValueListenableBuilder<SyncStatus>(
      valueListenable: scope.status,
      builder: (context, status, _) {
        final waiting = switch (status.pending) {
          0 => '',
          1 => ' 1 change will sync when you\'re back online.',
          final n => ' $n changes will sync when you\'re back online.',
        };
        return switch (status.phase) {
          SyncPhase.offline => HeaderAction(
            icon: HugeIcons.strokeRoundedWifiDisconnected02,
            tooltip: 'Offline.$waiting Tap to retry.',
            onTap: scope.onRetry,
          ),
          SyncPhase.error => HeaderAction(
            icon: HugeIcons.strokeRoundedAlert02,
            tooltip:
                "Couldn't sync: ${status.message ?? 'server error'}. "
                'Tap to retry.',
            onTap: scope.onRetry,
          ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }
}
