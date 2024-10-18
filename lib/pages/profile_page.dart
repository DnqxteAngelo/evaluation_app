// ignore_for_file: avoid_print, use_build_context_synchronously, unnecessary_null_comparison, use_super_parameters, library_private_types_in_public_api

import 'dart:convert';

import 'package:evaluation_app/components/select.dart';
import 'package:evaluation_app/components/summaryfield.dart';
import 'package:evaluation_app/components/toast.dart';
import 'package:evaluation_app/models/models.dart';
import 'package:evaluation_app/pages/evaluation_page.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shadcn_flutter/shadcn_flutter.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final StepperController controller = StepperController();
  final TextEditingController _subjectController = TextEditingController();

  // Nullable selection variables
  int? _selectedTeacher;
  int? _selectedCollege;
  int? _selectedDepartment;
  int? _selectedSemester;
  int? _selectedPeriod;
  int? _selectedSchoolYear;
  int? _selectedYear;
  String? _selectedModality;
  DateTime _observationDate = DateTime.now();
  String formattedDate = "";

  // Data lists
  List<Teacher> _teachers = [];
  List<College> _colleges = [];
  List<Department> _departments = [];
  List<Semester> _semesters = [];
  List<SchoolYear> _schoolyear = [];
  List<Period> _period = [];
  List<Year> _years = [];
  final List<String> _modality = ["FLEX", "RAD"];

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
        _fetchColleges(),
        _fetchDepartments(),
        _fetchSchoolYears(),
        _fetchPeriods(),
        _fetchSemesters(),
        _fetchYears(),
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

  Future<void> _fetchColleges() async {
    final colleges = await _fetchSelect<College>(
      url: 'http://localhost/evaluation_app_api/college.php',
      body: {'operation': 'getCollege'},
      fromJson: (json) => College(
        collegeId: json['college_id'],
        collegeName: json['college_name'],
        deptName: json['dept_name'],
      ),
    );
    setState(() => _colleges = colleges);
  }

  Future<void> _fetchDepartments() async {
    final departments = await _fetchSelect<Department>(
      url: 'http://localhost/evaluation_app_api/department.php',
      body: {'operation': 'getDepartment'},
      fromJson: (json) => Department(
        deptId: json['dept_id'],
        deptName: json['dept_name'],
      ),
    );
    setState(() => _departments = departments);
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

  Future<void> _fetchYears() async {
    final years = await _fetchSelect<Year>(
      url: 'http://localhost/evaluation_app_api/evaluation.php',
      body: {'operation': 'getYear'},
      fromJson: (json) => Year(
        yearId: json['year_id'],
        yearLevel: json['year_level'],
      ),
    );
    setState(() => _years = years);
  }

  Future<int?> _addEvaluation() async {
    if (!_validateData()) return null;

    final url = Uri.parse('http://localhost/evaluation_app_api/evaluation.php');
    final formattedDate = DateFormat('yyyy-MM-dd').format(_observationDate);

    final Map<String, dynamic> jsonData = {
      'eval_userId': widget.user.userId,
      'eval_teacherId': _selectedTeacher,
      'eval_semesterId': _selectedSemester,
      'eval_schoolyearId': _selectedSchoolYear,
      'eval_periodId': _selectedPeriod,
      'eval_subject': _subjectController.text,
      'eval_date': formattedDate,
      'eval_modality': _selectedModality,
      'eval_yearId': _selectedYear,
    };

    try {
      final response = await http.post(
        url,
        body: {
          "json": jsonEncode(jsonData),
          'operation': 'addEvaluation',
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success']) {
          return int.parse(result['evalId']);
        }
      }
    } catch (e) {
      print('Error adding evaluation: $e');
    }
    return null;
  }

  bool _validateTeacherProfile() {
    return _selectedTeacher != null &&
        _selectedCollege != null &&
        _selectedDepartment != null;
  }

  bool _validateObservationDetails() {
    return _selectedSemester != null &&
        _selectedSchoolYear != null &&
        _selectedPeriod != null &&
        _selectedYear != null &&
        _selectedModality != null &&
        _observationDate != null &&
        _subjectController.text.isNotEmpty;
  }

  bool _validateData() {
    return _selectedTeacher != null &&
        _selectedCollege != null &&
        _selectedDepartment != null &&
        _selectedSemester != null &&
        _selectedSchoolYear != null &&
        _selectedPeriod != null &&
        _selectedYear != null &&
        _selectedModality != null &&
        _observationDate != null &&
        _subjectController.text.isNotEmpty;
  }

  Widget _buildTeacherProfileStep(bool isMobile) {
    return StepContainer(
      actions: [
        const SecondaryButton(
          child: Text('Cancel'),
        ),
        PrimaryButton(
          onPressed:
              _validateTeacherProfile() ? () => controller.nextStep() : null,
          child: const Text('Next'),
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
                  const Text("Fill out the teacher's information.")
                      .muted()
                      .small(),
                  const SizedBox(height: 24),
                  LabeledSelect<int>(
                    label: 'Teacher',
                    value: _selectedTeacher,
                    items:
                        _teachers.map((teacher) => teacher.teacherId).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedTeacher = value),
                    isMobile: isMobile,
                    itemDisplay: (id) {
                      final teacher = _teachers.firstWhere(
                        (t) => t.teacherId == id,
                        orElse: () => Teacher(
                            teacherId: 0,
                            teacherName: 'Unknown',
                            collegeName: ''),
                      );
                      return teacher.teacherName;
                    },
                  ),
                  const SizedBox(height: 24),
                  LabeledSelect<int>(
                    label: 'College',
                    value: _selectedCollege,
                    items:
                        _colleges.map((college) => college.collegeId).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCollege = value;
                      });
                    },
                    isMobile: isMobile,
                    itemDisplay: (id) {
                      final college = _colleges
                          .firstWhere((college) => college.collegeId == id);
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
                          .firstWhere((department) => department.deptId == id);
                      return department.deptName;
                      // Return the full name for display
                    },
                  ),
                  // Add similar LabeledSelect widgets for College and Department
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObservationDetailsStep(bool isMobile) {
    return StepContainer(
      actions: [
        SecondaryButton(
          child: const Text('Back'),
          onPressed: () => controller.previousStep(),
        ),
        PrimaryButton(
          onPressed: _validateObservationDetails()
              ? () => controller.nextStep()
              : null,
          child: const Text('Next'),
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
                  const Text('Observation Details').semiBold(),
                  const SizedBox(height: 4),
                  const Text("Fill out the observation details.")
                      .muted()
                      .small(),
                  const SizedBox(height: 24),
                  isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Observer").semiBold().small(),
                            const SizedBox(
                              height: 8,
                            ),
                            TextField(
                              readOnly: true,
                              initialValue: widget.user.userFullName,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: const Text("Observer").semiBold().small(),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Expanded(
                              flex: 3,
                              child: TextField(
                                readOnly: true,
                                initialValue: widget.user.userFullName,
                                // placeholder: 'Enter subject',
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 24),
                  isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Date")
                                .semiBold()
                                .small(), // Reusable label
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              child: DatePicker(
                                initialView: CalendarView.now(),
                                value: _observationDate,
                                mode: PromptMode.popover,
                                stateBuilder: (date) {
                                  if (date.isAfter(DateTime.now())) {
                                    return DateState.disabled;
                                  }
                                  return DateState.enabled;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _observationDate = value!;
                                    formattedDate = DateFormat('MMMM d, y')
                                        .format(_observationDate);
                                  });
                                },
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              flex:
                                  2, // You can adjust the flex for better proportions
                              child: const Text("Date").semiBold().small(),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex:
                                  3, // You can adjust the flex for better proportions
                              child: DatePicker(
                                initialView: CalendarView.now(),
                                value: _observationDate,
                                mode: PromptMode.popover,
                                stateBuilder: (date) {
                                  if (date.isAfter(DateTime.now())) {
                                    return DateState.disabled;
                                  }
                                  return DateState.enabled;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _observationDate = value!;
                                    formattedDate = DateFormat('MMMM d, y')
                                        .format(_observationDate);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 24),
                  isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Subject').semiBold().small(),
                            const SizedBox(height: 4),
                            TextField(
                              controller: _subjectController,
                              placeholder: 'Enter subject',
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 2,
                              child: const Text('Subject').semiBold().small(),
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
                    label: 'Period',
                    value: _selectedPeriod,
                    items: _period.map((p) => p.periodId).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPeriod = value;
                      });
                    },
                    isMobile: isMobile,
                    itemDisplay: (id) {
                      final period =
                          _period.firstWhere((p) => p.periodId == id);
                      return '${period.periodName} Period';
                      // Return the full name for display
                    },
                  ),
                  const SizedBox(height: 24),
                  LabeledSelect<int>(
                    label: 'Semester',
                    value: _selectedSemester,
                    items: _semesters.map((s) => s.semesterId).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSemester = value;
                      });
                    },
                    isMobile: isMobile,
                    itemDisplay: (id) {
                      final semester =
                          _semesters.firstWhere((s) => s.semesterId == id);
                      return '${semester.semesterName} Semester';
                      // Return the full name for display
                    },
                  ),
                  const SizedBox(height: 24),
                  LabeledSelect<int>(
                    label: 'School Year',
                    value: _selectedSchoolYear,
                    items: _schoolyear.map((sy) => sy.syId).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSchoolYear = value;
                      });
                    },
                    isMobile: isMobile,
                    itemDisplay: (id) {
                      final schoolyear =
                          _schoolyear.firstWhere((sy) => sy.syId == id);
                      return schoolyear.syName;
                      // Return the full name for display
                    },
                  ),
                  const SizedBox(height: 24),
                  LabeledSelect<int>(
                    label: 'Year Level',
                    value: _selectedYear,
                    items: _years.map((y) => y.yearId).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value;
                      });
                    },
                    isMobile: isMobile,
                    itemDisplay: (id) {
                      final year = _years.firstWhere((y) => y.yearId == id);
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
                  // Add form fields for date, subject, semester, year level, and modality
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStep(bool isMobile) {
    if (!_validateData()) {
      return const Center(
        child:
            Text('Please complete all previous steps before viewing summary.'),
      );
    }

    return StepContainer(
      actions: [
        SecondaryButton(
          child: const Text('Back'),
          onPressed: () => controller.previousStep(),
        ),
        PrimaryButton(
          child: const Text('Submit'),
          onPressed: () async {
            final evalId = await _addEvaluation();
            if (evalId != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => EvaluationPage(evalId: evalId),
                ),
              );
            } else {
              showToast(
                context: context,
                builder: (context, overlay) => buildToast(
                    context, overlay, "Failed to submit evaluation."),
                location: ToastLocation.bottomRight,
              );
            }
          },
        ),
      ],
      child: isMobile
          ? Column(
              children: [
                _buildSummaryCard(
                  'Teacher Profile',
                  [
                    SummaryField(
                      isMobile: true,
                      label: 'Teacher',
                      value: _teachers
                          .firstWhere((t) => t.teacherId == _selectedTeacher)
                          .teacherName,
                    ),
                    const SizedBox(height: 24),
                    SummaryField(
                      isMobile: true,
                      label: 'College',
                      value: _colleges
                          .firstWhere((c) => c.collegeId == _selectedCollege)
                          .collegeName,
                    ),
                    const SizedBox(height: 24),
                    SummaryField(
                      isMobile: true,
                      label: 'Department',
                      value: _departments
                          .firstWhere((d) => d.deptId == _selectedDepartment)
                          .deptName,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSummaryCard(
                  'Observation Details',
                  [
                    SummaryField(
                      isMobile: true,
                      label: 'Observer',
                      value: widget.user.userFullName,
                    ),
                    const SizedBox(height: 24),
                    SummaryField(
                      isMobile: true,
                      label: 'Date',
                      value: formattedDate,
                    ),
                    const SizedBox(height: 24),
                    SummaryField(
                      isMobile: true,
                      label: 'Subject',
                      value: _subjectController.text,
                    ),
                    const SizedBox(height: 24),
                    SummaryField(
                      isMobile: true,
                      label: 'Period',
                      value:
                          "${_period.firstWhere((p) => p.periodId == _selectedPeriod).periodName} Period",
                    ),
                    const SizedBox(height: 24),
                    SummaryField(
                      isMobile: true,
                      label: 'Semester',
                      value:
                          "${_semesters.firstWhere((s) => s.semesterId == _selectedSemester).semesterName} Semester",
                    ),
                    const SizedBox(height: 24),
                    SummaryField(
                      isMobile: true,
                      label: 'School Year',
                      value: _schoolyear
                          .firstWhere((sy) => sy.syId == _selectedSchoolYear)
                          .syName,
                    ),
                    const SizedBox(height: 24),
                    SummaryField(
                      isMobile: true,
                      label: 'Year Level',
                      value:
                          "${_years.firstWhere((y) => y.yearId == _selectedYear).yearLevel} Year",
                    ),
                    const SizedBox(height: 24),
                    SummaryField(
                      isMobile: true,
                      label: 'Modality',
                      value: _selectedModality ?? 'Unknown Modality',
                    ),
                  ],
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Teacher Profile',
                    [
                      SummaryField(
                        isMobile: false,
                        label: 'Teacher',
                        value: _teachers
                            .firstWhere((t) => t.teacherId == _selectedTeacher)
                            .teacherName,
                      ),
                      const SizedBox(height: 24),
                      SummaryField(
                        isMobile: false,
                        label: 'College',
                        value: _colleges
                            .firstWhere((c) => c.collegeId == _selectedCollege)
                            .collegeName,
                      ),
                      const SizedBox(height: 24),
                      SummaryField(
                        isMobile: false,
                        label: 'Department',
                        value: _departments
                            .firstWhere((d) => d.deptId == _selectedDepartment)
                            .deptName,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Observation Details',
                    [
                      SummaryField(
                        isMobile: false,
                        label: 'Observer',
                        value: widget.user.userFullName,
                      ),
                      const SizedBox(height: 24),
                      SummaryField(
                        isMobile: false,
                        label: 'Date',
                        value: formattedDate,
                      ),
                      const SizedBox(height: 24),
                      SummaryField(
                        isMobile: false,
                        label: 'Subject',
                        value: _subjectController.text,
                      ),
                      const SizedBox(height: 24),
                      SummaryField(
                        isMobile: false,
                        label: 'Period',
                        value:
                            "${_period.firstWhere((p) => p.periodId == _selectedPeriod).periodName} Period",
                      ),
                      const SizedBox(height: 24),
                      SummaryField(
                        isMobile: false,
                        label: 'Semester',
                        value:
                            "${_semesters.firstWhere((s) => s.semesterId == _selectedSemester).semesterName} Semester",
                      ),
                      const SizedBox(height: 24),
                      SummaryField(
                        isMobile: false,
                        label: 'School Year',
                        value: _schoolyear
                            .firstWhere((sy) => sy.syId == _selectedSchoolYear)
                            .syName,
                      ),
                      const SizedBox(height: 24),
                      SummaryField(
                        isMobile: false,
                        label: 'Year Level',
                        value: _years
                            .firstWhere((y) => y.yearId == _selectedYear)
                            .yearLevel,
                      ),
                      const SizedBox(height: 24),
                      SummaryField(
                        isMobile: false,
                        label: 'Modality',
                        value: _selectedModality ?? 'Unknown Modality',
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryCard(String title, List<Widget> fields) {
    return Card(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title).semiBold(),
          const SizedBox(height: 4),
          Text("Summary of $title.").muted().small(),
          const SizedBox(height: 24),
          ...fields,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 1000;

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
          title: const Text('Evaluation'),
          leading: [
            OutlineButton(
              onPressed: () => Navigator.pop(context),
              density: ButtonDensity.icon,
              child: const Icon(RadixIcons.arrowLeft),
            ),
          ],
        ),
        const Divider(),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: isMobile ? double.infinity : 500,
          child: SingleChildScrollView(
            child: Stepper(
              controller: controller,
              size: isMobile ? StepSize.small : StepSize.medium,
              variant: isMobile ? StepVariant.circleAlt : StepVariant.circle,
              direction: isMobile ? Axis.horizontal : Axis.vertical,
              steps: [
                Step(
                  title: const Text('Teacher Profile'),
                  contentBuilder: (context) =>
                      _buildTeacherProfileStep(isMobile),
                ),
                Step(
                  title: const Text('Observation Details'),
                  contentBuilder: (context) =>
                      _buildObservationDetailsStep(isMobile),
                ),
                Step(
                  title: const Text('Summary'),
                  contentBuilder: (context) => _buildSummaryStep(isMobile),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
