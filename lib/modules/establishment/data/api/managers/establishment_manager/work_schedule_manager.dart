import 'package:flutter/cupertino.dart';

import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/establishment_manager/establishment_repository.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/work_schedule/work_week_data.dart';

/// Manage HR → Work Schedule: work weeks, shifts, shift batches and holidays.
///
/// Reconstructed from the call sites in
/// `modules/establishment/presentation/screens/manage_hr/manage_work_schedule`;
/// the original lived in the `prohealth` monolith and did not come across with
/// the extracted screens. Every endpoint below comes from
/// [EstablishmentManagerRepository], which the extraction did carry over.
/// Error handling matches the sibling managers here: log and return an empty
/// result, because the call sites feed these into Stream/FutureBuilders.

String _s(dynamic v) => v == null ? '' : '$v';
int _i(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

// ── work weeks ─────────────────────────────────────────────────────────────

/// GET /work-week-schedule
Future<List<WorkWeekScheduleData>> workWeekScheduleGet(
    BuildContext context) async {
  List<WorkWeekScheduleData> itemsList = [];
  try {
    final response = await Api(context)
        .get(path: EstablishmentManagerRepository.workWeekScheduleGet());
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in (response.data as List)) {
        itemsList.add(WorkWeekScheduleData(
          workWeekScheduleId: _i(item['WorkWeekScheduleId']),
          companyId: _i(item['CompanyId']),
          weekDays: _s(item['WeekDays']),
          officeStartTime: _s(item['OfficeStartTime']),
          officeEndTime: _s(item['OfficeEndTime']),
          success: true,
          message: response.statusMessage ?? '',
        ));
      }
    }
    return itemsList;
  } catch (e) {
    print("workWeekScheduleGet error $e");
    return itemsList;
  }
}

/// GET /work-week-shift-schedule/findByWeekDay/{weekDay}/{companyId}
Future<List<WorkWeekShiftScheduleData>> workWeekShiftScheduleGet(
    BuildContext context, String weekDay) async {
  List<WorkWeekShiftScheduleData> itemsList = [];
  try {
    final int companyId = await TokenManager.getCompanyId();
    final response = await Api(context).get(
        path: EstablishmentManagerRepository.workWeekShiftScheduleGet(
            companyId: companyId, weekDay: weekDay));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in (response.data as List)) {
        itemsList.add(WorkWeekShiftScheduleData(
          weekShiftScheduleId: _i(item['WeekShiftScheduleId']),
          companyId: _i(item['CompanyId']),
          weekDays: _s(item['WeekDays']),
          shiftName: _s(item['ShiftName']),
          shiftStartTime: _s(item['ShiftStartTime']),
          shiftEndTime: _s(item['ShiftEndTime']),
          success: true,
          message: response.statusMessage ?? '',
        ));
      }
    }
    return itemsList;
  } catch (e) {
    print("workWeekShiftScheduleGet error $e");
    return itemsList;
  }
}

/// POST /work-week-shift-schedule/add
Future<ApiData> addWorkWeekShiftPost(
  BuildContext context,
  String weekDays,
  String shiftName,
  String shiftStartTime,
  String shiftEndTime,
) async {
  try {
    final int companyId = await TokenManager.getCompanyId();
    final response = await Api(context).post(
      path: EstablishmentManagerRepository.addWorkWeekShiftPost(),
      data: {
        "CompanyId": companyId,
        "WeekDays": weekDays,
        "ShiftName": shiftName,
        "ShiftStartTime": shiftStartTime,
        "ShiftEndTime": shiftEndTime,
      },
    );
    return ApiData(
      success: response.statusCode == 200 || response.statusCode == 201,
      message: response.statusMessage ?? '',
      statusCode: response.statusCode ?? 0,
      data: response.data,
    );
  } catch (e) {
    print("addWorkWeekShiftPost error $e");
    return ApiData(success: false, message: '$e', statusCode: 0);
  }
}

/// DELETE /work-week-shift-schedule/{workWeekShiftId}
Future<ApiData> deleteWorkWeekSiftSchedule({
  required BuildContext context,
  required int workWeekShiftId,
}) async {
  try {
    final response = await Api(context).delete(
        path: EstablishmentManagerRepository.deleteWorkWeekShict(
            workWeekShiftId: workWeekShiftId));
    return ApiData(
      success: response.statusCode == 200 || response.statusCode == 201,
      message: response.statusMessage ?? '',
      statusCode: response.statusCode ?? 0,
      data: response.data,
    );
  } catch (e) {
    print("deleteWorkWeekSiftSchedule error $e");
    return ApiData(success: false, message: '$e', statusCode: 0);
  }
}

