import 'package:evaluation_app/models/models.dart';
import 'package:evaluation_app/components/activity_tally_list.dart';
import 'package:evaluation_app/components/activity_utils.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart'; // Import the utility functions

class ActivitySummaryWidget extends StatelessWidget {
  final List<MapEntry<Activity, int>> studentActivities;
  final List<MapEntry<Activity, int>> teacherActivities;
  final String studentStart;
  final String studentEnd;
  final String teacherStart;
  final String teacherEnd;

  const ActivitySummaryWidget({
    Key? key,
    required this.studentActivities,
    required this.teacherActivities,
    required this.studentStart,
    required this.studentEnd,
    required this.teacherStart,
    required this.teacherEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate percentages for students and teachers
    double studentPercentage =
        calculatePercentage(studentActivities, studentStart, studentEnd);
    double teacherPercentage =
        calculatePercentage(teacherActivities, teacherStart, teacherEnd);

    return LayoutBuilder(builder: (context, constraints) {
      bool isDesktop = constraints.maxWidth > 600;

      return isDesktop
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student Actions
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Student Actions').bold().medium(),
                      const SizedBox(height: 4),
                      ActivityTallyList(activities: studentActivities),
                      const SizedBox(height: 4),
                      Text(
                        '% of Student Actions: ${studentPercentage.toStringAsFixed(2)}%',
                      ).semiBold().small(),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Teacher Actions
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Teacher Actions').bold().medium(),
                      const SizedBox(height: 4),
                      ActivityTallyList(activities: teacherActivities),
                      const SizedBox(height: 4),
                      Text(
                        '% of Teacher Actions: ${teacherPercentage.toStringAsFixed(2)}%',
                      ).semiBold().small(),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Student Actions').bold().small(),
                    const SizedBox(height: 4),
                    ActivityTallyList(activities: studentActivities),
                    const SizedBox(height: 4),
                    Text(
                      '% of Student Actions: ${studentPercentage.toStringAsFixed(2)}%',
                    ).semiBold().xSmall(),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Teacher Actions').bold().small(),
                    const SizedBox(height: 4),
                    ActivityTallyList(activities: teacherActivities),
                    const SizedBox(height: 4),
                    Text(
                      '% of Teacher Actions: ${teacherPercentage.toStringAsFixed(2)}%',
                    ).semiBold().xSmall(),
                  ],
                ),
              ],
            );
    });
  }
}
