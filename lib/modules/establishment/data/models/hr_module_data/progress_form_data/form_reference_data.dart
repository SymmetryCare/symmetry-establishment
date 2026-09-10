class ReferenceDataForm {
  final int referenceId;
  final String association;
  final String comment;
  final String company;
  final String email;
  final int employeeId;
  final String mob;
  final String name;
  final String references;
  final String title;
  bool? approved;

  ReferenceDataForm(
      {required this.referenceId,
      required this.association,
      required this.comment,
      required this.company,
      required this.email,
      required this.employeeId,
      required this.mob,
      required this.name,
      required this.references,
      required this.title,
      this.approved});
}
