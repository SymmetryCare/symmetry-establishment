// GET employee-document-type-setup/{EmployeeDocumentTypeMetaDataId}/{pageNbr}/{NbrofRows}

import 'package:flutter/material.dart';

import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/progress_form_data/form_health_record_data.dart';
import 'package:symmetry_establishment/app/services/api/api_offer.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/form_repository/form_general_repo.dart';

Future<List<HREmployeeDocumentModal>> getHREmployeeDoc(
    BuildContext context,
    // int metaDocID
    int employeeDocTypeMetataId,
    int pageNo,
    int rowsNo) async {
  List<HREmployeeDocumentModal> itemsList = [];
  try {

    final response = await ApiOffer(context).get(
        path: ProgressBarRepository.getEmployeeDocSetUpMetaIdHR(
      // metaDocId: metaDocID
      pageNo: pageNo,
      rowsNo: rowsNo,
      employeeDocTypeMetaDataId: employeeDocTypeMetataId,
    ));
    if (response.statusCode == 200 || response.statusCode == 201) {
      // print("Org Document response:::::${itemsList}");
      print("1");
      for (var item in response.data["data"]) {
        itemsList.add(
          HREmployeeDocumentModal(
              docName: item["DocumentName"],
              expiry: item["Expiry"],
              reminderThreshold: item["ReminderThreshold"],
              employeeDocTypesetupId: item['EmployeeDocumentTypeSetupId'],
              employeeDocTypeMetaId: item['EmployeeDocumentTypeMetaDataId'],
              sucess: true,
              message: response.statusMessage!),
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
