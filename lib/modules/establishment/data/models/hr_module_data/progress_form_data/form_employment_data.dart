class EmploymentDataForm {
final int employmentId;
    final int employeeId;
    final  String employer;
    final  String city;
    final  String reason;
    final  String supervisor;
    final String supMobile;
    final  String title;
    final String dateOfJoining;
    final String endDate;
//bool? approved;
    final  String emgMobile;
    final  String country;
    final  String documentUrl;
    final  String documentName;



  EmploymentDataForm(
      {
        required this.employmentId,
        required this.employeeId,
        required this.employer,
        required this.city,
        required this.reason,
        required this.supervisor,
        required this.supMobile,
        required this.title,
        required this.dateOfJoining,
        required this.endDate,
       // this.approved,
        required this.country,
        required this.emgMobile,
        required this.documentUrl,
        required this.documentName,
      });
}
