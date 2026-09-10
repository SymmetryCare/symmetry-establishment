

import 'package:flutter/cupertino.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';

import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';

class EmployeeDocumentRepository{
  static String employeedocSetup = "/employee-document-type-setup";
  ///patch api
  static String patchEmpDocSetUp({required int employeeDoctypeSetupId}){
    return "$employeedocSetup/$employeeDoctypeSetupId";
  }
}
Future<ApiData> editEmployeeDocTypeSetupId({ required BuildContext context,
  required int employeeDoctypeSetupId,
  required String docName,



  required int threshold,
}
    ) async {
  try {
    final companyId = await TokenManager.getCompanyId();
    Map data = {
      "DocumentName": docName,



      "threshold": threshold,
    };
    print("::::::=>${data}");
      var response = await Api(context).patch(path:
    EmployeeDocumentRepository.patchEmpDocSetUp(
        employeeDoctypeSetupId: employeeDoctypeSetupId
      // empId : employeeTypeId,
    ),
        data:data

    );
    print('Patch Emp doc ::::$response ');
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Employee Doc type Updated");
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