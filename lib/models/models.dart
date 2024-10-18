class College {
  final int collegeId;
  final String collegeName;
  final String deptName;

  College(
      {required this.collegeId,
      required this.collegeName,
      required this.deptName});
}

class Teacher {
  final int teacherId;
  final String teacherName;
  final String collegeName;

  Teacher(
      {required this.teacherId,
      required this.teacherName,
      required this.collegeName});
}

class Department {
  final int deptId;
  final String deptName;

  Department({required this.deptId, required this.deptName});
}

class Semester {
  final int semesterId;
  final String semesterName;

  Semester({required this.semesterId, required this.semesterName});
}

class Period {
  final int periodId;
  final String periodName;

  Period({required this.periodId, required this.periodName});
}

class SchoolYear {
  final int syId;
  final String syName;

  SchoolYear({required this.syId, required this.syName});
}

class Year {
  final int yearId;
  final String yearLevel;

  Year({required this.yearId, required this.yearLevel});
}

class User {
  final int? userId;
  final int userDeptId;
  final String userFullName;

  User({
    required this.userId,
    required this.userFullName,
    required this.userDeptId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? '',
      userDeptId: json['user_deptId'] ?? '',
      userFullName: json['user_fullname'] ?? '',
    );
  }
}

class Activity {
  final int activityId;
  final String activityName;
  final String activityCode;
  final String activityPerson;
  final int tally;

  Activity({
    required this.activityId,
    required this.activityName,
    required this.activityCode,
    required this.activityPerson,
    required this.tally,
  });

  // Override == and hashCode for correct key comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Activity &&
        other.activityId == activityId &&
        other.activityName == activityName &&
        other.activityCode == activityCode &&
        other.activityPerson == activityPerson;
  }

  @override
  int get hashCode =>
      activityId.hashCode ^
      activityName.hashCode ^
      activityCode.hashCode ^
      activityPerson.hashCode;

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      activityId: json['trans_actId'] as int,
      activityName: json['act_name'] as String,
      activityCode: json['act_code'] as String,
      activityPerson: json['act_person'] as String,
      tally: json['tally'] as int,
    );
  }
}

class CollegeTable {
  final int collegeId;
  final String collegeName;
  final String deptName;

  CollegeTable(
      {required this.collegeId,
      required this.collegeName,
      required this.deptName});

  factory CollegeTable.fromJson(Map<String, dynamic> json) {
    return CollegeTable(
      collegeId: json['college_id'],
      collegeName: json['college_name'],
      deptName: json['dept_name'],
    );
  }
}

class TeacherTable {
  final String fullname;
  final String collegeName;
  final String empStatus;

  TeacherTable(
      {required this.fullname,
      required this.collegeName,
      required this.empStatus});

  factory TeacherTable.fromJson(Map<String, dynamic> json) {
    return TeacherTable(
      fullname: json['teacher_fullname'],
      collegeName: json['college_name'],
      empStatus: json['teacher_empStatus'],
    );
  }
}
