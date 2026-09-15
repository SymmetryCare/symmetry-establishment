class HrDashboardRepository {
  static String newJoinee = "/hr-dropdowns/total/employees/newJoinee";


  /// /hr-dropdowns/total/employees/newJoinee/{companyId}
  static String getNewJoinee({required int companyId}) {
    return "$newJoinee/$companyId";
  }
}