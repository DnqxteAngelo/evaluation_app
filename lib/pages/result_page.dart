import 'package:evaluation_app/components/activity_summary.dart';
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

  @override
  Widget build(BuildContext context) {
    print(widget.activityTallies);
    final studentActivities = widget.activityTallies.entries
        .where((entry) => entry.key.activityPerson == 'S')
        .toList();
    final teacherActivities = widget.activityTallies.entries
        .where((entry) => entry.key.activityPerson == 'T')
        .toList();

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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          padding: const EdgeInsets.all(24),
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
                          PieChartWidget(
                              activityTallies: widget.activityTallies),
                          const SizedBox(height: 16),
                          ActivitySummaryWidget(
                            studentActivities: studentActivities,
                            teacherActivities: teacherActivities,
                            studentStart: 'Individual Thinking',
                            studentEnd: 'Test/Quiz',
                            teacherStart: 'Moving/Guiding',
                            teacherEnd: 'Demonstrate/Video',
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
        ),
      ),
    );
  }
}
