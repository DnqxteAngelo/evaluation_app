import 'package:evaluation_app/models/models.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartWidget extends StatelessWidget {
  final Map<Activity, int> activityTallies;

  const PieChartWidget({Key? key, required this.activityTallies})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final studentActivities = activityTallies.entries
        .where((entry) => entry.key.activityPerson == 'S')
        .toList();
    final teacherActivities = activityTallies.entries
        .where((entry) => entry.key.activityPerson == 'T')
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 600;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: _buildChartSection(
                'Student Activities',
                studentActivities,
                isDesktop,
              ),
            ),
            if (isDesktop) const SizedBox(width: 32),
            Expanded(
              child: _buildChartSection(
                'Teacher Activities',
                teacherActivities,
                isDesktop,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartSection(
      String title, List<MapEntry<Activity, int>> entries, bool isDesktop) {
    final totalTally = entries.fold<int>(
        0, (previousValue, entry) => previousValue + entry.value);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: isDesktop
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pie Chart
                Column(
                  children: [
                    Text(title).bold(),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 300,
                          width: 300,
                          child: PieChart(
                            PieChartData(
                              sections: _generateSections(entries, totalTally),
                              centerSpaceRadius: 50,
                              sectionsSpace: 2,
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Legend beside the chart
                        _buildLegend(entries),
                      ],
                    ),
                  ],
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pie Chart
                SizedBox(
                  height: 200,
                  width: 200,
                  child: PieChart(
                    PieChartData(
                      sections: _generateSections(entries, totalTally),
                      centerSpaceRadius: 50,
                      sectionsSpace: 2,
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Legend below the chart
                _buildLegend(entries),
              ],
            ),
    );
  }

  List<PieChartSectionData> _generateSections(
      List<MapEntry<Activity, int>> entries, int totalTally) {
    return entries.map((entry) {
      final activity = entry.key;
      final int value = entry.value;
      final double percentage = (value / totalTally) * 100;

      return PieChartSectionData(
        value: percentage,
        title: '',
        color: _getColor(activity.activityName),
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(List<MapEntry<Activity, int>> entries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entries.map((entry) {
        final activity = entry.key;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                color: _getColor(activity.activityName),
              ),
              const SizedBox(width: 8),
              Text(activity.activityName, style: const TextStyle(fontSize: 12)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getColor(String label) {
    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.yellow,
      Colors.amber,
      Colors.cyan,
    ];
    return colors[label.hashCode % colors.length];
  }
}
