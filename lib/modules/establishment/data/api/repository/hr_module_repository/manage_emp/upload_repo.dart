class UploadDocumentRepository{
  static const String uploadEmployeeDocument = "/employee-documents/uploadDocumentbase64";
  static const String patchUploadEmployeeDocument = "/employee-documents/withBase64";

  static const String patchEmployeeDocument =  "/employee-documents";

  static String uploadEmployeeDocumentGet({required int employeeDocumentTypeMetaDataId,required int employeeDocumentTypeSetupId, required int employeeId}){
    return "$uploadEmployeeDocument/$employeeDocumentTypeMetaDataId/$employeeDocumentTypeSetupId/$employeeId";
  }
  static String PatchEmployeeDocumentGet({required int employeeDocumentId, }){
    return "$patchEmployeeDocument/$employeeDocumentId";
  }
  static String PatchUploadEmployeeDocumentGet({required int employeeDocumentId, required int employeeDocumentTypeMetaDataId,required int employeeDocumentTypeSetupId, required int employeeId}){
    return "$patchUploadEmployeeDocument$employeeDocumentId/$employeeDocumentTypeMetaDataId/$employeeDocumentTypeSetupId/$employeeId";
  }


  static String patchDocumentWithBase64({
    required int employeeDocumentId,
    required int employeeDocumentTypeMetaDataId,
    required int employeeDocumentTypeSetupId,
    required int employeeId,
  }) {
    return '/employee-documents/withBase64/$employeeDocumentId/$employeeDocumentTypeMetaDataId/$employeeDocumentTypeSetupId/$employeeId';
  }

}





