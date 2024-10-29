import 'package:evaluation_app/components/activity_summary.dart';
import 'package:evaluation_app/components/activity_table.dart';
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
  late Future<Map<String, dynamic>> _activityData;

  @override
  void initState() {
    super.initState();
    _evaluationDetails = fetchEvaluationDetails(widget.evalId);
    _activityData = fetchActivityData(widget.evalId);
  }

  Future<Map<String, dynamic>> fetchActivityData(int evalId) async {
    final url =
        '${DatabaseURL.databaseURL}/transaction.php?operation=getTransactions&evalId=$evalId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load activity data');
    }
  }

  Future<List<dynamic>> fetchEvaluationDetails(int evalId) async {
    String url = "${DatabaseURL.databaseURL}/evaluation.php";

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
    final studentActivities = widget.activityTallies.entries
        .where((entry) => entry.key.activityPerson == 'S')
        .toList();
    final teacherActivities = widget.activityTallies.entries
        .where((entry) => entry.key.activityPerson == 'T')
        .toList();

    bool isMobile = MediaQuery.of(context).size.width < 1000;

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
                          FutureBuilder<Map<String, dynamic>>(
                            future: _activityData,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else if (snapshot.hasData) {
                                // Use empty lists if data is null
                                final studentHeaders = List<String>.from(
                                    snapshot.data!['studentHeaders'] ?? []);
                                final teacherHeaders = List<String>.from(
                                    snapshot.data!['teacherHeaders'] ?? []);
                                final studentData = List<List<int?>>.from(
                                    (snapshot.data!['studentData'] ?? []).map(
                                        (row) => List<int?>.from(row ?? [])));
                                final teacherData = List<List<int?>>.from(
                                    (snapshot.data!['teacherData'] ?? []).map(
                                        (row) => List<int?>.from(row ?? [])));
                                final timeRanges = List<String>.from(
                                    snapshot.data!['timeRanges'] ?? []);

                                return isMobile
                                    ? Column(
                                        children: [
                                          ActivityTable(
                                            title: 'Student Activities',
                                            data: studentData,
                                            headers: studentHeaders,
                                            timeRanges: timeRanges,
                                          ),
                                          const SizedBox(
                                              height:
                                                  20), // Add space between tables
                                          ActivityTable(
                                            title: 'Teacher Activities',
                                            data: teacherData,
                                            headers: teacherHeaders,
                                            timeRanges: timeRanges,
                                          ),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          Expanded(
                                            child: ActivityTable(
                                              title: 'Student Activities',
                                              data: studentData,
                                              headers: studentHeaders,
                                              timeRanges: timeRanges,
                                            ),
                                          ),
                                          const SizedBox(
                                              width:
                                                  20), // Add space between tables
                                          Expanded(
                                            child: ActivityTable(
                                              title: 'Teacher Activities',
                                              data: teacherData,
                                              headers: teacherHeaders,
                                              timeRanges: timeRanges,
                                            ),
                                          ),
                                        ],
                                      ).gap(2);
                              } else {
                                return const Center(
                                    child: Text('No data found.'));
                              }
                            },
                          ),
                          const SizedBox(height: 16),
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
