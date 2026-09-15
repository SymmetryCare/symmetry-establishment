/// Models for Manage HR → Work Schedule (work weeks, shifts, batches, holidays).
///
/// Reconstructed from the call sites in
/// `modules/establishment/presentation/screens/manage_hr/manage_work_schedule`
/// — the originals lived in the `prohealth` monolith and did not come across
/// with the extracted screens. Field names match what those screens read.

/// A row of `/work-week-schedule` — one configured working day.
class WorkWeekScheduleData {
  final int workWeekScheduleId;
  final int companyId;
  final String weekDays;
  final String officeStartTime;
  final String officeEndTime;

  final bool success;
  final String message;

  WorkWeekScheduleData({
    required this.workWeekScheduleId,
    required this.companyId,
    required this.weekDays,
    required this.officeStartTime,
    required this.officeEndTime,
    required this.success,
    required this.message,
  });
}

/// A row of `/work-week-shift-schedule/findByWeekDay/...` — one shift on a day.
class WorkWeekShiftScheduleData {
  final int? weekShiftScheduleId;
  final int companyId;
  final String weekDays;
  final String shiftName;
  final String shiftStartTime;
  final String shiftEndTime;

  final bool success;
  final String message;

  WorkWeekShiftScheduleData({
    required this.weekShiftScheduleId,
    required this.companyId,
    required this.weekDays,
    required this.shiftName,
    required this.shiftStartTime,
    required this.shiftEndTime,
    required this.success,
    required this.message,
  });
}

/// A row of `/work-week-shift-schedule/batch/...` — one batch inside a shift.
class ShiftBachesData {
  final int shiftBatchScheduleId;
  final int companyId;
  final String weekDays;
  final String shiftName;
  final String officeStartTime;
  final String officeEndTime;

  final bool success;
  final String message;

  ShiftBachesData({
    required this.shiftBatchScheduleId,
    required this.companyId,
    required this.weekDays,
    required this.shiftName,
    required this.officeStartTime,
    required this.officeEndTime,
    required this.success,
    required this.message,
  });
}

/// A row of `/holidays`.
class DefineHolidayData {
  final int holidayId;
  final int companyId;
  final String holidayName;
  final String date;

  final bool success;
  final String message;

  DefineHolidayData({
    required this.holidayId,
    required this.companyId,
    required this.holidayName,
    required this.date,
    required this.success,
    required this.message,
  });
}

/// `/holidays/{holidayId}` — the single holiday behind the edit popup.
class DefinePrefillHolidayData {
  final int holidayId;
  final int companyId;
  final String holidayName;
  final String date;

  final bool success;
  final String message;

  DefinePrefillHolidayData({
    required this.holidayId,
    required this.companyId,
    required this.holidayName,
    required this.date,
    required this.success,
    required this.message,
  });
}
