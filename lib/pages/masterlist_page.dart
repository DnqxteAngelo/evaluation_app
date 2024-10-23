// ignore_for_file: use_super_parameters, library_private_types_in_public_api, use_build_context_synchronously
import 'package:evaluation_app/components/toast.dart';
import 'package:evaluation_app/models/models.dart';
import 'package:flutter/material.dart' as material;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MasterlistPage extends StatefulWidget {
  final User user;

  MasterlistPage({
    required this.user,
  });

  @override
  _MasterlistPageState createState() => _MasterlistPageState();
}

class _MasterlistPageState extends State<MasterlistPage> {
  int selected = 0;
  List<CollegeTable> collegeList = [];
  List<TeacherTable> teacherList = [];

  List<College> _colleges = [];

  final TextEditingController lastname = TextEditingController();
  final TextEditingController firstname = TextEditingController();
  final TextEditingController middlename = TextEditingController();
  final TextEditingController rank = TextEditingController();
  final TextEditingController profLicense = TextEditingController();

  // Define the values for the select dropdowns.
  int? selectedCollegeId;
  String? selectedEducAttain;
  String? selectedEmpStatus;

  DateTime? yearHired;
  DateTime? yearReg;

  List<String> educAttainments = ['Bachelor', 'Master', 'Doctorate'];
  List<String> empStatuses = ['Full-time', 'Part-time', 'Probationary'];

  @override
  void initState() {
    super.initState();
    fetchCollegeData(); // Fetch college data on init
    _fetchColleges();
  }

