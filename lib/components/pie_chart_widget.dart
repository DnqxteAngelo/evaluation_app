// ignore_for_file: unnecessary_null_comparison

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

        return isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: _ChartSection(
                      title: 'Student Activities',
                      entries: studentActivities,
                      isDesktop: isDesktop,
                    ),
                  ),
                  if (isDesktop) const SizedBox(width: 32),
                  Expanded(
                    child: _ChartSection(
                      title: 'Teacher Activities',
                      entries: teacherActivities,
                      isDesktop: isDesktop,
                    ),
                  ),
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _ChartSection(
                      title: 'Student Activities',
                      entries: studentActivities,
                      isDesktop: isDesktop,
                    ),
                    const SizedBox(height: 32),
                    _ChartSection(
                      title: 'Teacher Activities',
                      entries: teacherActivities,
                      isDesktop: isDesktop,
                    ),
                  ],
                ),
              );
      },
    );
  }
}

class _ChartSection extends StatefulWidget {
  final String title;
  final List<MapEntry<Activity, int>> entries;
  final bool isDesktop;

  const _ChartSection({
    Key? key,
    required this.title,
    required this.entries,
    required this.isDesktop,
  }) : super(key: key);

  @override
  __ChartSectionState createState() => __ChartSectionState();
}

class __ChartSectionState extends State<_ChartSection> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final totalTally = widget.entries
        .fold<int>(0, (previousValue, entry) => previousValue + entry.value);

    // Filter entries to exclude 0% sections for the chart
    final filteredEntries =
        widget.entries.where((entry) => entry.value > 0).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: widget.isDesktop
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Text(widget.title).bold(),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 300,
                          width: 300,
                          child: PieChart(
                            PieChartData(
                              sections: _generateSections(
                                  filteredEntries, totalTally),
                              centerSpaceRadius: 50,
                              sectionsSpace: 2,
                              borderData: FlBorderData(show: false),
                              pieTouchData: PieTouchData(
                                touchCallback: (event, response) {
                                  setState(() {
                                    if (response != null &&
                                        response.touchedSection != null) {
                                      final touchedIndex = response
                                          .touchedSection!.touchedSectionIndex;
                                      if (touchedIndex != null &&
                                          touchedIndex <
                                              filteredEntries.length) {
                                        _hoveredIndex = touchedIndex;
                                      } else {
                                        _hoveredIndex = null;
                                      }
                                    } else {
                                      _hoveredIndex = null;
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        _buildLegend(widget.entries),
                      ],
                    ),
                  ],
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.title).bold(),
                const SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  width: 200,
                  child: PieChart(
                    PieChartData(
                      sections: _generateSections(filteredEntries, totalTally),
                      centerSpaceRadius: 50,
                      sectionsSpace: 2,
                      borderData: FlBorderData(show: false),
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          setState(() {
                            if (response != null &&
                                response.touchedSection != null) {
                              final touchedIndex =
                                  response.touchedSection!.touchedSectionIndex;
                              if (touchedIndex != null &&
                                  touchedIndex < filteredEntries.length) {
                                _hoveredIndex = touchedIndex;
                              } else {
                                _hoveredIndex = null;
                              }
                            } else {
                              _hoveredIndex = null;
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildLegend(widget.entries),
              ],
            ),
    );
  }

  List<PieChartSectionData> _generateSections(
      List<MapEntry<Activity, int>> entries, int totalTally) {
    return entries.asMap().entries.map((entry) {
      final index = entry.key;
      final activity = entry.value.key;
      final int value = entry.value.value;
      final double percentage = (value / totalTally) * 100;

      return PieChartSectionData(
        value: percentage,
        title:
            _hoveredIndex == index ? '${percentage.toStringAsFixed(1)}%' : '',
        color: _getColor(activity.activityName),
        radius: _hoveredIndex == index ? 60 : 50,
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