// ── shift batches ──────────────────────────────────────────────────────────

/// GET /work-week-shift-schedule/batch/{weekDay}/{shiftName}/{companyId}
Future<List<ShiftBachesData>> shiftBatchesGet(
    BuildContext context, String shiftName, String weekDay) async {
  List<ShiftBachesData> itemsList = [];
  try {
    final int companyId = await TokenManager.getCompanyId();
    final response = await Api(context).get(
        path: EstablishmentManagerRepository.getShiftBatches(
            shiftName: shiftName, companyId: companyId, weekDay: weekDay));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in (response.data as List)) {
        itemsList.add(ShiftBachesData(
          shiftBatchScheduleId: _i(item['ShiftBatchScheduleId']),
          companyId: _i(item['CompanyId']),
          weekDays: _s(item['WeekDays']),
          shiftName: _s(item['ShiftName']),
          officeStartTime: _s(item['OfficeStartTime']),
          officeEndTime: _s(item['OfficeEndTime']),
          success: true,
          message: response.statusMessage ?? '',
        ));
      }
    }
    return itemsList;
  } catch (e) {
    print("shiftBatchesGet error $e");
    return itemsList;
  }
}

/// GET /work-week-shift-schedule/getbatchBy/{shiftBatchId}
Future<ShiftBachesData> shiftPrefillBatchesGet(
    BuildContext context, int shiftBatchId) async {
  ShiftBachesData empty = ShiftBachesData(
    shiftBatchScheduleId: shiftBatchId,
    companyId: 0,
    weekDays: '',
    shiftName: '',
    officeStartTime: '',
    officeEndTime: '',
    success: false,
    message: '',
  );
  try {
    final response = await Api(context).get(
        path: EstablishmentManagerRepository.getShiftPrefillBatches(
            shiftBatchId: shiftBatchId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final item =
          response.data is List ? (response.data as List).first : response.data;
      return ShiftBachesData(
        shiftBatchScheduleId: _i(item['ShiftBatchScheduleId']),
        companyId: _i(item['CompanyId']),
        weekDays: _s(item['WeekDays']),
        shiftName: _s(item['ShiftName']),
        officeStartTime: _s(item['OfficeStartTime']),
        officeEndTime: _s(item['OfficeEndTime']),
        success: true,
        message: response.statusMessage ?? '',
      );
    }
    return empty;
  } catch (e) {
    print("shiftPrefillBatchesGet error $e");
    return empty;
  }
}

/// POST /work-week-shift-schedule/batch/
Future<ApiData> addShiftBatch(
  BuildContext context,
  String shiftName,
  String weekDays,
  String startTime,
  String endTime,
) async {
  try {
    final int companyId = await TokenManager.getCompanyId();
    final response = await Api(context).post(
      path: EstablishmentManagerRepository.addShiftBatches(),
      data: {
        "CompanyId": companyId,
        "ShiftName": shiftName,
        "WeekDays": weekDays,
        "OfficeStartTime": startTime,
        "OfficeEndTime": endTime,
      },
    );
    return ApiData(
      success: response.statusCode == 200 || response.statusCode == 201,
      message: response.statusMessage ?? '',
      statusCode: response.statusCode ?? 0,
      data: response.data,
    );
  } catch (e) {
    print("addShiftBatch error $e");
    return ApiData(success: false, message: '$e', statusCode: 0);
  }
}

/// PATCH /work-week-shift-schedule/batch/{shiftBatchScheduleId}
Future<ApiData> updateShiftBatch(
  BuildContext context,
  String shiftName,
  String weekDays,
  String startTime,
  String endTime,
  int shiftBatchScheduleId,
) async {
  try {
    final response = await Api(context).patch(
      path: EstablishmentManagerRepository.modifyShiftBatches(
          shiftBatchScheduleId: shiftBatchScheduleId),
      data: {
        "ShiftName": shiftName,
        "WeekDays": weekDays,
        "OfficeStartTime": startTime,
        "OfficeEndTime": endTime,
      },
    );
    return ApiData(
      success: response.statusCode == 200 || response.statusCode == 201,
      message: response.statusMessage ?? '',
      statusCode: response.statusCode ?? 0,
      data: response.data,
    );
  } catch (e) {
    print("updateShiftBatch error $e");
    return ApiData(success: false, message: '$e', statusCode: 0);
  }
}

/// DELETE /work-week-shift-schedule/batch/{shiftBatchScheduleId}
Future<ApiData> deleteShiftBatch(
    BuildContext context, int shiftBatchScheduleId) async {
  try {
    final response = await Api(context).delete(
        path: EstablishmentManagerRepository.modifyShiftBatches(
            shiftBatchScheduleId: shiftBatchScheduleId));
    return ApiData(
      success: response.statusCode == 200 || response.statusCode == 201,
      message: response.statusMessage ?? '',
      statusCode: response.statusCode ?? 0,
      data: response.data,
    );
  } catch (e) {
    print("deleteShiftBatch error $e");
    return ApiData(success: false, message: '$e', statusCode: 0);
  }
}

// ── holidays ───────────────────────────────────────────────────────────────

/// GET /holidays
Future<List<DefineHolidayData>> holidaysListGet(BuildContext context) async {
  List<DefineHolidayData> itemsList = [];
  try {
    final response = await Api(context)
        .get(path: EstablishmentManagerRepository.holidaysGet());
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in (response.data as List)) {
        itemsList.add(DefineHolidayData(
          holidayId: _i(item['HolidayId']),
          companyId: _i(item['CompanyId']),
          holidayName: _s(item['HolidayName']),
          date: _s(item['Date']),
          success: true,
          message: response.statusMessage ?? '',
        ));
      }
    }
    return itemsList;
  } catch (e) {
    print("holidaysListGet error $e");
    return itemsList;
  }
}

