class AllRegisterRepository{

  static String empEnroll = "/employee-enroll";
  static String patchempEnroll = "/employee-enroll/updateCoverage";
  static String add = "/add";
  static String offers = "/addOffers";
  static String addZipCode = "/addZipCodes";
  static String addCompensation = "/addCompensations";
  static String cities = "/addCities";
  static String addCoverage = "/addCoverage";
  static String filter = "/Filter";
  static String onboarbingUser = "/employees/onboard";
  static String changeStatus = "/employees/changeStatusFromPartialToComplete";


  ///employee-enroll/Filter/{companyId}/{filter}
  static String getEmpEnrollFilter({required int compId,required String filter}){
    return "$empEnroll$filter/$compId/$filter";
  }
  ///employee-enroll/
  static String getEmployeeEnroll(){
    return "$empEnroll";
  }
  static String getOfferLetterCheck(){
    return "$empEnroll/check-offer-letter";
  }
  ///employee-enroll/{employeeEnrollId}
  static String getEmpEnrollByEnrollId({required int empEnrollId}){
    return "$empEnroll/$empEnrollId";
  }
  ///employee-enroll/add
  static String addEmpEnrollAdd(){
    return "$empEnroll$add";
  }
  static String patchEmpEnrollUpdate({required int empEnrollId}){
    return "$empEnroll/$empEnrollId";
  }
  ///employee-enroll/addOffers
  static String addEmpEnrollOffers(){
    return "$empEnroll$offers";
  }
  ///employee-enroll/addZipCodes
  static String addEmpEnrollZipCodes(){
    return "$empEnroll$addZipCode";
  }
  ///employee-enroll/addCompensations
  static String addEmpEnrollCompensation(){
    return "$empEnroll$addCompensation";
  }
  ///employee-enroll/addCities
  static String addEmpEnrollCities(){
    return "$empEnroll$cities";
  }
  ///employee-enroll/addCoverage
  static String addEmpEnrolladdCoverage(){
    return "$empEnroll$addCoverage";
  }
  ///employee-enroll/addCoverage
  static String PatchEmpEnrolladdCoverage({required int empEnrollId}){
    return "$patchempEnroll/$empEnrollId";
  }
  /// employee_onboarding patch
  static String patchOnboardingEmployee({required int employeeId}){
    return "$onboarbingUser/$employeeId";
  }

  static String patchChangeStatusEmployee({required int employeeId}){
    return "$changeStatus/$employeeId";
  }



  static String patchUserStatus({required int userId}) {
    return "/users/$userId/status";
  }
  static String deleteUser({required int userId}) {
    return "/users/$userId";
  }
}