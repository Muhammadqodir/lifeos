import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/features/navigation/presentation/widgets/custom_app_bar.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  String type = 'strength';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        CustomAppBar(
          title: 'Start workout',
          leftActions: [
            AppBarAction(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              tooltip: 'Back',
              onTap: () async {
                final bool? confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Confirm Exit'),
                      content: const Text(
                        'Are you sure you want to exit the workout? Your progress will not be saved.',
                      ),
                      actions: [
                        // Secondary action to cancel/dismiss.
                        OutlineButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                        ),
                        // Primary action to accept/confirm.
                        PrimaryButton(
                          child: const Text('Exit'),
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                        ),
                      ],
                    );
                  },
                );
                if (mounted) {
                  if (confirmed ?? false) {
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
          ],
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select Workout Type',
              style: Theme.of(context).typography.small,
            ),
            SizedBox(height: 8),
            RadioGroup<String>(
              onChanged: (value) {
                setState(() {
                  type = value;
                });
              },
              value: type,
              child: Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: RadioCard(
                      value: 'strength',
                      child: Basic(
                        titleAlignment: Alignment.center,
                        contentAlignment: Alignment.center,
                        title: HugeIcon(
                          icon: HugeIcons.strokeRoundedDumbbell01,
                          size: 24,
                        ),
                        content: Text(
                          'Strength',
                          style: Theme.of(context).typography.normal,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: RadioCard(
                      value: 'cardio',
                      child: Basic(
                        titleAlignment: Alignment.center,
                        contentAlignment: Alignment.center,
                        title: HugeIcon(
                          icon: HugeIcons.strokeRoundedRunningShoes,
                          size: 24,
                        ),
                        content: Text(
                          'Cardio',
                          style: Theme.of(context).typography.normal,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: RadioCard(
                      value: 'mixed',
                      child: Basic(
                        titleAlignment: Alignment.center,
                        contentAlignment: Alignment.center,
                        title: HugeIcon(
                          icon: HugeIcons.strokeRoundedGeometricShapes01,
                          size: 24,
                        ),
                        content: Text(
                          'Mixed',
                          style: Theme.of(context).typography.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            PrimaryButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedPlay,
                    size: 18,
                    strokeWidth: 2.5,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Start',
                    style: Theme.of(
                      context,
                    ).typography.small.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              onPressed: () {},
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Exercises:',
                    style: Theme.of(
                      context,
                    ).typography.small.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton.primary(
                  size: ButtonSize.normal,
                  onPressed: () {},
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedAdd01,
                    size: 16,
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
