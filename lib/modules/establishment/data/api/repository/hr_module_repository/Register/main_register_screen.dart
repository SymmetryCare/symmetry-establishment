class AllRegisterRepo{
  static String users = "/users";
  static String byCompanyId = "/ByCompanyId";
  static String offers = "/addOffers";

  ///users/ByCompanyId/{companyId}
  static String getRegisterDataCompId({required int companyId}){
    return "$users$byCompanyId/$companyId";
  }

  ///users/ByCompanyId/{companyId}/{status}
  static String getRegisterDataCompIdStatus({required int companyId,required String status}){
    return "$users$byCompanyId/$companyId/$status";
  }

  ///users/{userId}
  static String getRegisterPrefill({required int userId}){
    return "$users/$userId";
  }

}