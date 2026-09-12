class ProfileRepository {
  static String profilesearch = "/employees/searchByStringFilter";
  static String employees = "/employees";
  static String score = "GetProfileScore";
  static String zone = "/zone";
  static String countyWiseZone = "/zoneByCounty/";
  static String covergaelist = "/employee-enroll/coverageArea/byEmployee/";
  static String covergaePrefill = "/employee-enroll/coverageArea/byemployeeEnrollCoverage/";
  static String gender = "/gender-dropdown";
  static String enroll = "/employee-enroll";
  static String race = "/race";
  static String employeeSpeciality = "/employee-speciality";

  /// employee-speciality/add
  static String addEmployeeSpeciality() {
    return "$employeeSpeciality/add";
  }


  /// search employee profile
  static String searchEmployeeProfileByText({
    required int companyId, required String searchText}){
    return "$profilesearch/$companyId/$searchText";
  }

  static String searchEmployeeProfileById({required int companyId, required int Id}){
    return "$profilesearch/$companyId/$Id";
  }

  static String searchByEmployeeIdProfile({required int employeeId}){
    return "$employees/$employeeId";
  }
  static String getPercentage({required int employeeId}){
    return "$employees/$score/$employeeId";
  }
  static String getCountyWiseZone({
    required int countyId
   }){
    return "$zone$countyWiseZone$countyId";
  }

  ///employee-enroll/{employeeEnrollCoverageId}
  static String deleteCoverage({
    required int employeeEnrollCoverageId
  }){
    return "$enroll/$employeeEnrollCoverageId";
  }

  ////co
  static String getlistcoverage({required int employeeId}){
    return "$covergaelist/$employeeId";
  }
  static String getPreFillcoverage({required int employeeCoverageId}){
    return "$covergaePrefill/$employeeCoverageId";
  }
///gender
  static String getGender(){
    return "$gender";
  }

  static String getrace(){
    return "$race";
  }
}