/// GET /holidays/{holidayId}
Future<DefinePrefillHolidayData> holidaysPrefillGet(
    BuildContext context, int holidayId) async {
  DefinePrefillHolidayData empty = DefinePrefillHolidayData(
    holidayId: holidayId,
    companyId: 0,
    holidayName: '',
    date: '',
    success: false,
    message: '',
  );
  try {
    final response = await Api(context).get(
        path: EstablishmentManagerRepository.holidaysPrefillGet(
            holidayId: holidayId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final item =
          response.data is List ? (response.data as List).first : response.data;
      return DefinePrefillHolidayData(
        holidayId: _i(item['HolidayId']),
        companyId: _i(item['CompanyId']),
        holidayName: _s(item['HolidayName']),
        date: _s(item['Date']),
        success: true,
        message: response.statusMessage ?? '',
      );
    }
    return empty;
  } catch (e) {
    print("holidaysPrefillGet error $e");
    return empty;
  }
}

/// POST /holidays/add
Future<ApiData> addHolidaysPost(
  BuildContext context,
  String holidayName,
  String date,
  int year,
) async {
  try {
    final int companyId = await TokenManager.getCompanyId();
    final response = await Api(context).post(
      path: EstablishmentManagerRepository.addHolidaysPost(),
      data: {
        "CompanyId": companyId,
        "HolidayName": holidayName,
        "Date": date,
        "Year": year,
      },
    );
    return ApiData(
      success: response.statusCode == 200 || response.statusCode == 201,
      message: response.statusMessage ?? '',
      statusCode: response.statusCode ?? 0,
      data: response.data,
    );
  } catch (e) {
    print("addHolidaysPost error $e");
    return ApiData(success: false, message: '$e', statusCode: 0);
  }
}

/// PATCH /holidays/{holidayId}
Future<ApiData> updateHolidays(
  BuildContext context,
  int holidayId,
  String holidayName,
  String date,
  int year,
) async {
  try {
    final response = await Api(context).patch(
      path: EstablishmentManagerRepository.updateHolidaysPatch(
          holidayId: holidayId),
      data: {"HolidayName": holidayName, "Date": date, "Year": year},
    );
    return ApiData(
      success: response.statusCode == 200 || response.statusCode == 201,
      message: response.statusMessage ?? '',
      statusCode: response.statusCode ?? 0,
      data: response.data,
    );
  } catch (e) {
    print("updateHolidays error $e");
    return ApiData(success: false, message: '$e', statusCode: 0);
  }
}

/// DELETE /holidays/{holidayId}
Future<ApiData> deleteHolidays(BuildContext context, int holidayId) async {
  try {
    final response = await Api(context).delete(
        path: EstablishmentManagerRepository.deleteHolidaysDelete(
            holidayId: holidayId));
    return ApiData(
      success: response.statusCode == 200 || response.statusCode == 201,
      message: response.statusMessage ?? '',
      statusCode: response.statusCode ?? 0,
      data: response.data,
    );
  } catch (e) {
    print("deleteHolidays error $e");
    return ApiData(success: false, message: '$e', statusCode: 0);
  }
}
