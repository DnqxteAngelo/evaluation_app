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

  @override
  void initState() {
    super.initState();
    fetchCollegeData(); // Fetch college data on init
  }

  Future<void> fetchCollegeData() async {
    final response = await http.post(
      Uri.parse(
          'http://localhost/evaluation_app_api/college.php'), // Update with your actual URL
      body: {'operation': 'getCollege'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        collegeList =
            data.map((college) => CollegeTable.fromJson(college)).toList();
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

  void showAddTeacherDialog(BuildContext context) {
    final TextEditingController lastname = TextEditingController();
    final TextEditingController firstname = TextEditingController();
    final TextEditingController middlename = TextEditingController();
    final TextEditingController educAttain = TextEditingController();
    final TextEditingController profLicense = TextEditingController();
    final TextEditingController rank = TextEditingController();
    final TextEditingController yearHired = TextEditingController();
    final TextEditingController yearReg = TextEditingController();
    final TextEditingController collegeId = TextEditingController();
    final TextEditingController empStatus = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Teacher'),
          content: Container(
            width: 1000,
            height: 300,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildTextField('Last Name', lastname),
                      _buildTextField('First Name', firstname),
                      _buildTextField('Middle Name', middlename),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildTextField('College', collegeId),
                      _buildTextField('Year Hired', yearHired),
                      _buildTextField('Reg Year', yearReg),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildTextField('Educational Attainment', educAttain),
                      _buildTextField('Professional License', profLicense),
                      _buildTextField('Rank', rank),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildTextField('Employment Status', empStatus),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            DestructiveButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            PrimaryButton(
              onPressed: () async {
                int totalYears =
                    DateTime.now().year - int.parse(yearHired.text);
                final teacherData = {
                  'teacher_fullname':
                      '${lastname.text}, ${firstname.text} ${middlename.text}',
                  'teacher_collegeId': collegeId.text, // Adjust as needed
                  'teacher_totalYears': totalYears.toString(),
                  'teacher_yearHired': yearHired.text,
                  'teacher_yearReg': yearReg.text,
                  'teacher_educAttain': educAttain.text,
                  'teacher_profLicense': profLicense.text,
                  'teacher_empStatus': empStatus.text,
                  'teacher_rank': rank.text,
                };

                print(totalYears);

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
          Text(label).semiBold().small(),
          const SizedBox(height: 8),
          TextField(controller: controller),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label).semiBold().small(),
        const SizedBox(height: 8),
        DatePicker(
          initialView: CalendarView.now(),
          value: value,
          mode: PromptMode.popover,
          stateBuilder: (date) => date.isAfter(DateTime.now())
              ? DateState.disabled
              : DateState.enabled,
          onChanged: onChanged,
        ),
      ],
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
  NavigationLabelType labelType = NavigationLabelType.all;

  NavigationButton buildButton(String label, IconData icon) {
    return NavigationButton(
      label: Text(label),
      child: Icon(icon),
    );
  }

  // Table for College data
  Widget buildCollegeTable() {
    return material.DataTable(
      columns: const [
        material.DataColumn(
            label: Text(
          'College Name',
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
        material.DataColumn(
            label: Text(
          'Department Name',
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
      ],
      rows: collegeList.map((college) {
        return material.DataRow(cells: [
          material.DataCell(Text(college.collegeName)),
          material.DataCell(Text(college.departmentName)),
        ]);
      }).toList(),
    );
  }

  // Table for Teacher data
  Widget buildTeacherTable() {
    return material.DataTable(
      columns: const [
        material.DataColumn(
            label: Text(
          'Name',
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
        material.DataColumn(
            label: Text(
          'College Name',
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
        material.DataColumn(
            label: Text(
          'Employment Status',
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
      ],
      rows: teacherList.map((teacher) {
        return material.DataRow(cells: [
          material.DataCell(Text(teacher.fullname)),
          material.DataCell(Text(teacher.collegeName)),
          material.DataCell(Text(teacher.empStatus)),
        ]);
      }).toList(),
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
            labelType: labelType,
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
