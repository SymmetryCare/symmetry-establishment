class UserAppBar {
  final int userId;
  final String firstName;
  final String lastName;
  final int departmentId;
  final String department;
  final String email;
  final int companyId;
  final String? password;
  final String? status;
  final int employeeId;
  final String imgUrl;
  UserAppBar({required this.userId, required this.firstName, required this.lastName, required this.departmentId, required this.department,
    required this.email, required this.companyId, this.password, this.status, required this.employeeId, required this.imgUrl,});
}
