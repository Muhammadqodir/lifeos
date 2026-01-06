import 'package:flutter/cupertino.dart';
import 'package:lifeos_client/features/navigation/presentation/widgets/custom_app_bar.dart';
import 'package:lifeos_client/utils/toast.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';

class GymMainPage extends StatefulWidget {
  const GymMainPage({super.key});

  @override
  State<GymMainPage> createState() => _GymMainPageState();
}

class _GymMainPageState extends State<GymMainPage> {
  final GlobalKey<RefreshTriggerState> _refreshTriggerKey =
      GlobalKey<RefreshTriggerState>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppBar(
          title: "Health",
          rightActions: [
            AppBarAction(
              icon: HugeIcons.strokeRoundedPlay,
              tooltip: 'Start Workout',
              onTap: () {},
            ),
            AppBarAction(
              icon: HugeIcons.strokeRoundedChartUp,
              tooltip: 'Progress',
              onTap: () {},
            ),
            AppBarAction(
              icon: HugeIcons.strokeRoundedDatabaseSetting,
              tooltip: 'Gym Settings',
              onTap: () {},
            ),
          ],
        ),
        Expanded(
          child: RefreshTrigger(
            key: _refreshTriggerKey,
            onRefresh: () async {
              // Refresh gym page
              // Wait a bit for the refresh to complete
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: _buildBody(context),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // if (state is FinanceHomeLoading || state is FinanceHomeInitial) {
    //   return const LoadingState(message: "Loading...");
    // }

    // if (state is FinanceHomeFailure) {
    //   return ErrorState(
    //     message: state.message,
    //     onRetry: () {
    //       context.read<FinanceHomeBloc>().add(const FinanceHomeRetried());
    //     },
    //   );
    // }

    // if (state is FinanceHomeEmpty) {
    //   return EmptyState(
    //     title: 'No Health Data',
    //     description: 'Start by adding your first health record',
    //     icon: HugeIcon(icon: HugeIcons.strokeRoundedBodyPartMuscle, size: 24),
    //     action: PrimaryButton(
    //       onPressed: () => _navigateToAddHealthRecord(context),
    //       child: const Text('Add Health Record'),
    //     ),
    //   );
    // }

    // At this point, state must be FinanceHomeSuccess
    return CustomScrollView(slivers: [
        
      ],
    );
  }

  void _showComingSoonToast(BuildContext context, String feature) {
    showToast(
      context: context,
      builder: (context, overlay) => Utils.buildToast(
        context,
        overlay,
        'Coming Soon',
        '$feature feature is not yet implemented',
      ),
      location: ToastLocation.topCenter,
    );
  }
}
