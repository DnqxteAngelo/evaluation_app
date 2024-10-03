class College {
  final int collegeId;
  final String collegeName;

  College({required this.collegeId, required this.collegeName});
}

class Teacher {
  final int teacherId;
  final String teacherName;

  Teacher({required this.teacherId, required this.teacherName});
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

class Year {
  final int yearId;
  final String yearLevel;

  Year({required this.yearId, required this.yearLevel});
}

class User {
  final int? userId;
  final String userFullName;

  User({
    required this.userId,
    required this.userFullName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? '',
      userFullName: json['user_fullname'] ?? '',
    );
  }
}
