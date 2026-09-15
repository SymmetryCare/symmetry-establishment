/// Models for Company Identity → Visits.
///
/// Reconstructed from the call sites in
/// `.../company_identity/widgets/ci_tab_widget/ci_visit.dart` and
/// `.../widget/visit_constants.dart`; the originals lived in the `prohealth`
/// monolith and did not come across with the extracted screens.

/// One clinician eligible to perform a visit type.
class EligibleClinician {
  final int employeeTypeId;

  /// Display label for the clinician type; the visit screens show it on a chip.
  final String eligibleClinician;

  /// Chip colour as a "#rrggbb" string — the screens strip the "#".
  final String color;

  EligibleClinician({
    required this.employeeTypeId,
    required this.eligibleClinician,
    required this.color,
  });
}

/// A row of `/visits/{companyId}/{pageNo}/{rows}`.
class CiVisit {
  final int visitId;
  final String typeofVisit;
  final String serviceId;
  final List<EligibleClinician>? eligibleClinician;

  final bool success;
  final String message;

  CiVisit({
    required this.visitId,
    required this.typeofVisit,
    required this.serviceId,
    required this.eligibleClinician,
    required this.success,
    required this.message,
  });
}

/// A row of `/visits/getVisitsByServiceId/{serviceId}`.
class VisitListDataByServiceId {
  final int visitId;
  final String visitType;
  final String serviceId;

  final bool success;
  final String message;

  VisitListDataByServiceId({
    required this.visitId,
    required this.visitType,
    required this.serviceId,
    required this.success,
    required this.message,
  });
}

/// `/visits/{visitId}` — the visit behind the edit popup.
class VisitListDataPrefill {
  final int visitId;
  final String visitType;
  final String serviceId;
  final List<EligibleClinician> eligibleClinicia;
  final List<EligibleClinician> eligibleClinician;

  final bool success;
  final String message;

  VisitListDataPrefill({
    required this.visitId,
    required this.visitType,
    required this.serviceId,
    required this.eligibleClinicia,
    required this.eligibleClinician,
    required this.success,
    required this.message,
  });
}
