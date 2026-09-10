import 'package:flutter/cupertino.dart';

import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/establishment_manager/establishment_repository.dart';

/// Employee-type dropdown for Manage HR → add employee designation.
///
/// Reconstructed from the call sites in
/// `.../manage_hr/widgets/add_emp_popup_const.dart`; the original lived in the
/// `prohealth` monolith and did not come across with the extracted screens.
/// The screen builds its dropdown label as `"$abbreviation - $employeeType"`
/// and reads back [EmployeeTypeData.employeeTypeId] on submit.

/// One selectable employee type within a department.
class EmployeeTypeData {
  final int employeeTypeId;
  final int departmentId;
  final String employeeType;
  final String abbreviation;

  EmployeeTypeData({
    required this.employeeTypeId,
    required this.departmentId,
    required this.employeeType,
    required this.abbreviation,
  });
}

/// GET /employee-types/{departmentId}
class EmployeeTypeManager {
  Future<List<EmployeeTypeData>> getEmployeeTypeDropdown(
      BuildContext context, int departmentId) async {
    List<EmployeeTypeData> itemsList = [];
    try {
      final response = await Api(context).get(
          path: EstablishmentManagerRepository.getEmployeeType(
              departmentId: departmentId));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final List items = data is List ? data : (data['data'] ?? []) as List;
        for (var item in items) {
          itemsList.add(EmployeeTypeData(
            employeeTypeId: item['EmployeeTypeId'] is int
                ? item['EmployeeTypeId']
                : int.tryParse('${item['EmployeeTypeId']}') ?? 0,
            departmentId: item['DepartmentId'] is int
                ? item['DepartmentId']
                : int.tryParse('${item['DepartmentId']}') ?? departmentId,
            employeeType: '${item['EmployeeType'] ?? ''}',
            abbreviation: '${item['Abbreviation'] ?? item['Abbrivation'] ?? ''}',
          ));
        }
      }
      return itemsList;
    } catch (e) {
      print("getEmployeeTypeDropdown error $e");
      return itemsList;
    }
  }
}
