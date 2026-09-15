class EmpDocHealth {
  final String? name;
  final String? expiry;
  final String? reminderThreshold;

  EmpDocHealth({this.name, this.expiry, this.reminderThreshold});
}

class EmpDocCertification {
  final String? name;
  final String? expiry;
  final String? reminderThreshold;

  EmpDocCertification({this.name, this.expiry, this.reminderThreshold});
}

class EmployeeDocumentModal {
  final int employeeDocTypesetupId;
  final String docName;
  final String expiry;
  final String reminderThreshold;
  final int employeeDocTypeMetaId;
  final String idOfDocument;
  final int companyId;
  final String expiryType;
  final int threshold;
  final bool sucess;
  final String message;

  EmployeeDocumentModal({
    required this.employeeDocTypeMetaId,
    required this.employeeDocTypesetupId,
    required this.companyId,
    required this.docName,
    required this.idOfDocument,
    required this.expiry,
    required this.reminderThreshold,
    required this.expiryType,
    required this.threshold,
    required this.sucess,
    required this.message,
  });
}

class EmployeeDocTabModal {
  final String employeeDocType;
  final int employeeDocMetaDataId;
  final bool success;
  final String message;

  EmployeeDocTabModal({
    required this.employeeDocType,
    required this.employeeDocMetaDataId,
    required this.success,
    required this.message,
  });
}

class EmployeeDocSetupModal {
  final int employeeDocTypeSetupId;
  final int employeeDocMetaDataId;
  final String documentName;
  final String reminderThreshould;
  final String expiry;
  final bool success;
  final String message;
  final String idOfDocument;
  final String expirtType;
  final int companyId;
  final int threshold;

  EmployeeDocSetupModal({
    required this.idOfDocument,
    required this.expirtType,
    required this.companyId,
    required this.threshold,
    required this.employeeDocTypeSetupId,
    required this.employeeDocMetaDataId,
    required this.documentName,
    required this.expiry,
    required this.reminderThreshould,
    required this.success,
    required this.message,
  });
}

class GetEmployeeSetupPrefillData {
  final int employeeDocTypesetupId;
  final String docName;
  final String expiry;
  final String reminderThreshold;
  final int employeeDocTypeMetaId;
  final String idOfDocument;
  final int companyId;
  final String expiryType;
  final int threshold;
  final bool sucess;
  final String message;

  GetEmployeeSetupPrefillData({
    required this.docName,
    required this.expiry,
    required this.reminderThreshold,
    required this.idOfDocument,
    required this.employeeDocTypesetupId,
    required this.employeeDocTypeMetaId,
    required this.companyId,
    required this.expiryType,
    required this.threshold,
    required this.sucess,
    required this.message,
  });
}
