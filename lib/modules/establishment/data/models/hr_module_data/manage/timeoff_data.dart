class TimeOfffData {
  final int employeeTimeOffId;
  final int employeeId;
  final int userId;
  final int timeOffTypeId;
  final int leaveTypeId;
  final String startDate;
  final String endDate;
  final String reason;
  final String createdAt;
  final String updatedAt;
  final bool firstHalf;
  final String timeOffStatus;
  final String imageUrl;
  final String employeeName;

  TimeOfffData({
    required this.employeeTimeOffId,
    required this.employeeId,
    required this.userId,
    required this.timeOffTypeId,
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.createdAt,
    required this.updatedAt,
    required this.firstHalf,
    required this.timeOffStatus,
    required this.imageUrl,
    required this.employeeName
  });


}

class TimeOfPrefillData {
  final int timeOffId;
  final int employeeId;
  final int userId;
  final int timeOffTypeId;
  final int leaveTypeId;
  final String startDate;
  final String endDate;
  final String reason;
  final bool firstHalf;
  final String timeOffStatus;

  TimeOfPrefillData({
    required this.timeOffId,
    required this.employeeId,
    required this.userId,
    required this.timeOffTypeId,
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    required this.timeOffStatus,
    required this.firstHalf,
    required this.reason
  });

}
