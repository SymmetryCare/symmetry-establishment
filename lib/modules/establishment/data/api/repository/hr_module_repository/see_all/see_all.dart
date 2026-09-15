class SeeAllRepository{
  static String emp = "/employees";
  static String all = "/all";
  static String byStatus = "/ByStatus";

  ///employees/all/{companyId}
  static String getEmpSeeAll({required int compId}){
    return "$emp$all/$compId";
  }
  ///employees/ByStatus/{status}
  static String getEmpByStatus({required String status}){
    return "$emp$byStatus/$status";
  }
}