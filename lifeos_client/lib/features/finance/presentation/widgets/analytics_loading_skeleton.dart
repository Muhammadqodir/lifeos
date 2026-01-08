import 'package:shadcn_flutter/shadcn_flutter.dart';

class AnalyticsLoadingSkeleton extends StatelessWidget {
  const AnalyticsLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date picker skeleton
            _buildSkeletonBox(height: 80),
            const SizedBox(height: 20),

            // Summary card skeleton
            _buildSkeletonBox(height: 150),
            const SizedBox(height: 24),

            // Pie chart section skeleton
            Text(
              'Income by Category',
              style: Theme.of(context).typography.large,
            ),
            const SizedBox(height: 12),
            _buildSkeletonBox(height: 400),
            const SizedBox(height: 24),

            // Second pie chart skeleton
            Text(
              'Expense by Category',
              style: Theme.of(context).typography.large,
            ),
            const SizedBox(height: 12),
            _buildSkeletonBox(height: 400),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonBox({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0), // grey[300]
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
