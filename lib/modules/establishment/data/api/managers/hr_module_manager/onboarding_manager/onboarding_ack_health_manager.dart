import 'package:flutter/material.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/onboarding_data/onboarding_ack_health_data.dart';

import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/onboarding/onboarding_qualification.dart';

///get ack health
Future<List<OnboardingAckHealthData>> getAckHealthRecord(BuildContext context,
    int EmpDocTypeMetaDataId, int employeeId, String approveOnly) async {
  List<OnboardingAckHealthData> itemsList = [];
  try {
    final response = await Api(context).get(
        path: OnboardingQualificationRepo.getAckHealthRecord(
            EmpDocTypeMetaDataId: EmpDocTypeMetaDataId,
            employeeId: employeeId,
            approveOnly: approveOnly));
    if (response.statusCode == 200 || response.statusCode == 201) {
      // print("Org Document response:::::${itemsList}");
      for (var item in response.data) {
        itemsList.add(OnboardingAckHealthData(
            DocumentName: item['DocumentName'] ?? 'Document Name',
            employeeDocumentId: item['employeeDocumentId'] ?? 1,
            EmployeeDocumentTypeMetaDataId:
                item['EmployeeDocumentTypeMetaDataId'] ?? 10,
            EmployeeDocumentTypeSetupId:
                item['EmployeeDocumentTypeSetupId'] ?? 2,
            employeeId: item['employeeId'] ?? 1,
            DocumentUrl: item['DocumentUrl'] ?? 'null',
            ReminderThreshold: item['ReminderThreshold'] ?? '--',
            Expiry: item['Expiry'] ?? '--',
            DocumentType: item['DocumentType'] ?? '--',
            documentFileName: item['documentNameDefination'] ?? "--",
            approved: item['approved'],
            idOfTheDocument: item['idOfDocument'] ?? "--"));
      }
    } else {
      print('onboarding Document');
      return itemsList;
    }
    // print("Org response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

Future<List<OnboardingAckHealthManageDocData>> getAckDocManageHealthRecord(BuildContext context,
    int EmpDocTypeMetaDataId, int employeeId, String approveOnly) async {
  List<OnboardingAckHealthManageDocData> itemsList = [];
  try {
    final response = await Api(context).get(
        path: OnboardingQualificationRepo.getAckHealthRecord(
            EmpDocTypeMetaDataId: EmpDocTypeMetaDataId,
            employeeId: employeeId,
            approveOnly: approveOnly));
    if (response.statusCode == 200 || response.statusCode == 201) {
      // print("Org Document response:::::${itemsList}");
      for (var item in response.data) {
        itemsList.add(OnboardingAckHealthManageDocData(
            DocumentName: item['DocumentName'] ?? 'Document Name',
            employeeDocumentId: item['employeeDocumentId'] ?? 1,
            EmployeeDocumentTypeMetaDataId:
            item['EmployeeDocumentTypeMetaDataId'] ?? 10,
            EmployeeDocumentTypeSetupId:
            item['EmployeeDocumentTypeSetupId'] ?? 2,
            employeeId: item['employeeId'] ?? 1,
            DocumentUrl: item['DocumentUrl'] ?? 'null',
            ReminderThreshold: item['ReminderThreshold'] ?? '--',
            Expiry: item['Expiry'] ?? '--',
            DocumentType: item['DocumentType'] ?? '--',
            documentFileName: item['documentNameDefination'] ?? "--",
            approved: item['approved'],
            idOfTheDocument: item['idOfDocument'] ?? "--"));
      }
    } else {
      print('onboarding Document');
      return itemsList;
    }
    // print("Org response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

///reject ack health
// Future<ApiData> rejectOnboardAckHealthPatch(BuildContext context, int employeeDocumentId) async {
//   try {
//     var response = await Api(context).patch(
//       path: OnboardingQualificationRepo.rejectAckHealthRecord(employeeDocumentId: employeeDocumentId),
//       data: {},
//     );
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       print("Ack Health rejected$employeeDocumentId");
//       // orgDocumentGet(context);
//       return ApiData(
//           statusCode: response.statusCode!,
//           success: true,
//           message: response.statusMessage!);
//     } else {
//       print("Error 1");
//       return ApiData(
//           statusCode: response.statusCode!,
//           success: false,
//           message: response.data['message']);
//     }
//   } catch (e) {
//     print("Error $e");
//     return ApiData(
//         statusCode: 404, success: false, message: AppString.somethingWentWrong);
//   }
// }

///approve ack health
// Future<ApiData> approveOnboardAckHealthPatch(BuildContext context, int employeeDocumentId) async {
//   try {
//     var response = await Api(context).patch(
//       path: OnboardingQualificationRepo.approveAckHealthRecord(employeeDocumentId: employeeDocumentId),
//       data: {},
//     );
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       print("Ack Health Approved$employeeDocumentId");
//       // orgDocumentGet(context);
//       return ApiData(
//           statusCode: response.statusCode!,
//           success: true,
//           message: response.statusMessage!);
//     } else {
//       print("Error 1");
//       return ApiData(
//           statusCode: response.statusCode!,
//           success: false,
//           message: response.data['message']);
//     }
//   } catch (e) {
//     print("Error $e");
//     return ApiData(
//         statusCode: 404, success: false, message: AppString.somethingWentWrong);
//   }
// }

///batch approve
Future<ApiData> batchApproveOnboardAckHealthPatch(
    BuildContext context, List<int> employeeDocumentId) async {
  try {
    var response = await Api(context).patch(
      path: OnboardingQualificationRepo.batchApproveAckHealthRecord(),
      data: {
        "Ids": employeeDocumentId.map((id) => id).toList(),
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Ack Health batch Approved : ${employeeDocumentId.join(", ")}");
      // orgDocumentGet(context);
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

Future<ApiData> singleBatchApproveOnboardAckHealthPatch(
    BuildContext context, int employeeDocumentId) async {
  try {
    var response = await Api(context).patch(
      path: OnboardingQualificationRepo.singlebatchApproveAckHealthRecord(empDocumentId: employeeDocumentId),
      data: {}
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Ack Health batch Approved :");
      // orgDocumentGet(context);
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
///batch reject
Future<ApiData> batchRejectOnboardAckHealthPatch(
    BuildContext context, List<int> employeeDocumentId) async {
  try {
    var response = await Api(context).patch(
      path: OnboardingQualificationRepo.batchRejectAckHealthRecord(),
      data: {
        "Ids": employeeDocumentId.map((id) => id).toList(),
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Ack Health batch rejected${employeeDocumentId.join(", ")}");
      // orgDocumentGet(context);
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
