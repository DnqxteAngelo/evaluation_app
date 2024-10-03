// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:evaluation_app/components/select.dart';
import 'package:evaluation_app/components/summaryfield.dart';
import 'package:evaluation_app/models/models.dart';
import 'package:evaluation_app/pages/evaluation_page.dart';
import 'package:intl/intl.dart';

import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  final User user;

  ProfilePage({
    required this.user,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final StepperController controller = StepperController();
  final TextEditingController _subjectController = TextEditingController();
  int? _selectedTeacher;
  int? _selectedCollege;
  int? _selectedDepartment;
  int? _selectedSemester;
  int? _selectedYear;
  String? _selectedModality;
  List<Teacher> _teachers = [];
  List<College> _colleges = [];
  List<Department> _departments = [];
  List<Semester> _semesters = [];
  List<Year> _years = [];
  final List<String> _modality = ["FLEX", "RAD"];

  DateTime? _observationDate;

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
    _fetchColleges();
    _fetchDepartments();
    _fetchSemesters();
    _fetchYears();
  }

  Future<List<T>> fetchSelect<T>({
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
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<void> _fetchTeachers() async {
    List<Teacher> teachers = await fetchSelect<Teacher>(
      url: 'http://localhost/evaluation_app_api/teacher.php',
      body: {'operation': 'getTeacher'},
      fromJson: (json) => Teacher(
        teacherId: json['teacher_id'],
        teacherName: json['teacher_fullname'],
      ),
    );

    setState(() {
      _teachers = teachers;
    });
  }

  Future<void> _fetchColleges() async {
    List<College> colleges = await fetchSelect<College>(
      url: 'http://localhost/evaluation_app_api/college.php',
      body: {'operation': 'getCollege'},
      fromJson: (json) => College(
        collegeId: json['college_id'],
        collegeName: json['college_name'],
      ),
    );

    setState(() {
      _colleges = colleges;
    });
  }

  Future<void> _fetchDepartments() async {
    List<Department> departments = await fetchSelect<Department>(
      url: 'http://localhost/evaluation_app_api/department.php',
      body: {'operation': 'getDepartment'},
      fromJson: (json) => Department(
        deptId: json['dept_id'],
        deptName: json['dept_name'],
      ),
    );

    setState(() {
      _departments = departments;
    });
  }

  Future<void> _fetchSemesters() async {
    List<Semester> semesters = await fetchSelect<Semester>(
      url: 'http://localhost/evaluation_app_api/evaluation.php',
      body: {'operation': 'getSemester'},
      fromJson: (json) => Semester(
        semesterId: json['sem_id'],
        semesterName: json['sem_name'],
      ),
    );

    setState(() {
      _semesters = semesters;
    });
  }

  Future<void> _fetchYears() async {
    List<Year> years = await fetchSelect<Year>(
      url: 'http://localhost/evaluation_app_api/evaluation.php',
      body: {'operation': 'getYear'},
      fromJson: (json) => Year(
        yearId: json['year_id'],
        yearLevel: json['year_level'],
      ),
    );

    setState(() {
      _years = years;
    });
  }

  Future<int?> addEvaluation({
    required int userId,
    required int teacherId,
    required int semesterId,
    required String subject,
    required DateTime date,
    required String modality,
    required int yearId,
  }) async {
    final url = Uri.parse('http://localhost/evaluation_app_api/evaluation.php');

    String formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    Map<String, dynamic> jsonData = {
      'eval_userId': userId,
      'eval_teacherId': teacherId,
      'eval_semesterId': semesterId,
      'eval_subject': subject,
      'eval_date': formattedDate, // Convert DateTime to string
      'eval_modality': modality,
      'eval_yearId': yearId,
    };

    try {
      final response = await http.post(
        url,
        body: {
          "json": jsonEncode(jsonData),
          'operation': 'addEvaluation',
        },
      );

      print(response.body);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success']) {
          print('Evaluation added successfully');
          return int.parse(result['evalId']); // Return the evalId
        } else {
          print('Failed to add evaluation');
          return null;
        }
      } else {
        throw Exception(
            'Failed to add evaluation. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding evaluation: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 1000;
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Evaluation'),
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
        child: Container(
          width: 500,
          child: SingleChildScrollView(
            child: Stepper(
              controller: controller,
              size: isMobile ? StepSize.small : StepSize.medium,
              variant: isMobile ? StepVariant.circleAlt : StepVariant.circle,
              direction: isMobile ? Axis.horizontal : Axis.vertical,
              steps: [
                Step(
                  title: const Text('Teacher Profile'),
                  icon: StepNumber(
                    onPressed: () {
                      controller.jumpToStep(1);
                    },
                  ),
                  contentBuilder: (context) {
                    return StepContainer(
                      actions: [
                        const SecondaryButton(
                          child: Text('Prev'),
                        ),
                        PrimaryButton(
                          child: const Text('Next'),
                          onPressed: () {
                            controller.nextStep();
                          },
                        ),
                      ],
                      child: Column(
                        children: [
                          Container(
                            width: 700,
                            child: Card(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Teacher Profile').semiBold(),
                                  const SizedBox(height: 4),
                                  const Text(
                                          "Fill out the teacher's information.")
                                      .muted()
                                      .small(),
                                  const SizedBox(height: 24),
                                  LabeledSelect<int>(
                                    label: 'Teacher',
                                    value: _selectedTeacher,
                                    items: _teachers
                                        .map((teacher) => teacher.teacherId)
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedTeacher = value;
                                      });
                                    },
                                    isMobile: isMobile,
                                    itemDisplay: (id) {
                                      final teacher = _teachers.firstWhere(
                                          (teacher) => teacher.teacherId == id);
                                      return teacher.teacherName;
                                      // Return the full name for display
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  LabeledSelect<int>(
                                    label: 'College',
                                    value: _selectedCollege,
                                    items: _colleges
                                        .map((college) => college.collegeId)
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCollege = value;
                                      });
                                    },
                                    isMobile: isMobile,
                                    itemDisplay: (id) {
                                      final college = _colleges.firstWhere(
                                          (college) => college.collegeId == id);
                                      return college.collegeName;
                                      // Return the full name for display
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  LabeledSelect<int>(
                                    label: 'Department',
                                    value: _selectedDepartment,
                                    items: _departments
                                        .map((department) => department.deptId)
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedDepartment = value;
                                      });
                                    },
                                    isMobile: isMobile,
                                    itemDisplay: (id) {
                                      final department = _departments
                                          .firstWhere((department) =>
                                              department.deptId == id);
                                      return department.deptName;
                                      // Return the full name for display
                                    },
                                  ),
                                ],
                              ),
                            ).intrinsic(),
                          )
                        ],
                      ),
                    );
                  },
                ),
                Step(
                  title: const Text('Observation Details'),
                  icon: StepNumber(
                    onPressed: () {
                      controller.jumpToStep(2);
                    },
                  ),
                  contentBuilder: (context) {
                    return StepContainer(
                      actions: [
                        SecondaryButton(
                          child: const Text('Prev'),
                          onPressed: () {
                            controller.previousStep();
                          },
                        ),
                        PrimaryButton(
                            child: const Text('Next'),
                            onPressed: () {
                              controller.nextStep();
                            }),
                      ],
                      child: Column(
                        children: [
                          Container(
                            width: 700,
                            child: Card(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Observation Details').semiBold(),
                                  const SizedBox(height: 4),
                                  const Text(
                                          "Fill out the observation details.")
                                      .muted()
                                      .small(),
                                  const SizedBox(height: 24),
                                  isMobile
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text("Observer")
                                                .semiBold()
                                                .small(),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            TextField(
                                              readOnly: true,
                                              initialValue:
                                                  widget.user.userFullName,
                                            ),
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: const Text("Observer")
                                                  .semiBold()
                                                  .small(),
                                            ),
                                            const SizedBox(
                                              width: 16,
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: TextField(
                                                readOnly: true,
                                                initialValue:
                                                    widget.user.userFullName,
                                                // placeholder: 'Enter subject',
                                              ),
                                            ),
                                          ],
                                        ),
                                  const SizedBox(height: 24),
                                  isMobile
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text("Date")
                                                .semiBold()
                                                .small(), // Reusable label
                                            const SizedBox(height: 8),
                                            DatePicker(
                                              value: _observationDate,
                                              mode: PromptMode.popover,
                                              stateBuilder: (date) {
                                                if (date
                                                    .isAfter(DateTime.now())) {
                                                  return DateState.disabled;
                                                }
                                                return DateState.enabled;
                                              },
                                              onChanged: (value) {
                                                setState(() {
                                                  _observationDate = value;
                                                });
                                              },
                                            ),
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            Expanded(
                                              flex:
                                                  2, // You can adjust the flex for better proportions
                                              child: const Text("Date")
                                                  .semiBold()
                                                  .small(),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              flex:
                                                  3, // You can adjust the flex for better proportions
                                              child: DatePicker(
                                                value: _observationDate,
                                                mode: PromptMode.popover,
                                                stateBuilder: (date) {
                                                  if (date.isAfter(
                                                      DateTime.now())) {
                                                    return DateState.disabled;
                                                  }
                                                  return DateState.enabled;
                                                },
                                                onChanged: (value) {
                                                  setState(() {
                                                    _observationDate = value;
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                  const SizedBox(height: 24),
                                  isMobile
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text('Subject')
                                                .semiBold()
                                                .small(),
                                            const SizedBox(height: 4),
                                            TextField(
                                              controller: _subjectController,
                                              placeholder: 'Enter subject',
                                            ),
                                          ],
                                        )
                                      : Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: const Text('Subject')
                                                  .semiBold()
                                                  .small(),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              flex: 3,
                                              child: TextField(
                                                controller: _subjectController,
                                                placeholder: 'Enter subject',
                                              ),
                                            ),
                                          ],
                                        ),
                                  const SizedBox(height: 24),
                                  LabeledSelect<int>(
                                    label: 'Semester',
                                    value: _selectedSemester,
                                    items: _semesters
                                        .map((semester) => semester.semesterId)
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedSemester = value;
                                      });
                                    },
                                    isMobile: isMobile,
                                    itemDisplay: (id) {
                                      final semester = _semesters.firstWhere(
                                          (semester) =>
                                              semester.semesterId == id);
                                      return '${semester.semesterName} Semester';
                                      // Return the full name for display
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  LabeledSelect<int>(
                                    label: 'Year Level',
                                    value: _selectedYear,
                                    items: _years
                                        .map((year) => year.yearId)
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedYear = value;
                                      });
                                    },
                                    isMobile: isMobile,
                                    itemDisplay: (id) {
                                      final year = _years.firstWhere(
                                          (year) => year.yearId == id);
                                      return '${year.yearLevel} Year';
                                      // Return the full name for display
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  LabeledSelect<String>(
                                    label: 'Modality',
                                    value: _selectedModality,
                                    items: _modality,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedModality = value;
                                      });
                                    },
                                    isMobile: isMobile,
                                    itemDisplay: (value) {
                                      return value; // Display the modality directly
                                    },
                                  ),
                                ],
                              ),
                            ).intrinsic(),
                          )
                        ],
                      ),
                    );
                  },
                ),
                Step(
                  title: const Text('Evaluation Summary'),
                  contentBuilder: (context) {
                    return StepContainer(
                      actions: [
                        SecondaryButton(
                          child: const Text('Prev'),
                          onPressed: () {
                            controller.previousStep();
                          },
                        ),
                        PrimaryButton(
                          child: const Text('Finish'),
                          onPressed: () async {
                            int? evalId = await addEvaluation(
                              userId: widget.user.userId!,
                              teacherId: _selectedTeacher!,
                              semesterId: _selectedSemester!,
                              subject: _subjectController.text,
                              date: _observationDate!,
                              modality: _selectedModality!,
                              yearId: _selectedYear!,
                            );

                            if (evalId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EvaluationPage(
                                    evalId: evalId, // Pass the evalId here
                                  ),
                                ),
                              );
                            } else {
                              // Handle the case where the evaluation was not added successfully
                            }
                          },
                        )
                      ],
                      child: Column(
                        children: [
                          isMobile
                              ? Column(
                                  children: [
                                    Container(
                                      width: 500,
                                      child: Card(
                                        padding: const EdgeInsets.all(24),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text('Teacher Profile')
                                                .semiBold(),
                                            const SizedBox(height: 4),
                                            const Text(
                                                    "The summary of the teacher's profile.")
                                                .muted()
                                                .small(),
                                            const SizedBox(height: 24),
                                            SummaryField(
                                              isMobile: isMobile,
                                              label: 'Teacher',
                                              value: _teachers
                                                  .firstWhere(
                                                    (teacher) =>
                                                        teacher.teacherId ==
                                                        _selectedTeacher,
                                                    orElse: () => Teacher(
                                                      teacherId: 0,
                                                      teacherName:
                                                          'Unknown Teacher',
                                                    ),
                                                  )
                                                  .teacherName,
                                            ),
                                            const SizedBox(height: 24),
                                            SummaryField(
                                              isMobile: isMobile,
                                              label: 'College',
                                              value: _colleges
                                                  .firstWhere(
                                                    (college) =>
                                                        college.collegeId ==
                                                        _selectedCollege,
                                                    orElse: () => College(
                                                      collegeId: 0,
                                                      collegeName:
                                                          'Unknown College',
                                                    ),
                                                  )
                                                  .collegeName,
                                            ),
                                            const SizedBox(height: 24),
                                            SummaryField(
                                              isMobile: isMobile,
                                              label: 'Department',
                                              value: _departments
                                                  .firstWhere(
                                                    (department) =>
                                                        department.deptId ==
                                                        _selectedDepartment,
                                                    orElse: () => Department(
                                                      deptId: 0,
                                                      deptName:
                                                          'Unknown Department',
                                                    ),
                                                  )
                                                  .deptName,
                                            ),
                                            const SizedBox(height: 24),
                                          ],
                                        ),
                                      ).intrinsic(),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      width: 500,
                                      child: Card(
                                        padding: const EdgeInsets.all(24),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text('Observation Details')
                                                .semiBold(),
                                            const SizedBox(height: 4),
                                            const Text(
                                                    "The summary of the observation details.")
                                                .muted()
                                                .small(),
                                            const SizedBox(height: 24),
                                            SummaryField(
                                                isMobile: isMobile,
                                                label: 'Observer',
                                                value:
                                                    widget.user.userFullName),
                                            const SizedBox(height: 24),
                                            SummaryField(
                                              isMobile: isMobile,
                                              label: 'Date',
                                              value: DateFormat('MMMM d, yyyy')
                                                  .format(_observationDate!),
                                            ),
                                            const SizedBox(height: 24),
                                            SummaryField(
                                              isMobile: isMobile,
                                              label: 'Subject',
                                              value: _subjectController.text,
                                            ),
                                            const SizedBox(height: 24),
                                            SummaryField(
                                              isMobile: isMobile,
                                              label: 'Semester',
                                              value: "${_semesters.firstWhere(
                                                    (semester) =>
                                                        semester.semesterId ==
                                                        _selectedSemester,
                                                    orElse: () => Semester(
                                                      semesterId: 0,
                                                      semesterName:
                                                          'Unknown Semester',
                                                    ),
                                                  ).semesterName} Semester",
                                            ),
                                            const SizedBox(height: 24),
                                            SummaryField(
                                              isMobile: isMobile,
                                              label: 'Year Level',
                                              value: "${_years.firstWhere(
                                                    (year) =>
                                                        year.yearId ==
                                                        _selectedYear,
                                                    orElse: () => Year(
                                                      yearId: 0,
                                                      yearLevel: 'Unknown Year',
                                                    ),
                                                  ).yearLevel} Year",
                                            ),
                                            const SizedBox(height: 24),
                                            SummaryField(
                                              isMobile: isMobile,
                                              label: 'Modality',
                                              value: _selectedModality ??
                                                  'Unknown Modality',
                                            ),
                                            const SizedBox(height: 24),
                                          ],
                                        ),
                                      ).intrinsic(),
                                    ),
                                  ],
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        child: Card(
                                          padding: const EdgeInsets.all(24),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('Teacher Profile')
                                                  .semiBold(),
                                              const SizedBox(height: 4),
                                              const Text(
                                                      "The summary of the teacher's profile.")
                                                  .muted()
                                                  .small(),
                                              const SizedBox(height: 24),
                                              SummaryField(
                                                isMobile: isMobile,
                                                label: 'Teacher',
                                                value: _teachers
                                                    .firstWhere(
                                                      (teacher) =>
                                                          teacher.teacherId ==
                                                          _selectedTeacher,
                                                      orElse: () => Teacher(
                                                        teacherId: 0,
                                                        teacherName:
                                                            'Unknown Teacher',
                                                      ),
                                                    )
                                                    .teacherName,
                                              ),
                                              const SizedBox(height: 24),
                                              SummaryField(
                                                isMobile: isMobile,
                                                label: 'College',
                                                value: _colleges
                                                    .firstWhere(
                                                      (college) =>
                                                          college.collegeId ==
                                                          _selectedCollege,
                                                      orElse: () => College(
                                                        collegeId: 0,
                                                        collegeName:
                                                            'Unknown College',
                                                      ),
                                                    )
                                                    .collegeName,
                                              ),
                                              const SizedBox(height: 24),
                                              SummaryField(
                                                isMobile: isMobile,
                                                label: 'Department',
                                                value: _departments
                                                    .firstWhere(
                                                      (department) =>
                                                          department.deptId ==
                                                          _selectedDepartment,
                                                      orElse: () => Department(
                                                        deptId: 0,
                                                        deptName:
                                                            'Unknown Department',
                                                      ),
                                                    )
                                                    .deptName,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        child: Card(
                                          padding: const EdgeInsets.all(24),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('Observation Details')
                                                  .semiBold(),
                                              const SizedBox(height: 4),
                                              const Text(
                                                      "The summary of the observation details.")
                                                  .muted()
                                                  .small(),
                                              const SizedBox(height: 24),
                                              SummaryField(
                                                  isMobile: isMobile,
                                                  label: 'Observer',
                                                  value:
                                                      widget.user.userFullName),
                                              const SizedBox(height: 24),
                                              SummaryField(
                                                isMobile: isMobile,
                                                label: 'Date',
                                                value:
                                                    _observationDate.toString(),
                                              ),
                                              const SizedBox(height: 24),
                                              SummaryField(
                                                isMobile: isMobile,
                                                label: 'Subject',
                                                value: _subjectController.text,
                                              ),
                                              const SizedBox(height: 24),
                                              SummaryField(
                                                isMobile: isMobile,
                                                label: 'Semester',
                                                value: "${_semesters.firstWhere(
                                                      (semester) =>
                                                          semester.semesterId ==
                                                          _selectedSemester,
                                                      orElse: () => Semester(
                                                        semesterId: 0,
                                                        semesterName:
                                                            'Unknown Semester',
                                                      ),
                                                    ).semesterName} Semester",
                                              ),
                                              const SizedBox(height: 24),
                                              SummaryField(
                                                isMobile: isMobile,
                                                label: 'Year Level',
                                                value: "${_years.firstWhere(
                                                      (year) =>
                                                          year.yearId ==
                                                          _selectedYear,
                                                      orElse: () => Year(
                                                        yearId: 0,
                                                        yearLevel:
                                                            'Unknown Year',
                                                      ),
                                                    ).yearLevel} Year",
                                              ),
                                              const SizedBox(height: 24),
                                              SummaryField(
                                                isMobile: isMobile,
                                                label: 'Modality',
                                                value: _selectedModality ??
                                                    'Unknown Modality',
                                              ),
                                              const SizedBox(height: 24)
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
