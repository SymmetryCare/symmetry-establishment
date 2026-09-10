class OnlinkGeneralRepo{
  static String employee ="/employees";

  ///employees/{employeeId}
  static String getGeneralByIdPrefill({required int employeeId}){
    return "$employee/$employeeId";
  }
  ///employees/{employeeId}
  static String patchGeneralById({required int employeeId}){
    return "$employee/$employeeId";
  }
}