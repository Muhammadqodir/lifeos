import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../ui/app_theme_x.dart';
import '../ui/components/app_badge.dart';
import '../ui/tokens.dart';

/// Configuration for a single Kanban column.
class KanbanColumnConfig<T> {
  final String title;
  final List<T> items;
  final Color color;

  /// When false, the column acts as read-only — it renders items but
  /// does not accept drag-and-drop.
  final bool isDroppable;

  const KanbanColumnConfig({
    required this.title,
    required this.items,
    required this.color,
    this.isDroppable = true,
  });
}

/// A generic, reusable Kanban board that renders [columns] side-by-side.
///
/// Each item in a column is wrapped in a [Draggable] automatically.
/// Drop targets are handled per-column via [onItemDropped].
///
/// Type parameter [T] is the item type for every column.
class KanbanBoard<T extends Object> extends StatelessWidget {
  const KanbanBoard({
    super.key,
    required this.columns,
    required this.itemBuilder,
    required this.feedbackBuilder,
    required this.onItemDropped,
    this.columnGap = AppSpacing.md,
    this.emptyText = 'No items',
    this.padding = EdgeInsets.zero,
  });

  final List<KanbanColumnConfig<T>> columns;

  /// Builds the card widget for each item.
  /// [isDragging] is `true` when used as the [Draggable.childWhenDragging].
  final Widget Function(BuildContext context, T item, bool isDragging)
  itemBuilder;

  /// Builds the floating ghost widget while the item is being dragged.
  /// [width] matches the column width so the ghost fits neatly.
  final Widget Function(BuildContext context, T item, double width)
  feedbackBuilder;

  /// Called when an item is dropped into a column.
  /// [targetColumnIndex] is the index of the target column in [columns].
  final void Function(T item, int targetColumnIndex) onItemDropped;

  final double columnGap;

  /// Text shown in an empty column.
  final String emptyText;

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalGap = columnGap * (columns.length - 1);
          final columnWidth =
              (constraints.maxWidth - totalGap) / columns.length;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < columns.length; i++) ...[
                SizedBox(
                  width: columnWidth,
                  child: KanbanColumn<T>(
                    config: columns[i],
                    columnWidth: columnWidth,
                    itemBuilder: itemBuilder,
                    feedbackBuilder: feedbackBuilder,
                    emptyText: emptyText,
                    onItemDropped: (item) => onItemDropped(item, i),
                  ),
                ),
                if (i < columns.length - 1) SizedBox(width: columnGap),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// A single column inside a [KanbanBoard].
///
/// Manages its own hover/highlight state during drag operations.
class KanbanColumn<T extends Object> extends StatefulWidget {
  const KanbanColumn({
    super.key,
    required this.config,
    required this.columnWidth,
    required this.itemBuilder,
    required this.feedbackBuilder,
    required this.onItemDropped,
    this.emptyText = 'No items',
  });

  final KanbanColumnConfig<T> config;
  final double columnWidth;
  final Widget Function(BuildContext context, T item, bool isDragging)
  itemBuilder;
  final Widget Function(BuildContext context, T item, double width)
  feedbackBuilder;
  final void Function(T item) onItemDropped;
  final String emptyText;

  @override
  State<KanbanColumn<T>> createState() => _KanbanColumnState<T>();
}

class _KanbanColumnState<T extends Object> extends State<KanbanColumn<T>> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final col = widget.config;

    return DragTarget<T>(
      onWillAcceptWithDetails: (_) => col.isDroppable,
      onAcceptWithDetails: (details) {
        setState(() => _isHovered = false);
        widget.onItemDropped(details.data);
      },
      onMove: (_) {
        if (col.isDroppable && !_isHovered) {
          setState(() => _isHovered = true);
        }
      },
      onLeave: (_) {
        if (_isHovered) setState(() => _isHovered = false);
      },
      builder: (context, _, __) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _isHovered
                ? col.color.withValues(alpha: 0.07)
                : colorScheme.muted.withValues(alpha: 0.4),
            border: Border.all(
              color: _isHovered
                  ? col.color.withValues(alpha: 0.55)
                  : colorScheme.border,
              width: _isHovered ? 2 : 1,
            ),
            borderRadius: theme.cardRadius,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, theme, colorScheme),
              _buildItems(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final col = widget.config;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md - 2,
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: col.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              col.title,
              style: context.text.label.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          AppBadge.count(col.items.length),
        ],
      ),
    );
  }

  Widget _buildItems(BuildContext context) {
    final col = widget.config;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        0,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: col.items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Text(widget.emptyText, style: context.text.caption),
              ),
            )
          : Column(
              children: col.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm - 2),
                  child: Draggable<T>(
                    data: item,
                    feedback: widget.feedbackBuilder(
                      context,
                      item,
                      widget.columnWidth,
                    ),
                    childWhenDragging: widget.itemBuilder(context, item, true),
                    child: widget.itemBuilder(context, item, false),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
