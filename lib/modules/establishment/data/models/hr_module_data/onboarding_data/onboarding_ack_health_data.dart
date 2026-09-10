///get
class OnboardingAckHealthData {
  final String DocumentName;
  final String Expiry;
  final String ReminderThreshold;
  final String DocumentType;
  final int EmployeeDocumentTypeMetaDataId;
  final int EmployeeDocumentTypeSetupId;
  final String DocumentUrl;
  final int employeeDocumentId;
  final int employeeId;
  final String idOfTheDocument;
  final String documentFileName;
  bool? approved;

  OnboardingAckHealthData({required this.documentFileName,required this.idOfTheDocument,
    required this.DocumentName,
    required this.employeeDocumentId,
    required this.EmployeeDocumentTypeMetaDataId,
    required this.EmployeeDocumentTypeSetupId,
    required this.employeeId,
    required this.DocumentUrl,
    required this.ReminderThreshold,
    required this.Expiry, required this.DocumentType,
    this.approved
  });
}


/// Manage doc
class OnboardingAckHealthManageDocData {
  final String DocumentName;
  final String Expiry;
  final String ReminderThreshold;
  final String DocumentType;
  final int EmployeeDocumentTypeMetaDataId;
  final int EmployeeDocumentTypeSetupId;
  final String DocumentUrl;
  final int employeeDocumentId;
  final int employeeId;
  final String idOfTheDocument;
  final String documentFileName;
  bool? approved;

  OnboardingAckHealthManageDocData({required this.documentFileName,required this.idOfTheDocument,
    required this.DocumentName,
    required this.employeeDocumentId,
    required this.EmployeeDocumentTypeMetaDataId,
    required this.EmployeeDocumentTypeSetupId,
    required this.employeeId,
    required this.DocumentUrl,
    required this.ReminderThreshold,
    required this.Expiry, required this.DocumentType,
    this.approved
  });
}

