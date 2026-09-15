/// Models for Company Identity → Role Manager.
///
/// Reconstructed from the call sites in
/// `.../company_identity/widgets/ci_tab_widget/widget/ci_role_manager_tab`;
/// the originals lived in the `prohealth` monolith and did not come across
/// with the extracted screens.

/// A row of `/app-module-meta-data` — one app module a role can be granted.
class ModuleMetaData {
  final int appModuleMetaDataId;

  /// Top-level module this screen belongs to; the role tabs group by it.
  final String mainModule;
  final String moduleName;
  final String screenName;

  final bool success;
  final String message;

  ModuleMetaData({
    required this.appModuleMetaDataId,
    required this.mainModule,
    required this.moduleName,
    required this.screenName,
    required this.success,
    required this.message,
  });
}

/// A department's employee types, used to scope a role to a department.
class RoleManagerDepartmentEmpType {
  /// Capitalised to match the API field and the call sites.
  final int DepartmentId;
  final int employeeTypeId;
  final String departmentName;
  final String employeeType;

  final bool success;
  final String message;

  RoleManagerDepartmentEmpType({
    required this.DepartmentId,
    required this.employeeTypeId,
    required this.departmentName,
    required this.employeeType,
    required this.success,
    required this.message,
  });
}
