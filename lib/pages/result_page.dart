import 'package:evaluation_app/components/pie_chart_widget.dart';
import 'package:evaluation_app/models/models.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ResultPage extends StatefulWidget {
  final Map<Activity, int> activityTallies;
  final int evalId;

  const ResultPage({
    Key? key,
    required this.activityTallies,
    required this.evalId,
  }) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late Future<List<dynamic>> _evaluationDetails;

  @override
  void initState() {
    super.initState();
    _evaluationDetails = fetchEvaluationDetails(widget.evalId);
  }

  Future<List<dynamic>> fetchEvaluationDetails(int evalId) async {
    String url = "http://localhost/evaluation_app_api/evaluation.php";

    final Map<String, dynamic> jsonData = {
      "eval_id": evalId.toString(),
    };

    http.Response response = await http.post(
      Uri.parse(url),
      body: {
        "json": jsonEncode(jsonData),
        "operation": "getEvaluation",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load evaluation details');
    }
  }

  // Calculate the sum of a specific range of activities
  int _calculateSumInRange(
      List<MapEntry<Activity, int>> activities, String start, String end) {
    bool inRange = false;
    int sum = 0;

    for (var entry in activities) {
      if (entry.key.activityName == start) {
        inRange = true; // Start summing from this point
      }
      if (inRange) {
        sum += entry.value;
      }
      if (entry.key.activityName == end) {
        break; // Stop summing after reaching the end
      }
    }
    return sum;
  }

  double _calculatePercentage(
      List<MapEntry<Activity, int>> activities, String start, String end) {
    int rangeSum = _calculateSumInRange(activities, start, end);
    int totalSum = activities.fold(0, (sum, entry) => sum + entry.value);

    // Avoid division by zero
    return totalSum == 0 ? 0 : (rangeSum / totalSum) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final studentActivities = widget.activityTallies.entries
        .where((entry) => entry.key.activityPerson == 'S')
        .toList();
    final teacherActivities = widget.activityTallies.entries
        .where((entry) => entry.key.activityPerson == 'T')
        .toList();

    // Calculate percentages for students and teachers
    double studentPercentage = _calculatePercentage(
        studentActivities, 'Individual Thinking', 'Test/Quiz');
    double teacherPercentage = _calculatePercentage(
        teacherActivities, 'Moving/Guiding', 'Demonstrate/Video');

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Results'),
          leading: [
            OutlineButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              density: ButtonDensity.icon,
              child: const Icon(RadixIcons.arrowLeft),
            ),
          ],
        ),
        const Divider(),
      ],
      child: Center(
        child: FutureBuilder<List<dynamic>>(
          future: _evaluationDetails,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              var evaluationData = snapshot.data!.first;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Teacher Name: ${evaluationData['teacher_fullname']}'),
                      Text('Subject: ${evaluationData['eval_subject']}'),
                      Text('Date: ${evaluationData['eval_date']}'),
                      const Divider(),
                      const SizedBox(height: 24),
                      PieChartWidget(activityTallies: widget.activityTallies),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Student Actions
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text('Student Actions').bold().medium(),
                                const SizedBox(height: 4),
                                _buildActivityList(studentActivities),
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
                                _buildActivityList(teacherActivities),
                                const SizedBox(height: 4),
                                Text(
                                  '% of Teacher Actions: ${teacherPercentage.toStringAsFixed(2)}%',
                                ).semiBold().small(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }
            return const Text('No data found.');
          },
        ),
      ),
    );
  }

  Widget _buildActivityList(List<MapEntry<Activity, int>> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: activities.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Container(
            width: 250,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key.activityName).semiBold().small(),
                Text(entry.value.toString()).small(),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
