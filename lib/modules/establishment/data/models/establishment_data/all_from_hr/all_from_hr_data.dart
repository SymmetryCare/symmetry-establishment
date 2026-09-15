import 'dart:ui';
///hr head bar
class HRHeadBar{
  final int deptId;
  final String deptName;
  final String deptDescp;
  final bool sucess;
  final String message;
   HRHeadBar({required this.deptId,required this.deptName, required this.deptDescp,required this.sucess,required this.message,});
}
///getby id
class HRGetEmpId{
  final int empTypeId;
  final int deptId;
  final bool? success;
  final String? message;
  final String? empType;
  final String? abbrivation;
  final String? color;
 final int roleId;
 final String roleName;
 final int masterEmpTypeId;
 final String masterEmpTypeName;
 final int  templateIdSalaried;
 final int templateIdParttime;
  final int templateIdPerdiem;
 final List<int> childEmpTypeId;
 final List<String> childEmpTypeNames;
  HRGetEmpId({required this.empTypeId, required this.deptId, this.success, this.message, this.empType, this.abbrivation, this.color, required this.roleId, required this.roleName, required this.masterEmpTypeId, required this.masterEmpTypeName, required this.childEmpTypeId, required this.childEmpTypeNames, required this.templateIdSalaried, required this.templateIdParttime, required this.templateIdPerdiem,});
}
///hr clinical
class HRClinical {
  final bool? success;
  final String? message;
  final String? empType;
  final String? abbrivation;
  final String? color;
  final int employeeTypesId;

  HRClinical( {
    required this.employeeTypesId,
      this.success, this.message, this.empType, this.abbrivation, this.color});
}



/// Hr All
class HRAllData {
  final int deptID;
  final int employeeTypesId;
  final String? empType;
  final String? abbrivation;
  final String? color;
  final int? roleId;
  final String? roleName;
  final int? masterEmpTypeId;
  final String? masterEmpTypeName;
  final List<int>? childEmpTypeId;
  final List<String>? childEmpTypeNames;   // ← String not String?
  final int? templateIdSalaried;
  final int? templateIdParttime;
  final int? templateIdPerdiem;
  final bool? success;
  final String? message;
  final DateTime? createdAt;

  HRAllData({
    required this.deptID,
    required this.employeeTypesId,
    this.empType,
    this.abbrivation,
    this.color,
    this.roleId,
    this.roleName,
    this.masterEmpTypeId,
    this.masterEmpTypeName,
    this.childEmpTypeId,
    this.childEmpTypeNames,
    this.templateIdSalaried,
    this.templateIdParttime,
    this.templateIdPerdiem,
    this.success,
    this.message,
    this.createdAt,
  });
}

///hr sales
// class HRSales {
//   final bool? success;
//   final String? message;
//   final String? empType;
//   final String? abbrivation;
//   final String? color;
//
//   HRSales({
//       this.success, this.message, this.empType, this.abbrivation, this.color});
// }

///hr administration
// class HRAdministration {
//   final bool? success;
//   final String? message;
//   final String? empType;
//   final String? abbrivation;
//   final String? color;
//
//   HRAdministration({
//       this.success, this.message, this.empType, this.abbrivation, this.color});
// }

///hr all add/edit
// class HRAdd {
//   String employeeType;
//   String shorthand;
//   String typeOfEmployee;
//   Color color;
//
//   HRAdd({
//     required this.employeeType,
//     required this.shorthand,
//     required this.typeOfEmployee,
//     required this.color,
//   });
// }

class RoleMasterData{
  final int roleId;
  final String roleName;
  RoleMasterData({required this.roleId, required this.roleName});
}

class MasterTemplateData{
  final int templateId;
  final String templateName;
  final String template;
  MasterTemplateData({required this.templateId, required this.templateName, required this.template});
}