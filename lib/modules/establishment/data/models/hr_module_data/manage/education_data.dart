class EducationData {
  final bool sucess;
  final String message;
  final int educationId;
  final int employeeID;
  final String graduate;
  final String degree;
  final String major;
  final String city;
  final String college;
  final String phone;
  final String state;
  bool? approved;
  final String country;
  final String startDate;
  EducationData({
    required this.sucess,
    required this.message,
    required this.country,
    required this.startDate,
    this.approved,
    required this.educationId,
    required this.employeeID,
    required this.graduate,
    required this.degree,
    required this.major,
    required this.city,
    required this.college,
    required this.phone,
    required this.state,
  });
}

class EducationPrefillData {
  final bool sucess;
  final String message;
  final int educationId;
  final int employeeID;
  final String graduate;
  final String degree;
  final String major;
  final String city;
  final String college;
  final String phone;
  final String state;
  bool? approved;
  final String country;
  final String startDate;
  EducationPrefillData({
    required this.country,
    required this.startDate,
    required this.sucess,
    required this.message,
    this.approved,
    required this.educationId,
    required this.employeeID,
    required this.graduate,
    required this.degree,
    required this.major,
    required this.city,
    required this.college,
    required this.phone,
    required this.state,
  });
}
