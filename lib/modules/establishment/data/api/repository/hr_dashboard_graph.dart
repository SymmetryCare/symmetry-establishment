class HrGraphRepo{
  static String sexRatio = "/hr-dropdowns/sexRatio";


  /// HR dashboard graph sex ratio
  static String getSexRationPercentage({required int companyId}) {
    return "$sexRatio/$companyId";
  }
}