  Future<void> fetchCollegeData() async {
    final response = await http.post(
      Uri.parse('http://localhost/evaluation_app_api/college.php'),
      body: {'operation': 'getCollege'},
    );

    print(response.body);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        collegeList = data
            .map((e) => CollegeTable(
                  collegeId: e['college_id'],
                  collegeName: e['college_name'],
                  deptName: e['dept_name'],
                ))
            .toList();
      });
    } else {
      throw Exception('Failed to load college data');
    }
  }

  void showAddCollegeDialog(BuildContext context) {
    final TextEditingController collegeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final FormController controller = FormController();
        return Container(
          width: 400,
          child: AlertDialog(
            title: const Text('Add College'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Form(
                  controller: controller,
                  child: FormTableLayout(rows: [
                    FormField<String>(
                      key: const FormKey(#college),
                      label: const Text('College Name'),
                      child: TextField(
                        controller: collegeController,
                      ),
                    ),
                  ]),
                ).withPadding(vertical: 16),
              ],
            ),
            actions: [
              DestructiveButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              PrimaryButton(
                child: const Text('Add'),
                onPressed: () async {
                  final collegeData = {
                    'college_deptId': widget.user.userDeptId,
                    'college_name': collegeController.text,
                  };

                  final response = await http.post(
                    Uri.parse(
                        'http://localhost/evaluation_app_api/college.php'), // Update with your actual URL
                    body: {
                      'operation': 'addCollege',
                      'json': json.encode(collegeData),
                    },
                  );

                  if (response.statusCode == 200) {
                    // Optionally show a success message
                    showToast(
                      context: context,
                      builder: (context, overlay) => buildToast(
                          context, overlay, "College added successfully!"),
                      location: ToastLocation.bottomRight,
                    );
                    fetchCollegeData(); // Refresh college data
                    Navigator.of(context).pop(); // Close the dialog
                  } else {
                    // Optionally show an error message
                    showToast(
                      context: context,
                      builder: (context, overlay) =>
                          buildToast(context, overlay, "ailed to add college"),
                      location: ToastLocation.bottomRight,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> fetchTeacherData() async {
    final response = await http.post(
      Uri.parse(
          'http://localhost/evaluation_app_api/teacher.php'), // Update with your actual URL
      body: {'operation': 'getTeacher'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        teacherList =
            data.map((teacher) => TeacherTable.fromJson(teacher)).toList();
      });
    } else {
      throw Exception('Failed to load teacher data');
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

  void showAddTeacherDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        // Use StatefulBuilder to manage state within the dialog
        return AlertDialog(
          title: const Text('Add Teacher'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: 950,
                height: 350,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildTextField('Last Name', lastname),
                          _buildTextField('First Name', firstname),
                          _buildTextField('Middle Name', middlename),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildSelect<int>(
                            label: 'College',
                            value: selectedCollegeId,
                            items: _colleges
                                .map((college) => college.collegeId)
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCollegeId = value;
                              });
                            },
                            itemDisplay: (id) {
                              final college = _colleges.firstWhere(
                                  (college) => college.collegeId == id);
                              return college.collegeName;
                            },
                            popupConstraints: const BoxConstraints(
                                maxHeight: 300, maxWidth: 300),
                          ),
                          _buildSelect<String>(
                            label: 'Educational Attainment',
                            value: selectedEducAttain,
                            items: educAttainments,
                            onChanged: (value) {
                              setState(() {
                                selectedEducAttain = value;
                              });
                            },
                            itemDisplay: (item) => item,
                            popupConstraints: const BoxConstraints(
                                maxHeight: 300, maxWidth: 300),
                          ),
                          _buildSelect<String>(
                            label: 'Employment Status',
                            value: selectedEmpStatus,
                            items: empStatuses,
                            onChanged: (value) {
                              setState(() {
                                selectedEmpStatus = value;
                              });
                            },
                            itemDisplay: (item) => item,
                            popupConstraints: const BoxConstraints(
                                maxHeight: 300, maxWidth: 300),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildTextField('Professional License', profLicense),
                          _buildTextField('Rank', rank),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildDatePicker(
                            label: 'Date Hired',
                            value: yearHired,
                            onChanged: (value) {
                              setState(() {
                                yearHired = value;
                              });
                            },
                          ),
                          _buildDatePicker(
                            label: 'Reg Date',
                            value: yearReg,
                            onChanged: (value) {
                              setState(() {
                                yearReg = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            DestructiveButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            PrimaryButton(
              onPressed: () async {
                int totalYears = DateTime.now().year - yearHired!.year;
                final teacherData = {
                  'teacher_fullname':
                      '${lastname.text}, ${firstname.text} ${middlename.text}',
                  'teacher_collegeId': selectedCollegeId.toString(),
                  'teacher_totalYears': totalYears.toString(),
                  'teacher_yearHired': yearHired!.year.toString(),
                  'teacher_yearReg': yearReg!.year.toString(),
                  'teacher_educAttain': selectedEducAttain,
                  'teacher_profLicense': profLicense.text,
                  'teacher_empStatus': selectedEmpStatus,
                  'teacher_rank': rank.text,
                };

                final response = await http.post(
                  Uri.parse('http://localhost/evaluation_app_api/teacher.php'),
                  body: {
                    'operation': 'addTeacher',
                    'json': json.encode(teacherData),
                  },
                );

                print(response.body);

                if (response.statusCode == 200) {
                  showToast(
                    context: context,
                    builder: (context, overlay) => buildToast(
                        context, overlay, "Teacher added successfully!"),
                  );
                  fetchTeacherData();
                  Navigator.pop(context);
                } else {
                  showToast(
                    context: context,
                    builder: (context, overlay) =>
                        buildToast(context, overlay, "Failed to add teacher"),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

// Helper method to build labeled TextFields
  Widget _buildTextField(String label, TextEditingController controller) {
    return SizedBox(
      width: 300, // Adjust width as needed
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black),
          ).semiBold().small(),
          const SizedBox(height: 8),
          TextField(controller: controller),
        ],
      ),
    );
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

// Helper method to build DatePicker widgets
  Widget _buildDatePicker({
    required String label,
    required DateTime? value,
    required Function(DateTime?) onChanged,
  }) {
    return SizedBox(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black),
          ).semiBold().small(),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: DatePicker(
              initialView: CalendarView.now(),
              initialViewType: CalendarViewType.year,
              value: value,
              mode: PromptMode.popover,
              stateBuilder: (date) => date.isAfter(DateTime.now())
                  ? DateState.disabled
                  : DateState.enabled,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  void onTabSelected(int index) {
    setState(() {
      selected = index;
      if (selected == 0) {
        fetchCollegeData();
      } else if (selected == 1) {
        fetchTeacherData();
      }
    });
  }

  NavigationRailAlignment alignment = NavigationRailAlignment.start;

  NavigationButton buildButton(String label, IconData icon) {
    return NavigationButton(
      label: Text(label),
      child: Icon(icon),
    );
  }

  // Table for College data
  Widget buildCollegeTable() {
    String? lastDeptName;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return material.Theme(
      data: material.Theme.of(context).copyWith(
        dataTableTheme: material.DataTableThemeData(
          headingTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 14 : 16,
          ),
          dataTextStyle: TextStyle(
            fontSize: isSmallScreen ? 13 : 14,
          ),
          horizontalMargin: isSmallScreen ? 10 : 24,
          columnSpacing: isSmallScreen ? 20 : 56,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: screenWidth * 0.9,
          ),
          child: material.DataTable(
            columnSpacing: isSmallScreen ? 20 : 56,
            horizontalMargin: isSmallScreen ? 10 : 24,
            columns: [
              if (!isSmallScreen)
                const material.DataColumn(
                  label: Text('College'),
                ),
              const material.DataColumn(
                label: Text('Program Name'),
              ),
            ],
            rows: collegeList.map((college) {
              bool showDeptName = college.deptName != lastDeptName;
              lastDeptName = college.deptName;

              return material.DataRow(cells: [
                if (!isSmallScreen)
                  material.DataCell(
                    showDeptName
                        ? Text(college.deptName)
                        : const SizedBox.shrink(),
                  ),
                material.DataCell(Text(college.collegeName)),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

// Table for Teacher data
  Widget buildTeacherTable() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return material.Theme(
      data: material.Theme.of(context).copyWith(
        dataTableTheme: material.DataTableThemeData(
          headingTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 14 : 16,
          ),
          dataTextStyle: TextStyle(
            fontSize: isSmallScreen ? 13 : 14,
          ),
          horizontalMargin: isSmallScreen ? 10 : 24,
          columnSpacing: isSmallScreen ? 20 : 56,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: screenWidth * 0.9,
          ),
          child: material.DataTable(
            columnSpacing: isSmallScreen ? 20 : 56,
            horizontalMargin: isSmallScreen ? 10 : 24,
            // For mobile, you might want to show fewer columns
            columns: [
              const material.DataColumn(label: Text('Name')),
              if (!isSmallScreen) // Only show on larger screens
                const material.DataColumn(label: Text('College Name')),
              const material.DataColumn(label: Text('Status')),
            ],
            rows: teacherList.map((teacher) {
              return material.DataRow(cells: [
                material.DataCell(Text(teacher.fullname)),
                if (!isSmallScreen)
                  material.DataCell(Text(teacher.collegeName)),
                material.DataCell(Text(teacher.empStatus)),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Display appropriate table based on the selected button
  Widget buildContent() {
    switch (selected) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Button to add a college
            PrimaryButton(
              onPressed: () => showAddCollegeDialog(context),
              child: const Text('Add College'),
            ),
            const SizedBox(
                height: 16), // Add some space between button and table
            Expanded(child: buildCollegeTable()), // Render college table
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Button to add a college
            PrimaryButton(
              onPressed: () => showAddTeacherDialog(context),
              child: const Text('Add Teacher'),
            ),
            const SizedBox(
                height: 16), // Add some space between button and table
            Expanded(child: buildTeacherTable()), // Render college table
          ],
        );
      default:
        return const Center(child: Text('Select an option from the menu'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Master List'),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NavigationRail(
            alignment: alignment,
            labelType: isSmallScreen
                ? NavigationLabelType.tooltip
                : NavigationLabelType.all,
            index: selected,
            onSelected: onTabSelected,
            children: [
              buildButton('College', BootstrapIcons.book),
              buildButton('Teacher', BootstrapIcons.people),
            ],
          ),
          const VerticalDivider(),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: buildContent(), // Render selected content
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
