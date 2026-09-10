import 'package:flutter/cupertino.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/establishment_manager/employee_doc_repository.dart';

import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/employee_doc/employee_doc_data.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/establishment_manager/all_from_hr_repository.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/establishment_manager/establishment_repository.dart';

/// GET employee-document-type-meta-data in tab bar
Future<List<EmployeeDocTabModal>> getEmployeeDocTab(BuildContext context,
    ) async {
  List<EmployeeDocTabModal> itemsList = [];
  try {
    final response = await Api(context)
        .get(path: EstablishmentManagerRepository.getEmployeeDocSetup(
    ));
    if (response.statusCode == 200 || response.statusCode == 201) {
      // print("Org Document response:::::${itemsList}");
      print("1212");
      for(var item in response.data){
        itemsList.add(
          EmployeeDocTabModal(
            employeeDocType: item['EmployeeDocumentType']== null ?"null" :item['EmployeeDocumentType'],
            employeeDocMetaDataId: item['EmployeeDocumentTypeMetaDataId']== null ? 0 :item['EmployeeDocumentTypeMetaDataId'],
            success: true,
            message: response.statusMessage!,
          ),
        );
      }
      print("Employee Document Response:::::${itemsList}");
    } else {
      print('Employee Document');
      return itemsList;
    }
    // print("Org response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

/// Get employee document setup drop down
Future<List<EmployeeDocSetupModal>> getEmployeeDocSetupDropDown(BuildContext context,
    int empDocMetaId
    ) async {
  List<EmployeeDocSetupModal> itemsList = [];
  try {
    final response = await Api(context)
        .get(path: EstablishmentManagerRepository.getEmployeDocSetupDropdown(empDocMetaId: empDocMetaId
    ));
    if (response.statusCode == 200 || response.statusCode == 201) {
      // print("Org Document response:::::${itemsList}");
      print("1212");
      for(var item in response.data){
        itemsList.add(
          EmployeeDocSetupModal(
            employeeDocMetaDataId: item['EmployeeDocumentTypeMetaDataId']?? 0,
            success: true,
            message: response.statusMessage!,
            employeeDocTypeSetupId: item['EmployeeDocumentTypeSetupId'],
            documentName: item['DocumentName']??"--",
            expiry: item['Expiry'],
            reminderThreshould: item['ReminderThreshold']??"--",
            idOfDocument: item['idOfDocument']??"--",
            expirtType: item['expiry_type']??"--",
            companyId: item['companyId']??0,
            threshold: item['threshold']??0,
          ),
        );
      }
    } else {
      print('Employee Document Setup drop down');
      return itemsList;
    }
    // print("Org response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

/// GET employee-document-type-setup/{EmployeeDocumentTypeMetaDataId}/{pageNbr}/{NbrofRows}
Future<List<EmployeeDocumentModal>> getEmployeeDoc(BuildContext context,
    int employeeDocTypeMetataId,
    int pageNo,
    int rowsNo
    ) async {
  List<EmployeeDocumentModal> itemsList = [];
  try {
    final companyId = await TokenManager.getCompanyId();
    final response = await Api(context)
        .get(path: EstablishmentManagerRepository.getEmployeeDocSetUpMetaId(
         // metaDocId: metaDocID
        pageNo: pageNo,
        rowsNo: rowsNo,
        employeeDocTypeMetaDataId:  employeeDocTypeMetataId,
    ));
    if (response.statusCode == 200 || response.statusCode == 201) {
      // print("Org Document response:::::${itemsList}");
      print("1");
      for(var item in response.data['data']){
        itemsList.add(EmployeeDocumentModal(
              docName: item["DocumentName"],
              expiry: item["Expiry"] ?? "",
              reminderThreshold: item["ReminderThreshold"],
              employeeDocTypesetupId: item['EmployeeDocumentTypeSetupId'],
              employeeDocTypeMetaId: item['EmployeeDocumentTypeMetaDataId'],
              idOfDocument: item['idOfDocument'],
              expiryType: item['expiry_type'],
            threshold: item['threshold'] ?? 0,
              companyId: companyId,
              sucess: true,
              message: response.statusMessage!
          ),
        );
      }
      print("Employee setup Response:::::${response.data}");
    } else {
      print('Employee Document Error');
      return itemsList;
    }
    // print("Org response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

///Add employee doc type setup Id
Future<ApiData> addEmployeeDocSetup({
  required BuildContext context,
  required String docName,
  required String? expiryDate,
  required String remainderThreshold,
  required int empDocMetaDataId,
  required String idOfDoc,
  required String expiryType,
  required int threshold,

}) async {
  try {
    final companyId = await TokenManager.getCompanyId();
    var data = {
      "DocumentName": docName,
      "Expiry": expiryDate,
      "companyId": companyId,
      "ReminderThreshold": remainderThreshold,
      "EmployeeDocumentTypeMetaDataId": empDocMetaDataId,
      "idOfDocument": idOfDoc,
      "expiry_type": expiryType,
      "threshold": threshold,
    };

    print('New EMP doc $data');
    var response = await Api(context).post(
        path: EstablishmentManagerRepository.addEmployeDocSetup(),
        data: data);
    print('New EMP post new::::$response ');
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("New EMP Doc addded ");
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
    print("Error 2");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

///DELETE employee doc type setup Id
Future<ApiData> employeedoctypeSetupIdDelete(
    BuildContext context,
    int employeeDocTypeSetupId
    ) async {
  try {
    var response = await Api(context).delete(path:
    EstablishmentManagerRepository.deleteEmployeedoctypesetup(
         employeeDoctypeSetupId: employeeDocTypeSetupId
    ));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Employee Document Deleted");
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
///POST employee doc type setup
Future<ApiData> employeeDocTypeSetupIDPost(
    BuildContext context,
    int employeeDoctypeSetupId

    ) async {
  try {
    var response = await Api(context).post(path:
    EstablishmentManagerRepository.postEmployeedocTypesetup(
        employeeDoctypeSetupId: employeeDoctypeSetupId
    ), data:
    {

    });
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
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

/// GET Prefill employee-document-type-Setuo-data
Future<GetEmployeeSetupPrefillData> getPrefillEmployeeDocTab(BuildContext context,
   int  empDocTypeId) async {
  var itemsList;
  try {
    final companyId = await TokenManager.getCompanyId();
    final response = await Api(context)
        .get(path: EstablishmentManagerRepository.getPrefillEmployeDocSetup(empDocTypeId: empDocTypeId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      // print("Org Document response:::::${itemsList}");
      print("1212");

        itemsList =
            GetEmployeeSetupPrefillData(
              docName: response.data["DocumentName"],
              expiry: response.data["Expiry"],
              reminderThreshold: response.data["ReminderThreshold"],
              employeeDocTypesetupId: response.data['EmployeeDocumentTypeSetupId'],
              employeeDocTypeMetaId: response.data['EmployeeDocumentTypeMetaDataId'],
                idOfDocument: response.data['idOfDocument'] ?? "--",
                expiryType: response.data['expiry_type'] ?? "--",
                threshold: response.data['threshold'] ?? 0,
              companyId: companyId,
              sucess: true,
              message: response.statusMessage!
          );
    } else {
      print('Employee Document');
      return itemsList;
    }
    // print("Org response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}
