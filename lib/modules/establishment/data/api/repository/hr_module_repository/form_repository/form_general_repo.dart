class ProgressBarRepository{

  static String grneralpage ="/employees/add";
  static String uploadEmployeePhoto = "/employees/attach-photobase64";

  static String educationDocument = "/employee-educations/attach-documentbase64";

 static String employmentpage ="/employee-employment-histories/add";

 static String educationpage ="/employee-educations/add";

 static String  referencepage  ="/reference/add";

 static String empI9 = "/employee-i9/add";
 static String licensespage   = "/employee-licenses/add";

 static String   bankingpage  = "/employee-bankings/add";


  static String employeedocSetup = "/employee-document-type-setup";

static String verifyuserpopup = "/auth/Otp";

static String addLegalDocument = "/employee-legal-document/add";
static String uploadLegalDocument = "/employee-legal-document/attach-docbase64";
static String getprifilluploadDocument = "/employee-legal-document/ByemployeeId";
///patch api
  ///
  static String educationscreen  ="/employee-educations";


  ///  degree api
  static String educationdegree ="/employee-degree";



  ///get api

 static  String educationformprifill ="/employee-educations";
 static  String employmentformprifill ="/employee-employment-histories";
 static  String referenceformprifill ="/reference";
 static  String bankingformprifill ="/employee-bankings";
 static  String licensesformprifill ="/employee-licenses";


   static String getEmployeeByEmpID({required int employeeID} ){
    return "$educationformprifill/ByemployeeId/$employeeID/no";
  }
  static String uploadEmployeePhotoBase64({required int employeeID} ){
    return "$uploadEmployeePhoto/$employeeID";
  }

  static String getEmploymentByEmpID({required int employeeID} ){
    return "$employmentformprifill/ByemployeeId/$employeeID/no";
  }

  static String getReferenceByEmpID({required int employeeID} ){
    return "$referenceformprifill/ByemployeeId/$employeeID/no";
  }

  static String getBankingByEmpID({required int employeeID} ){
    return "$bankingformprifill/ByemployeeId/$employeeID/no";


  }
  static String getLicensesByEmpID({required int employeeID} ){
    return "$licensesformprifill/ByemployeeId/$employeeID/no";
  }

  ///
///////
  static String postgeneralscreen(){
    return "$grneralpage";
  }
  ////
static String postemploymentscreen(){
   return "$employmentpage";
}
//////
static String posteducationscreen(){
    return "$educationpage";
}
///////
static String postreferencescreen(){
    return "$referencepage";
}
///////
static String postlicensesscreen(){
    return "$licensespage";
}
 static String postbankingscreen(){
    return "$bankingpage";
 }
  static String uploadEducationDocument({required int educationId, required String documentName}){
    return "$educationDocument/$educationId/$documentName";
  }
  static String uploadLegalDocumentBase64({required int legalDocumentId}){
    return "$uploadLegalDocument/$legalDocumentId";
  }
  static String addLegalDocumentForm(){
    return "$addLegalDocument";
  }


  static String priLegalDocumentForm({required int employeeID}){
    return "$getprifilluploadDocument/$employeeID";
  }



 ////
  ///employee doc list
  static String getEmployeeDocSetUpMetaIdHR({
    /// required int metaDocId
    required int pageNo, required int rowsNo,
    required int employeeDocTypeMetaDataId
  }){
    /// return "$employeedocSetup/$metaDocId";
    return "$employeedocSetup/$employeeDocTypeMetaDataId/$pageNo/$rowsNo";
  }


 ///////
static String postverifyuser(){
    return "$verifyuserpopup";
}



///patch api

  static String patchEmployeeDucationForm({required int educationId}){
    return "$educationscreen/$educationId";
  }


 ///degree dropdown

  static String getEmployeeDegreeDropDown(){
    return "$educationdegree";
  }


  ///prifillapi education

  static String educationformget({required int educationId }){
    return "$educationformprifill/$educationId";
  }
  static String addEmployeeI9Form(){
    return "$empI9";
  }
}

