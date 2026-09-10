class EmployeementData {
  final bool sucess;
  final String message;
  final int employmentId;
  final int employeeId;
  final String employer;
  final String city;
  final String reason;
  final String supervisor;
  final String supMobile;
  final String title;
  final String dateOfJoining;
  final String endDate;
  final String emgMobile;
  final String country;
  final String documentUrl;
  bool? approved;
  EmployeementData({required this.emgMobile, required this.country,required this.sucess, required this.message,
      this.approved,
    required this.documentUrl,
      required this.employmentId,
      required this.employeeId,
      required this.employer,
      required this.city,
      required this.reason,
      required this.supervisor,
      required this.supMobile,
      required this.title,
      required this.dateOfJoining,
      required this.endDate});
}

class EmployeementPrefillData {
  final bool sucess;
  final String message;
  final int employmentId;
  final int employeeId;
  final String employer;
  final String city;
  final String reason;
  final String supervisor;
  final String supMobile;
  final String title;
  final String dateOfJoining;
  final String endDate;
  bool? approved;
  final String emgMobile;
  final String country;
  EmployeementPrefillData({required this.emgMobile, required this.country,required this.sucess, required this.message,
      this.approved,
        required this.employmentId,
        required this.employeeId,
        required this.employer,
        required this.city,
        required this.reason,
        required this.supervisor,
        required this.supMobile,
        required this.title,
        required this.dateOfJoining,
        required this.endDate});
}
