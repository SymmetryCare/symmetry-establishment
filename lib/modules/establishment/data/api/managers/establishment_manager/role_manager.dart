import 'package:flutter/cupertino.dart';

import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/establishment_manager/establishment_repository.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/role_manager/role_manager_data.dart';

/// Company Identity → Role Manager.
///
/// Reconstructed from the call sites in
/// `.../company_identity/widgets/ci_tab_widget/widget/ci_role_manager_tab`;
/// the original lived in the `prohealth` monolith and did not come across with
/// the extracted screens. Endpoints come from [EstablishmentManagerRepository].

String _s(dynamic v) => v == null ? '' : '$v';
int _i(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

/// GET /app-module-meta-data — the modules a role can be granted.
Future<List<ModuleMetaData>> roleManagerDataGet(BuildContext context) async {
  List<ModuleMetaData> itemsList = [];
  try {
    final response = await Api(context)
        .get(path: EstablishmentManagerRepository.getRoalMetaData());
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in (response.data as List)) {
        itemsList.add(ModuleMetaData(
          appModuleMetaDataId: _i(item['AppModuleMetaDataId']),
          mainModule: _s(item['MainModule']),
          moduleName: _s(item['ModuleName']),
          screenName: _s(item['ScreenName']),
          success: true,
          message: response.statusMessage ?? '',
        ));
      }
    }
    return itemsList;
  } catch (e) {
    print("roleManagerDataGet error $e");
    return itemsList;
  }
}

/// GET /app-module-meta-data — same list as [roleManagerDataGet], kept under
/// the name the role tabs call in `initState`.
Future<List<ModuleMetaData>> roleMabagerMetaData(BuildContext context) =>
    roleManagerDataGet(context);

/// GET /employee-types/Department/{DepartmentId} — the employee types a role
/// can be scoped to within one department.
Future<List<RoleManagerDepartmentEmpType>> roleManagerGetByDepartmentID(
    BuildContext context, int departmentId) async {
  List<RoleManagerDepartmentEmpType> itemsList = [];
  try {
    final response = await Api(context).get(
        path: EstablishmentManagerRepository.companyDepartmentById(
            DepartmentId: departmentId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in (response.data as List)) {
        itemsList.add(RoleManagerDepartmentEmpType(
          DepartmentId: _i(item['DepartmentId']),
          employeeTypeId: _i(item['EmployeeTypeId']),
          departmentName: _s(item['DepartmentName']),
          employeeType: _s(item['EmployeeType']),
          success: true,
          message: response.statusMessage ?? '',
        ));
      }
    }
    return itemsList;
  } catch (e) {
    print("roleManagerGetByDepartmentID error $e");
    return itemsList;
  }
}
