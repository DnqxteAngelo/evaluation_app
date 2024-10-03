// ignore_for_file: use_super_parameters, library_private_types_in_public_api, prefer_const_constructors, avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:evaluation_app/components/toast.dart';
import 'package:http/http.dart' as http;
import 'package:shadcn_flutter/shadcn_flutter.dart';

class EvaluationPage extends StatefulWidget {
  final int evalId;

  EvaluationPage({
    required this.evalId,
  });

  @override
  _EvaluationPageState createState() => _EvaluationPageState();
}

class _EvaluationPageState extends State<EvaluationPage> {
  late Future<Map<String, List<Map<String, String>>>> _activitiesFuture;
  Map<String, int> _activityTallies = {};
  List<CheckboxState> _studentChecked = [];
  List<CheckboxState> _teacherChecked = [];
  List<Map<String, String>> studentActivities = [];
  List<Map<String, String>> teacherActivities = [];

  Timer? _timer;
  DateTime? _currentTime;

  List<dynamic> _timeRanges = [];
  int _currentRangeIndex = 0;
  Timer? _range;

  DateTime? _startTime;

  Map<String, String> comments = {};
  TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _activitiesFuture =
        fetchActivities(); // Fetch activities when the widget initializes
    _startTime = getPhilippineTime();
    _fetchTimeRanges();
  }

  Future<void> fetchActivityTallies() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/evaluation_app_api/transaction.php'),
        body: {
          'operation': 'countActivityTally',
          'json': json.encode({'trans_evalId': widget.evalId.toString()}),
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> tallies = json.decode(response.body);
        setState(() {
          // Reset tallies
          _activityTallies.clear();

          // Process each tally
          for (var tally in tallies) {
            String actId = tally['trans_actId'].toString();
            int count = int.parse(tally['tally'].toString());
            _activityTallies[actId] = count;
          }
        });
      } else {
        print('Failed to load tallies');
      }
    } catch (e) {
      print('Error fetching tallies: $e');
    }
  }

  Future<void> _fetchTimeRanges() async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://localhost/evaluation_app_api/transaction.php'), // Replace with your server URL
        body: {'operation': 'getTimeRange'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _timeRanges = json.decode(response.body);
          // Start the range update after fetching the data
          // _startRange();
        });
      } else {
        throw Exception('Failed to load time ranges');
      }
    } catch (e) {
      print(e);
    }
  }

  DateTime getPhilippineTime() {
    return DateTime.now()
        .toUtc()
        .add(const Duration(hours: 8)); // Convert to PHT
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime =
            getPhilippineTime(); // Update to current Philippine time every second
      });

      // Stop both timers after 90 minutes
      if (_hasExceededTimeLimit()) {
        _stopTimers();
      }
    });
  }

  void _startRange() {
    _range = Timer.periodic(const Duration(minutes: 2), (timer) async {
      // Add transactions for current time range if any activities are checked
      await _addTransactions();

      setState(() {
        _currentRangeIndex = (_currentRangeIndex + 1) % _timeRanges.length;
      });

      _resetCheckboxes();

      // Stop the timer after 90 minutes
      if (_hasExceededTimeLimit()) {
        _stopRange();
      }
    });
  }

  bool _hasExceededTimeLimit() {
    final elapsedMinutes =
        getPhilippineTime().difference(_startTime!).inMinutes;
    return elapsedMinutes >= 90; // Check if 90 minutes have passed
  }

  void _stopTimers() {
    _stopTimer();
    _stopRange();
  }

  void _stopRange() {
    if (_range != null) {
      _range!.cancel(); // Stop the timer
    }
    setState(() {
      _currentRangeIndex = 0; // Reset the index
    });
  }

  void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    setState(() {
      _currentTime = null;
    });
  }

  void _resetCheckboxes() {
    setState(() {
      _studentChecked =
          List.filled(_studentChecked.length, CheckboxState.unchecked);
      _teacherChecked =
          List.filled(_teacherChecked.length, CheckboxState.unchecked);
    });
  }

  String _formatCurrentTime() {
    if (_currentTime == null) return "00:00:00"; // Set the initial time
    final hours = _currentTime!.hour.toString().padLeft(2, '0');
    final minutes = _currentTime!.minute.toString().padLeft(2, '0');
    final seconds = _currentTime!.second.toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds'; // Format as HH:MM:SS
  }

  String _formatTimeRange() {
    if (_timeRanges.isNotEmpty) {
      return _timeRanges[_currentRangeIndex]['time_range'];
    }
    return 'Loading...';
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when disposing
    _range?.cancel();
    super.dispose();
  }

  bool _hasCheckedActivities() {
    return _studentChecked.contains(CheckboxState.checked) ||
        _teacherChecked.contains(CheckboxState.checked);
  }

  Future<void> _addTransactions() async {
    if (!_hasCheckedActivities()) return; // Exit if no activities are checked

    final url =
        Uri.parse('http://localhost/evaluation_app_api/transaction.php');

    List<Map<String, String>> allTransactions = []; // Store as Strings

    // Add student activities
    for (int i = 0; i < _studentChecked.length; i++) {
      if (_studentChecked[i] == CheckboxState.checked) {
        final timeId =
            _timeRanges.isNotEmpty && _currentRangeIndex < _timeRanges.length
                ? _timeRanges[_currentRangeIndex]['time_id']
                : null;
        final actId =
            studentActivities.isNotEmpty && i < studentActivities.length
                ? studentActivities[i]['act_id']
                : null;

        if (timeId != null && actId != null) {
          allTransactions.add({
            'trans_evalId': widget.evalId.toString(),
            'trans_timeId': timeId.toString(),
            'trans_actId': actId.toString(),
          });
        } else {
          print(
              'Error: timeId or actId is null at student index $i'); // Debugging output
        }
      }
    }

    // Add teacher activities (similar checks)
    for (int i = 0; i < _teacherChecked.length; i++) {
      if (_teacherChecked[i] == CheckboxState.checked) {
        final timeId =
            _timeRanges.isNotEmpty && _currentRangeIndex < _timeRanges.length
                ? _timeRanges[_currentRangeIndex]['time_id']
                : null;
        final actId =
            teacherActivities.isNotEmpty && i < teacherActivities.length
                ? teacherActivities[i]['act_id']
                : null;

        if (timeId != null && actId != null) {
          allTransactions.add({
            'trans_evalId': widget.evalId.toString(),
            'trans_timeId': timeId.toString(),
            'trans_actId': actId.toString(),
          });
        } else {
          print(
              'Error: timeId or actId is null at teacher index $i'); // Debugging output
        }
      }
    }

    // Send transactions to server
    for (var transaction in allTransactions) {
      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'operation': 'addTransaction',
            'json': jsonEncode(transaction),
          },
        );

        if (response.statusCode != 200) {
          print('Failed to add transaction: ${response.body}');
        } else {
          showToast(
            context: context,
            builder: (context, overlay) =>
                buildToast(context, overlay, "Response Saved."),
            location: ToastLocation.bottomRight,
          );
          await fetchActivityTallies();
        }
      } catch (e) {
        print('Error adding transaction: $e');
      }
    }
  }

  Future<Map<String, List<Map<String, String>>>> fetchActivities() async {
    final url = Uri.parse(
        'http://localhost/evaluation_app_api/transaction.php'); // Replace with your actual API endpoint
    final response = await http.post(url, body: {
      'operation': 'getActivities',
    });
    print(response.body);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      // Separate activities based on act_person and include act_code and act_name
      for (var activity in data) {
        Map<String, String> activityInfo = {
          'act_id': activity['act_id'].toString(),
          'act_code': activity['act_code'] as String,
          'act_name': activity['act_name'] as String,
        };

        if (activity['act_person'] == 'S') {
          studentActivities.add(activityInfo);
        } else if (activity['act_person'] == 'T') {
          teacherActivities.add(activityInfo);
        }
      }

      _studentChecked =
          List.filled(studentActivities.length, CheckboxState.unchecked);
      _teacherChecked =
          List.filled(teacherActivities.length, CheckboxState.unchecked);

      return {
        'students': studentActivities,
        'teachers': teacherActivities,
      };
    } else {
      throw Exception('Failed to load activities');
    }
  }

  void popover() {
    showPopover(
      context: context,
      alignment: Alignment.topRight,
      builder: (context) {
        return SurfaceCard(
          child: SizedBox(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Start Evaluation').semiBold().withPadding(vertical: 4),
                Divider(),
                PrimaryButton(
                  onPressed: () {
                    _startTimer();
                    _startRange();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(RadixIcons.play),
                      Text('Start '),
                    ],
                  ),
                ).withPadding(vertical: 4),
                Divider(),
                DestructiveButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text(
                              'Are you sure you want to stop evaluating?'),
                          content: const Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("This will restart your progress.")
                            ],
                          ),
                          actions: [
                            DestructiveButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            PrimaryButton(
                              child: const Text('Stop'),
                              onPressed: () {
                                _stopTimer();
                                _stopRange();
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(RadixIcons.stop),
                      Text('Stop '),
                    ],
                  ),
                ).withPadding(vertical: 4),
              ],
            ),
          ),
        ).withPadding(vertical: 8);
      },
    );
  }

  void commentDialog(String activity) {
    _commentController.text = comments[activity] ?? '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Comment for $activity'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextArea(
                expandableWidth: true,
                initialWidth: 500,
                controller: _commentController,
              )
            ],
          ),
          actions: [
            OutlineButton(
              child: const Text('Comment'),
              onPressed: () {
                setState(() {
                  comments[activity] =
                      _commentController.text; // Save the comment
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  String getTruncatedComment(String activity) {
    String comment = comments[activity] ?? '';
    if (comment.isEmpty) {
      return 'Comment'; // Default button text
    } else {
      return comment.length > 10 ? '${comment.substring(0, 10)}...' : comment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: Text(_formatCurrentTime()),
          subtitle: Text('${_formatTimeRange()} minutes').small(),
          alignment: Alignment.center,
          leading: [
            OutlineButton(
              onPressed: () {
                Navigator.pop(context);
              },
              density: ButtonDensity.icon,
              child: const Icon(RadixIcons.arrowLeft),
            ),
          ],
          trailing: [
            OutlineButton(
              onPressed: () {
                popover();
              },
              density: ButtonDensity.icon,
              child: const Icon(RadixIcons.timer),
            ),
          ],
        ),
        const Divider(),
      ],
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<Map<String, List<Map<String, String>>>>(
              future: _activitiesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child:
                          CircularProgressIndicator()); // Show loading indicator
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final activities = snapshot.data!;
                  final studentActivities = activities['students'] ?? [];
                  final teacherActivities = activities['teachers'] ?? [];

                  // Check screen size to determine layout
                  bool isMobile = MediaQuery.of(context).size.width < 1000;

                  return isMobile
                      ? mobileScreen(studentActivities, teacherActivities)
                      : desktopScreen(studentActivities, teacherActivities);
                } else {
                  return Center(child: Text('No activities found'));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget mobileScreen(List studentActivities, List teacherActivities) {
    final screenSize = MediaQuery.of(context).size.height < 800;
    return Column(
      children: [
        // Student Activities Card
        Container(
          height: screenSize ? 300 : 400, // Adjust height based on screen size
          child: Card(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // The shadow color
                spreadRadius: 1, // Spread of the shadow
                blurRadius: 10, // How blurred the shadow is
                offset: Offset(0, 4), // Offset for the shadow (x, y)
              ),
            ],
            padding: EdgeInsets.all(screenSize ? 2 : 4),
            child: Padding(
              padding: EdgeInsets.all(screenSize ? 6 : 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Student Actions",
                      ).small().semiBold(),
                      SizedBox(
                        height: screenSize ? 8 : 12,
                      ),
                      if (studentActivities.isNotEmpty)
                        Container(
                          height: screenSize ? 250 : 330,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: studentActivities
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                int index = entry.key;
                                Map<String, String> activity = entry.value;
                                return Container(
                                  decoration: BoxDecoration(
                                    border: index ==
                                            studentActivities.length - 1
                                        ? null // No border for the last item
                                        : Border(
                                            bottom: BorderSide(
                                              color: Colors
                                                  .gray, // Ensure proper color
                                              width: 1,
                                            ),
                                          ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: screenSize
                                            ? 80
                                            : 100, // Adjust width based on screen size
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                              screenSize ? 4 : 6),
                                          child: Text(activity['act_code']!)
                                              .xSmall(),
                                        ),
                                      ),
                                      Container(
                                        width: screenSize
                                            ? 70
                                            : 90, // Adjust width based on screen size
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                              screenSize ? 4 : 6),
                                          child: Center(
                                            child: Checkbox(
                                              state: _studentChecked[
                                                  index], // Updated to 'value'
                                              onChanged: (value) {
                                                setState(() {
                                                  _studentChecked[index] =
                                                      value;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: screenSize ? 70 : 90,
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                              screenSize ? 4 : 6),
                                          child: Center(
                                            child: Text(_activityTallies[
                                                            activity['act_id']]
                                                        ?.toString() ??
                                                    '0')
                                                .xSmall(),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: screenSize
                                            ? 70
                                            : 90, // Adjust width based on screen size
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                              screenSize ? 4 : 6),
                                          child: Center(
                                            child: IconButton.primary(
                                              size: ButtonSize.xSmall,
                                              onPressed: () {
                                                commentDialog(
                                                    activity['act_code']!);
                                              },
                                              density: ButtonDensity.icon,
                                              icon: const Icon(
                                                  RadixIcons.chatBubble),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        )
                      else
                        Text("No student activities found."),
                    ],
                  ),
                ],
              ).gap(12),
            ),
          ),
        ),

        // Teacher Activities Card
        Container(
          height: screenSize ? 300 : 400, // Adjust height based on screen size
          child: Card(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // The shadow color
                spreadRadius: 1, // Spread of the shadow
                blurRadius: 10, // How blurred the shadow is
                offset: Offset(0, 4), // Offset for the shadow (x, y)
              ),
            ],
            padding: EdgeInsets.all(screenSize ? 2 : 4),
            child: Padding(
              padding: EdgeInsets.all(screenSize ? 6 : 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Teacher Actions",
                      ).small().semiBold(),
                      SizedBox(
                        height: screenSize ? 8 : 12,
                      ),
                      if (teacherActivities.isNotEmpty)
                        Container(
                          height: screenSize ? 250 : 330,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: teacherActivities
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                int index = entry.key;
                                Map<String, String> activity = entry.value;
                                return Container(
                                  decoration: BoxDecoration(
                                    border: index ==
                                            teacherActivities.length - 1
                                        ? null // No border for the last item
                                        : Border(
                                            bottom: BorderSide(
                                              color: Colors
                                                  .gray, // Ensure proper color
                                              width: 1,
                                            ),
                                          ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: screenSize
                                            ? 80
                                            : 100, // Adjust width based on screen size
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                              screenSize ? 4 : 6),
                                          child: Text(activity['act_code']!)
                                              .xSmall(),
                                        ),
                                      ),
                                      Container(
                                        width: screenSize
                                            ? 70
                                            : 90, // Adjust width based on screen size
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                              screenSize ? 4 : 6),
                                          child: Center(
                                            child: Checkbox(
                                              state: _teacherChecked[
                                                  index], // Updated to 'value'
                                              onChanged: (value) {
                                                setState(() {
                                                  _teacherChecked[index] =
                                                      value;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: screenSize ? 70 : 90,
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                              screenSize ? 4 : 6),
                                          child: Center(
                                            child: Text(_activityTallies[
                                                            activity['act_id']]
                                                        ?.toString() ??
                                                    '0')
                                                .xSmall(),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: screenSize
                                            ? 70
                                            : 90, // Adjust width based on screen size
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                              screenSize ? 4 : 6),
                                          child: Center(
                                            child: IconButton.primary(
                                              size: ButtonSize.xSmall,
                                              onPressed: () {
                                                commentDialog(
                                                    activity['act_code']!);
                                              },
                                              density: ButtonDensity.icon,
                                              icon: const Icon(
                                                  RadixIcons.chatBubble),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        )
                      else
                        Text("No teacher activities found."),
                    ],
                  ),
                ],
              ).gap(12),
            ),
          ),
        ),
      ],
    ).gap(24);
  }

  Widget desktopScreen(List studentActivities, List teacherActivities) {
    final screenSize = MediaQuery.of(context).size.width > 1000;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Student Activities Card
        Expanded(
          child: Container(
            height:
                screenSize ? 550 : 500, // Adjust height based on screen size
            child: Card(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // The shadow color
                  spreadRadius: 1, // Spread of the shadow
                  blurRadius: 10, // How blurred the shadow is
                  offset: Offset(0, 4), // Offset for the shadow (x, y)
                ),
              ],
              padding: EdgeInsets.all(screenSize ? 8 : 4),
              child: Padding(
                padding: EdgeInsets.all(screenSize ? 12 : 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Student Actions",
                        ).small().semiBold(),
                        SizedBox(
                          height: screenSize ? 16 : 12,
                        ),
                        if (studentActivities.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                studentActivities.asMap().entries.map((entry) {
                              int index = entry.key;
                              Map<String, String> activity = entry.value;
                              return Container(
                                decoration: BoxDecoration(
                                  border: index == studentActivities.length - 1
                                      ? null // No border for the last item
                                      : Border(
                                          bottom: BorderSide(
                                            color: Colors.gray,
                                            width: 1,
                                          ),
                                        ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: screenSize
                                          ? 200
                                          : 180, // Adjust width based on screen size
                                      child: Padding(
                                        padding:
                                            EdgeInsets.all(screenSize ? 8 : 6),
                                        child: Text(activity['act_name']!)
                                            .xSmall(),
                                      ),
                                    ),
                                    Container(
                                      width: screenSize
                                          ? 100
                                          : 60, // Adjust width based on screen size
                                      child: Padding(
                                        padding:
                                            EdgeInsets.all(screenSize ? 8 : 6),
                                        child: Center(
                                          child: Checkbox(
                                            state: _studentChecked[index],
                                            onChanged: (value) {
                                              setState(() {
                                                _studentChecked[index] = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: screenSize ? 70 : 90,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.all(screenSize ? 4 : 6),
                                        child: Center(
                                          child: Text(_activityTallies[
                                                          activity['act_id']]
                                                      ?.toString() ??
                                                  '0')
                                              .xSmall(),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: screenSize
                                          ? 100
                                          : 120, // Adjust width based on screen size
                                      child: Padding(
                                        padding:
                                            EdgeInsets.all(screenSize ? 4 : 6),
                                        child: Center(
                                          child: OutlineButton(
                                            size: ButtonSize.small,
                                            density: ButtonDensity.dense,
                                            onPressed: () {
                                              commentDialog(
                                                  activity['act_name']!);
                                            },
                                            trailing: const Icon(
                                                RadixIcons.chatBubble),
                                            child: const Text('Comment'),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          )
                        else
                          Text("No student activities found."),
                      ],
                    ),
                  ],
                ).gap(12),
              ),
            ),
          ),
        ),

        // Teacher Activities Card
        Expanded(
          child: Container(
            height:
                screenSize ? 550 : 500, // Adjust height based on screen size
            child: Card(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // The shadow color
                  spreadRadius: 1, // Spread of the shadow
                  blurRadius: 10, // How blurred the shadow is
                  offset: Offset(0, 4), // Offset for the shadow (x, y)
                ),
              ],
              padding: EdgeInsets.all(screenSize ? 8 : 4),
              child: Padding(
                padding: EdgeInsets.all(screenSize ? 12 : 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Teacher Actions",
                        ).small().semiBold(),
                        SizedBox(
                          height: screenSize ? 16 : 12,
                        ),
                        if (studentActivities.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                teacherActivities.asMap().entries.map((entry) {
                              int index = entry.key;
                              Map<String, String> activity = entry.value;
                              return Container(
                                decoration: BoxDecoration(
                                  border: index == teacherActivities.length - 1
                                      ? null // No border for the last item
                                      : Border(
                                          bottom: BorderSide(
                                            color: Colors.gray,
                                            width: 1,
                                          ),
                                        ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: screenSize
                                          ? 200
                                          : 180, // Adjust width based on screen size
                                      child: Padding(
                                        padding:
                                            EdgeInsets.all(screenSize ? 8 : 6),
                                        child: Text(activity['act_name']!)
                                            .xSmall(),
                                      ),
                                    ),
                                    Container(
                                      width: screenSize
                                          ? 100
                                          : 60, // Adjust width based on screen size
                                      child: Padding(
                                        padding:
                                            EdgeInsets.all(screenSize ? 8 : 6),
                                        child: Center(
                                          child: Checkbox(
                                            state: _teacherChecked[index],
                                            onChanged: (value) {
                                              setState(() {
                                                _teacherChecked[index] = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: screenSize ? 70 : 90,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.all(screenSize ? 4 : 6),
                                        child: Center(
                                          child: Text(_activityTallies[
                                                          activity['act_id']]
                                                      ?.toString() ??
                                                  '0')
                                              .xSmall(),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: screenSize
                                          ? 100
                                          : 120, // Adjust width based on screen size
                                      child: Padding(
                                        padding:
                                            EdgeInsets.all(screenSize ? 4 : 6),
                                        child: Center(
                                          child: OutlineButton(
                                            size: ButtonSize.small,
                                            density: ButtonDensity.dense,
                                            onPressed: () {
                                              commentDialog(
                                                  activity['act_name']!);
                                            },
                                            trailing: const Icon(
                                                RadixIcons.chatBubble),
                                            child: const Text('Comment'),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          )
                        else
                          Text("No teacher activities found."),
                      ],
                    ),
                  ],
                ).gap(12),
              ),
            ),
          ),
        ),
      ],
    ).gap(24);
  }
}
