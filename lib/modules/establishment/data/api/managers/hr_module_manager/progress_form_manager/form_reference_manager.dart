import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/app/services/api/api_offer.dart';

import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/progress_form_data/form_reference_data.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/form_repository/form_general_repo.dart';


String _extractServerMessage(dynamic data) {
  try {
    if (data == null) return AppString.somethingWentWrong;

    final map = data as Map<String, dynamic>;
    final rawMessage = map['message'];

    if (rawMessage is List) {
      final details = _extractFieldErrors(data);
      if (details.isEmpty) return AppString.somethingWentWrong;
      return details.map((d) => d.message).join('\n');
    }

    if (rawMessage is String) {
      return rawMessage;
    }

    return AppString.somethingWentWrong;
  } catch (e) {
    print("Error parsing server message: $e");
    return AppString.somethingWentWrong;
  }
}

List<ErrorDetail> _extractFieldErrors(dynamic data) {
  try {
    if (data == null) return [];

    final map = data as Map<String, dynamic>;
    final rawMessage = map['message'];

    if (rawMessage is List) {
      return rawMessage
          .map((e) => ErrorDetail(
        (e['key'] ?? '').toString(),
        (e['message'] ?? '').toString(),
      ))
          .toList();
    }

    return [];
  } catch (e) {
    print("Error parsing field errors: $e");
    return [];
  }
}

// ---------------------------------------------------------------------------
// Manager function
// ---------------------------------------------------------------------------

Future<ApiDataRegister> postreferencescreenData(
    BuildContext context,
    String association,
    String comment,
    String company,
    String email,
    int employeeId,
    String mob,
    String name,
    String references,
    String title) async {
  try {
    var response = await ApiOffer(context).post(
      path: ProgressBarRepository.postreferencescreen(),
      data: {
        "association": association,
        "comment": comment,
        "company": company,
        "email": email,
        "employeeId": employeeId,
        "mob": mob,
        "name": name,
        "references": references,
        "title": title
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("reference Added");
      return ApiDataRegister(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!);
    } else {
      final msg = _extractServerMessage(response.data);
      final fieldErrors = _extractFieldErrors(response.data);
      print("Error 1: $msg");

      // NOTE: kept your existing dialog call — consider removing this,
      // since the caller (ReferencesScreen) already shows a popup/toast
      // based on the returned ApiDataRegister. Showing a dialog here too
      // means the user could see two error/success popups stacked.
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AddErrorPopup(
            message: msg,
          );
        },
      );

      return ApiDataRegister(
        statusCode: response.statusCode!,
        success: false,
        message: msg,
        fieldErrors: fieldErrors, // NEW
      );
    }
  } catch (e) {
    print("Error $e");
    return ApiDataRegister(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}


///prifill api get
///
Future<List<ReferenceDataForm>> getEmployeeReferenceForm(
    BuildContext context, int employeeId) async {
  String convertIsoToDayMonthYear(String isoDate) {
    // Parse ISO date string to DateTime object
    DateTime dateTime = DateTime.parse(isoDate);

    // Create a DateFormat object to format the date
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    // Format the date into "dd mm yy" format
    String formattedDate = dateFormat.format(dateTime);

    return formattedDate;
  }

//var itemList ;
  List<ReferenceDataForm> itemsData = [];
  try {
    final response = await ApiOffer(context).get(
        path: ProgressBarRepository
            .getReferenceByEmpID(employeeID: employeeId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        //String startDateFormattedDate = item['startDate'] == null ? "--" :convertIsoToDayMonthYear(item['expDate']);
        //String issueFormattedDate = convertIsoToDayMonthYear(item['issueDate']);
        itemsData.add(ReferenceDataForm(
            referenceId: item['referenceId'],
            association: item['association'],
            comment: item['comment'],
            company: item['company'],
            email:item['email'],
            employeeId:item['employeeId'],
            mob: item['mob'],
            name: item['name'],
            references:item['references'],
            title: item['title'],
        ));
        // itemsData.sort((a, b) => a.educationId.compareTo(b.educationId));
      }
    } else {
      print("Employee References ");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}
