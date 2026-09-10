import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_dashboard_graph.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/manage_emp/manage_emp_repo.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/dashboard/hr_dashboard_graph_model.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/education_data.dart';

Future<EmployeeSexRatioData> getSexRation(
    {required BuildContext context,}) async {
  String convertIsoToDayMonthYear(String isoDate) {
    // Parse ISO date string to DateTime object
    DateTime dateTime = DateTime.parse(isoDate);

    // Create a DateFormat object to format the date
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    // Format the date into "dd mm yy" format
    String formattedDate = dateFormat.format(dateTime);

    return formattedDate;
  }

  var itemsData;
  try {
    final companyId = await TokenManager.getCompanyId();
    final response = await Api(context).get(
        path: HrGraphRepo.getSexRationPercentage(companyId: companyId,));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<GenderStatistic> genderStats = (response.data['genderStatistics'] as List)
          .map((item) => GenderStatistic(
        gender: item['gender'] ?? 'Unknown',
        count: item['count'] ?? 0,
        percentage: item['percentage'] ?? '0%',
      ))
          .toList();
        //String startDateFormattedDate = item['startDate'] == null ? "--" :convertIsoToDayMonthYear(item['expDate']);
        //String issueFormattedDate = convertIsoToDayMonthYear(item['issueDate']);
        itemsData = EmployeeSexRatioData(totalEmployees: response.data['totalEmployees']??0, genderStatistics: genderStats);


    } else {
      print("Employee Education");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}