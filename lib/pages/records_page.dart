import 'package:evaluation_app/components/pie_chart_widget.dart';
import 'package:evaluation_app/models/models.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecordsPage extends StatefulWidget {
  const RecordsPage({Key? key}) : super(key: key);

  @override
  _RecordsPageState createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  final Map<Activity, int> _activityTallies = {};
  EvaluationDetails? _evaluationDetails;

  List<Teacher> _teachers = [];
  List<Semester> _semesters = [];
  List<SchoolYear> _schoolyear = [];
  List<Period> _period = [];

  int? selectedPeriodId;
  int? selectedTeacherId;
  int? selectedSemesterId;
  int? selectedSchoolyearId;

  bool _isLoading = true;
  String _errorMessage = '';
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _fetchTeachers(),
        _fetchSchoolYears(),
        _fetchPeriods(),
        _fetchSemesters(),
      ]);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load data. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<List<T>> _fetchSelect<T>({
    required String url,
    required Map<String, String> body,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: body,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => fromJson(item)).toList();
      } else {
        throw Exception('Failed to load ${T.toString()}');
      }
    } catch (e) {
      print('Error fetching ${T.toString()}: $e');
      return [];
    }
  }

  Future<void> _fetchTeachers() async {
    final teachers = await _fetchSelect<Teacher>(
      url: 'http://localhost/evaluation_app_api/teacher.php',
      body: {'operation': 'getTeacher'},
      fromJson: (json) => Teacher(
        teacherId: json['teacher_id'],
        teacherName: json['teacher_fullname'],
        collegeName: json['college_name'],
      ),
    );
    setState(() => _teachers = teachers);
  }

  Future<void> _fetchSemesters() async {
    final semesters = await _fetchSelect<Semester>(
      url: 'http://localhost/evaluation_app_api/evaluation.php',
      body: {'operation': 'getSemester'},
      fromJson: (json) => Semester(
        semesterId: json['sem_id'],
        semesterName: json['sem_name'],
      ),
    );
    setState(() => _semesters = semesters);
  }

  Future<void> _fetchSchoolYears() async {
    final schoolyears = await _fetchSelect<SchoolYear>(
      url: 'http://localhost/evaluation_app_api/evaluation.php',
      body: {'operation': 'getSchoolYear'},
      fromJson: (json) => SchoolYear(
        syId: json['sy_id'],
        syName: json['sy_name'],
      ),
    );
    setState(() => _schoolyear = schoolyears);
  }

  Future<void> _fetchPeriods() async {
    final periods = await _fetchSelect<Period>(
      url: 'http://localhost/evaluation_app_api/evaluation.php',
      body: {'operation': 'getPeriod'},
      fromJson: (json) => Period(
        periodId: json['period_id'],
        periodName: json['period_name'],
      ),
    );
    setState(() => _period = periods);
  }

  // Future<EvaluationDetails?> fetchEvaluationDetails() async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('http://localhost/evaluation_app_api/evaluation.php'),
  //       body: {
  //         'operation': 'getEvaluationDetails',
  //         'json': json.encode({
  //           'eval_periodId': selectedPeriodId,
  //           'eval_teacherId': selectedTeacherId,
  //           'eval_semesterId': selectedSemesterId,
  //           'eval_schoolyearId': selectedSchoolyearId,
  //         }),
  //       },
  //     );

  //     print(response.body);

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);

  //       print(data);
  //       if (data.isNotEmpty) {
  //         return EvaluationDetails.fromJson(data[0]); // Parse first element
  //       } else {
  //         print('No data found.');
  //       }
  //     } else {
  //       print('Failed to fetch evaluation details: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error fetching evaluation details: $e');
  //   }
  //   return null; // Return null if no data or error occurs
  // }

  // Future<void> _loadEvaluationDetails() async {
  //   final details = await fetchEvaluationDetails();
  //   setState(() {
  //     _evaluationDetails = details;
  //   });
  // }

  // Widget _buildEvaluationCard() {
  //   return Expanded(
  //     child: Row(
  //       children: [
  //         Text(
  //           'Teacher: ${_evaluationDetails?.teacherFullname ?? ' '}',
  //         ),
  //         const SizedBox(width: 8),
  //         Text(
  //           'Subject: ${_evaluationDetails?.evalSubject ?? ' '}',
  //         ),
  //         const SizedBox(width: 8),
  //         Text(
  //           'Date: ${_evaluationDetails?.evalDate ?? ' '}',
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Future<void> fetchActivityTallies() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/evaluation_app_api/evaluation.php'),
        body: {
          'operation': 'getEvaluationRecords',
          'json': json.encode(
            {
              'eval_periodId': selectedPeriodId,
              'eval_teacherId': selectedTeacherId,
              'eval_semesterId': selectedSemesterId,
              'eval_schoolyearId': selectedSchoolyearId,
            },
          ),
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> tallies = json.decode(response.body);
        setState(() {
          // Process each tally
          for (var tally in tallies) {
            String actId = tally['trans_actId'].toString();
            String actName = tally['act_name'] ?? 'Unknown'; // Default if null
            String actCode = tally['act_code'] ?? 'N/A'; // Default if null
            String actPerson =
                tally['act_person'] ?? 'Unknown'; // Default if null
            int count = int.tryParse(tally['tally'].toString()) ??
                0; // Default to 0 if null

            // Create a new Activity object (if necessary)
            Activity activity = Activity(
              activityId: int.parse(actId),
              activityName: actName,
              activityCode: actCode,
              activityPerson: actPerson,
              tally: count,
            );

            _activityTallies[activity] =
                count; // Store the tally with the activity as key
          }
        });
      } else {
        print('Failed to load tallies: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching tallies: $e');
    }
  }

  Widget _buildSelect<T>({
    required String label,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
    required String Function(T item) itemDisplay,
    required BoxConstraints popupConstraints,
  }) {
    return SizedBox(
      width: 300, // Adjust width as needed
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black),
          ).semiBold().small(), // Reusable label
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            child: Select<T>(
              itemBuilder: (context, item) {
                return Text(itemDisplay(item)); // Display the item name
              },
              searchFilter: (item, query) {
                return itemDisplay(item)
                        .toLowerCase()
                        .contains(query.toLowerCase())
                    ? 1
                    : 0;
              },
              autoClosePopover: true,
              popupConstraints: popupConstraints,
              onChanged: onChanged,
              value: value,
              placeholder: Align(
                alignment: Alignment.centerLeft, // Align to the start
                child: Text('Select $label',
                    style: const TextStyle(color: Colors.gray),
                    selectionColor: Colors.gray),
              ),
              children: items
                  .map((item) => SelectItemButton(
                        value: item,
                        child: Text(itemDisplay(item)),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  void open(BuildContext context, int count) {
    openDrawer(
      context: context,
      showDragHandle: false,
      expands: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildSelect<int>(
                    label: 'Teacher',
                    value: selectedTeacherId,
                    items: _teachers.map((t) => t.teacherId).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTeacherId = value;
                      });
                    },
                    itemDisplay: (id) {
                      final teacher =
                          _teachers.firstWhere((t) => t.teacherId == id);
                      return teacher.teacherName;
                    },
                    popupConstraints:
                        const BoxConstraints(maxHeight: 300, maxWidth: 300),
                  ),
                  const SizedBox(height: 16),
                  _buildSelect<int>(
                    label: 'School Year',
                    value: selectedSchoolyearId,
                    items: _schoolyear.map((sy) => sy.syId).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSchoolyearId = value;
                      });
                    },
                    itemDisplay: (id) {
                      final schoolyear =
                          _schoolyear.firstWhere((sy) => sy.syId == id);
                      return schoolyear.syName;
                    },
                    popupConstraints:
                        const BoxConstraints(maxHeight: 300, maxWidth: 300),
                  ),
                  const SizedBox(height: 16),
                  _buildSelect<int>(
                    label: 'Semester',
                    value: selectedSemesterId,
                    items: _semesters.map((s) => s.semesterId).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSemesterId = value;
                      });
                    },
                    itemDisplay: (id) {
                      final semester =
                          _semesters.firstWhere((s) => s.semesterId == id);
                      return semester.semesterName;
                    },
                    popupConstraints:
                        const BoxConstraints(maxHeight: 300, maxWidth: 300),
                  ),
                  const SizedBox(height: 16),
                  _buildSelect<int>(
                    label: 'Period',
                    value: selectedPeriodId,
                    items: _period.map((p) => p.periodId).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPeriodId = value;
                      });
                    },
                    itemDisplay: (id) {
                      final period =
                          _period.firstWhere((p) => p.periodId == id);
                      return period.periodName;
                    },
                    popupConstraints:
                        const BoxConstraints(maxHeight: 300, maxWidth: 300),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    onPressed: () {
                      fetchActivityTallies();
                      // _loadEvaluationDetails();
                    },
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            );
          },
        );
      },
      position: OverlayPosition.right,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage),
              PrimaryButton(
                onPressed: _initializeData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Results'),
          leading: [
            OutlineButton(
              onPressed: () {
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Evaluation Card and Filter Button in a Row
                    // _buildEvaluationCard(),
                    PrimaryButton(
                      onPressed: () {
                        open(context, 0);
                      },
                      trailing: const Icon(BootstrapIcons.filter),
                      child: const Text("Filter"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Activity Tallies or No Records Message
                _activityTallies.isNotEmpty
                    ? PieChartWidget(activityTallies: _activityTallies)
                    : Center(
                        child: const Text("No records found.").bold().large(),
                      ),
              ],
            ),
          ),
        ).intrinsic(),
      ),
    );
  }
}
