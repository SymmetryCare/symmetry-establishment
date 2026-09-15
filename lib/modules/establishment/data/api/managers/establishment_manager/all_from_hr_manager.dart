import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/establishment_manager/establishment_repository.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/all_from_hr/all_from_hr_data.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/establishment_manager/all_from_hr_repository.dart';

///get hrTab
Future<List<HRHeadBar>> companyHRHeadApi(
    BuildContext context, int deptId) async {
  List<HRHeadBar> itemsList = [];
  try {
    final response =
        await Api(context).get(path: AllFromHrRepository.getHrType());
    print('Prachi ::::::::;;;;${deptId}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("ResponseList:::::${itemsList}");
      for (var item in response.data) {
        itemsList.add(HRHeadBar(
            deptId: item['departmentId'] ?? 0,
            deptName: item['departmentName'] ?? '',
            deptDescp: item['description'] ?? '',
            sucess: true,
            message: response.statusMessage!));
      }
      print("ResponseList:::::${itemsList}");
    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

/// Get Company data
Future<List<HRClinical>> companyAllHrClinicApi(BuildContext context) async {
  List<HRClinical> itemsList = [];
  try {
    final response =
        await Api(context).get(path: AllFromHrRepository.getEmployeeType());
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(
          HRClinical(
            employeeTypesId: item['employeeTypeId'],
            empType: item['employeeType'],
            abbrivation: item['abbreviation'],
            color: item['color'],
          ),
        );
      }
    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

/// Get data by depart ment ID
Future<List<HRAllData>> getAllHrDeptWise(
    BuildContext context, int deptId) async {
  List<HRAllData> itemsList = [];
  try {
    final response = await Api(context)
        .get(path: AllFromHrRepository.getEmployeeTypeDeptWise(deptId: deptId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        final rawChildIds = item['childEmpTypeId'];
        final rawChildNames = item['childEmpTypeNames'];

        itemsList.add(
          HRAllData(
            deptID: _parseInt(item['DepartmentId']),
            employeeTypesId: _parseInt(item['employeeTypeId']),
            empType: item['employeeType']?.toString(),
            abbrivation: item['abbreviation']?.toString(),
            color: item['color']?.toString(),
            roleId: _parseInt(item['roleId']),
            roleName: item['roleName']?.toString(),
            masterEmpTypeId: _parseInt(item['masterEmpTypeId']),
            masterEmpTypeName: item['masterEmpTypeName']?.toString(),
            childEmpTypeId: rawChildIds is List
                ? rawChildIds
                .map((e) => _parseInt(e))
                .where((id) => id != 0)
                .toList()
                : [],
            childEmpTypeNames: rawChildNames is List
                ? rawChildNames
                .where((e) => e != null && e.toString().isNotEmpty)
                .map((e) => e.toString())
                .toList()
                : [],
            templateIdSalaried: _parseInt(item['templateId_salaried']),
            templateIdParttime: _parseInt(item['templateId_parttime']),
            templateIdPerdiem: _parseInt(item['templateId_perdiem']),
          ),
        );
      }
    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

int _parseInt(dynamic val) {
  if (val == null) return 0;
  if (val is int) return val;
  if (val is double) return val.toInt();
  return int.tryParse(val.toString()) ?? 0;
}

/// Role master data
Future<List<RoleMasterData>> getAllMasterRole(
    BuildContext context, ) async {
  List<RoleMasterData> itemsList = [];
  try {
    final response = await Api(context)
        .get(path: AllFromHrRepository.getRoleMaster());
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("ResponseList:::::${itemsList}");
      for (var item in response.data) {
        itemsList.add(
          RoleMasterData(
            roleId: item['roleId'] ?? 0,
            roleName: item['roleName'] ?? '',
          ),
        );
      }

    } else {
      print('Api Error');
    }

    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

///get by id
Future<HRGetEmpId> HrGetById(BuildContext context, int empId) async {
  var itemsList;
  try {
    final response = await Api(context)
        .get(path: AllFromHrRepository.getEmpTypeById(empId: empId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("ResponseList:::::${itemsList}");
      //for (var item in response.data) {
      itemsList = HRGetEmpId(
          empTypeId: response.data['employeeTypeId'],
          deptId: response.data['DepartmentId'],
          empType: response.data['employeeType'],
          abbrivation: response.data['abbreviation'],
          color: response.data['color'],
        roleId: response.data['roleId'] ?? 0,
        roleName:  response.data['roleName'] ?? '',
        masterEmpTypeId: response.data['masterEmpTypeId'] ?? 0,
        masterEmpTypeName: response.data['masterEmpTypeName'] ?? '',
        childEmpTypeId: response.data['childEmpTypeId'] != null ? List<int>.from(response.data['childEmpTypeId']) : [],
        childEmpTypeNames: response.data['childEmpTypeNames'] != null ? List<String>.from(response.data['childEmpTypeNames']) : [],
        templateIdSalaried: response.data['templateId_salaried'] ?? 0,
        templateIdParttime: response.data['templateId_parttime'] ?? 0,
        templateIdPerdiem: response.data['templateId_perdiem'] ?? 0,
       );
      //}
      print("ResponseList:::::${itemsList}");
    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

/// Add employee type data POST
/// Add employee type data POST
Future<ApiData> addEmployeeTypePost(
    BuildContext context,
    int departmentId,
    String employeeType,
    String color,
    String abbreviation,
    int masterEmpTypeId,
    int roleId,
    List<int> childEmpTypeId,
    int salariedId,
    int partTimeId,
    int perdiemId,
    ) async {
  try {
    var response = await Api(context).post(
        path: EstablishmentManagerRepository.addEmployeeTypePost(),
        data: {
          'DepartmentId': departmentId,
          'employeeType': employeeType,
          'color': "${color}",
          'abbreviation': abbreviation,
          "roleId": roleId,
          "masterEmpTypeId": masterEmpTypeId,
          "childEmpTypeId": childEmpTypeId,
          "templateId_salaried": salariedId,
          "templateId_parttime": partTimeId,
          "templateId_perdiem": perdiemId
          // 'is_assistant': isassistant,
          // "assistant_master_id": assistantmaster
        });
    print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Employee type Added");
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!);
    } else {
      print("Error 1");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          // ✅ FIX: surface the real server message when present, fall back
          // to statusMessage only if the body didn't include one
          message: response.data is Map && response.data['message'] != null
              ? response.data['message'].toString()
              : (response.statusMessage ?? AppString.somethingWentWrong));
    }
  } on DioException catch (e) {
    // ✅ NEW — split from generic catch so real server error messages
    // (validation errors, duplicate name, etc.) actually reach the UI
    // instead of always showing the generic "somethingWentWrong" text.
    print("DioException $e");
    final serverMessage = e.response?.data is Map
        ? e.response?.data['message']?.toString()
        : null;
    return ApiData(
      statusCode: e.response?.statusCode ?? 404,
      success: false,
      // ✅ 404 with a response body still proves server reachability —
      // show the real message if the server sent one
      message: serverMessage ?? AppString.somethingWentWrong,
    );
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}
///delete allfromHr Clinical
Future<ApiData> allfromHrDelete(
    BuildContext context, int employeeTypeId) async {
  try {
    var response = await Api(context).delete(
        path: EstablishmentManagerRepository.deleteEmployeeTypes(
            employeeTypeId: employeeTypeId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Hr Doc Deleted");
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!);
    } else {
      print("Error 1");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

///patch
Future<ApiData> AllFromHrPatch(
  BuildContext context,
  int employeeTypeId,
  int deptId,
  String empType,
  String abbreviation,
  String color,
    int roleId,
    int masterEmpTypeId,
    List<int> childEmpTypeId,
    int salariedTemplateId,
    int partTimeTemplateId,
    int perdiemTemplateId
) async {
  try {
    var allData = {
      "DepartmentId": deptId,
      "employeeType": empType,
      "color": color,
      "abbreviation": abbreviation,
      "roleId": roleId,
      "masterEmpTypeId": masterEmpTypeId,
      "childEmpTypeId": childEmpTypeId,
      "templateId_salaried": salariedTemplateId,
      "templateId_parttime": partTimeTemplateId,
      "templateId_perdiem": perdiemTemplateId
    };
    print('All data ${allData}');
    var response = await Api(context).patch(
        path: AllFromHrRepository.patchHRType(
          empId: employeeTypeId,
        ),
        data: {
          "DepartmentId": deptId,
          "employeeType": empType,
          "color": color,
          "abbreviation": abbreviation,
          "roleId": roleId,
          "masterEmpTypeId": masterEmpTypeId,
          "childEmpTypeId": childEmpTypeId,
          "templateId_salaried": salariedTemplateId,
          "templateId_parttime": partTimeTemplateId,
          "templateId_perdiem": perdiemTemplateId
        });

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Hr Doc updated");
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!);
    } else {
      print("Error 1");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error 11 $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

/// ADD UPDATE OFFER LATTER TEMPLATE
Future<ApiData> postOfferLatterTemplate({
  required BuildContext context,
  required String templateName,
  required String template
}) async {
  try {
    var allData = {
      "templateName": templateName,
      "template": template,
      // "employmentType": empType,
      // "departmentId": deptId,
      // "is_assistant": true
    };

    var response = await Api(context).post(
        path: AllFromHrRepository.addOfferTemplate(),
        data: allData);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Template Added");
      var data = response.data;
      final offerLatterTemplateId = data['templateId'];
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!,
         templateId: offerLatterTemplateId);
    } else {
      print("Error 1");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error 11 $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}
Future<ApiData> patchOfferLatterTemplate({
  required BuildContext context,
  required int templateId,
  required String templateName,
  required String template
}) async {
  try {
    var allData = {
      "templateName": templateName,
      "template": template,
      // "employmentType": empType,
      // "departmentId": deptId,
      // "is_assistant": true
    };

    var response = await Api(context).patch(
        path: AllFromHrRepository.patchOfferTemplate(templateId: templateId),
        data: allData);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Template Updated");
      var data = response.data;
      final offerLatterTemplateId = data['templateId'];
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!,
          templateId: offerLatterTemplateId);
    } else {
      print("Error 1");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error 11 $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}
Future<MasterTemplateData> getPrefillTemplateData({required BuildContext context, required int templateId}) async {
  var itemsList;
  try {
    final response = await Api(context)
        .get(path: AllFromHrRepository.getOfferTemplate(templateId: templateId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      // print("ResponseList:::::${itemsList}");
      //for (var item in response.data) {
      itemsList = MasterTemplateData(
        templateId: response.data['templateId'] ?? 0,
        templateName: response.data['templateName'] ?? '',
        template: response.data['template']??'',
              );
      //}
      print("templateResponse:::::${itemsList}");
    } else {
      print('Api Error');
    }
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}