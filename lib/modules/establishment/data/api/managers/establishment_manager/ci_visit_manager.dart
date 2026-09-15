import 'package:flutter/cupertino.dart';

import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/establishment_manager/establishment_repository.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/company_identity/ci_visit_data.dart';

/// Company Identity → Visits.
///
/// Reconstructed from the call sites in
/// `.../company_identity/widgets/ci_tab_widget`; the original lived in the
/// `prohealth` monolith and did not come across with the extracted screens.
/// Endpoints come from [EstablishmentManagerRepository].

String _s(dynamic v) => v == null ? '' : '$v';
int _i(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

/// The API returns eligible clinicians as a list of objects; the visit screens
/// render each as a coloured chip.
List<EligibleClinician> _clinicians(dynamic raw) {
  if (raw is! List) return <EligibleClinician>[];
  return raw
      .map((c) => EligibleClinician(
            employeeTypeId: _i(c is Map ? c['EmployeeTypeId'] : null),
            eligibleClinician:
                _s(c is Map ? (c['EligibleClinician'] ?? c['EmployeeType']) : c),
            color: _s(c is Map ? c['Color'] : null),
          ))
      .toList();
}

/// GET /visits/{companyId}/{pageNo}/{rows}
Future<List<CiVisit>> getVisit(
    BuildContext context, int pageNo, int noofRows) async {
  List<CiVisit> itemsList = [];
  try {
    final int companyId = await TokenManager.getCompanyId();
    final response = await Api(context).get(
        path: EstablishmentManagerRepository.getCiVisit(
            companyId: companyId, pageNo: pageNo, noofRows: noofRows));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      final List items = data is List ? data : (data['data'] ?? []) as List;
      for (var item in items) {
        itemsList.add(CiVisit(
          visitId: _i(item['VisitId']),
          typeofVisit: _s(item['VisitType'] ?? item['TypeOfVisit']),
          serviceId: _s(item['ServiceId']),
          eligibleClinician: _clinicians(item['EligibleClinician']),
          success: true,
          message: response.statusMessage ?? '',
        ));
      }
    }
    return itemsList;
  } catch (e) {
    print("getVisit error $e");
    return itemsList;
  }
}

/// GET /visits/{visitId}
Future<VisitListDataPrefill> getVisitListPrefill(
    BuildContext context, int visitId) async {
  VisitListDataPrefill empty = VisitListDataPrefill(
    visitId: visitId,
    visitType: '',
    serviceId: '',
    eligibleClinicia: const <EligibleClinician>[],
    eligibleClinician: const <EligibleClinician>[],
    success: false,
    message: '',
  );
  try {
    final response = await Api(context)
        .get(path: EstablishmentManagerRepository.getCiVisitPrefill(visitId: visitId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final item =
          response.data is List ? (response.data as List).first : response.data;
      final List<EligibleClinician> clinician =
          _clinicians(item['EligibleClinician']);
      return VisitListDataPrefill(
        visitId: _i(item['VisitId']),
        visitType: _s(item['VisitType']),
        serviceId: _s(item['ServiceId']),
        eligibleClinicia: clinician,
        eligibleClinician: clinician,
        success: true,
        message: response.statusMessage ?? '',
      );
    }
    return empty;
  } catch (e) {
    print("getVisitListPrefill error $e");
    return empty;
  }
}

/// GET /visits/getVisitsByServiceId/{serviceId}
Future<List<VisitListDataByServiceId>> getVisitListByServiceId(
    {required BuildContext context, required String serviceId}) async {
  List<VisitListDataByServiceId> itemsList = [];
  try {
    final response = await Api(context).get(
        path: EstablishmentManagerRepository.getCiVisitListByServiceId(
            serviceId: serviceId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in (response.data as List)) {
        itemsList.add(VisitListDataByServiceId(
          visitId: _i(item['VisitId']),
          visitType: _s(item['VisitType']),
          serviceId: _s(item['ServiceId']),
          success: true,
          message: response.statusMessage ?? '',
        ));
      }
    }
    return itemsList;
  } catch (e) {
    print("getVisitListByServiceId error $e");
    return itemsList;
  }
}

/// POST /visits/add
Future<ApiData> addVisitPost({
  required BuildContext context,
  required String typeOfVisit,
  required List<dynamic> eligibleClinician,
  required String serviceId,
}) async {
  try {
    final int companyId = await TokenManager.getCompanyId();
    final response = await Api(context).post(
      path: EstablishmentManagerRepository.postCiVisit(),
      data: {
        "CompanyId": companyId,
        "VisitType": typeOfVisit,
        "EligibleClinician": eligibleClinician,
        "ServiceId": serviceId,
      },
    );
    return ApiData(
      success: response.statusCode == 200 || response.statusCode == 201,
      message: response.statusMessage ?? '',
      statusCode: response.statusCode ?? 0,
      data: response.data,
    );
  } catch (e) {
    print("addVisitPost error $e");
    return ApiData(success: false, message: '$e', statusCode: 0);
  }
}

/// PATCH /visits/{visitId}
Future<ApiData> updateVisitPatch({
  required BuildContext context,
  required int typeVisist,
  required String visitType,
  required List<dynamic> eligibleClinical,
  required String serviceId,
}) async {
  try {
    final response = await Api(context).patch(
      path: EstablishmentManagerRepository.updateCiVisit(typeVisit: typeVisist),
      data: {
        "VisitType": visitType,
        "EligibleClinician": eligibleClinical,
        "ServiceId": serviceId,
      },
    );
    return ApiData(
      success: response.statusCode == 200 || response.statusCode == 201,
      message: response.statusMessage ?? '',
      statusCode: response.statusCode ?? 0,
      data: response.data,
    );
  } catch (e) {
    print("updateVisitPatch error $e");
    return ApiData(success: false, message: '$e', statusCode: 0);
  }
}

/// DELETE /visits/{visitId}
Future<ApiData> deleteVisit(BuildContext context, int visitId) async {
  try {
    final response = await Api(context)
        .delete(path: EstablishmentManagerRepository.deleteCiVisit(visitId: visitId));
    return ApiData(
      success: response.statusCode == 200 || response.statusCode == 201,
      message: response.statusMessage ?? '',
      statusCode: response.statusCode ?? 0,
      data: response.data,
    );
  } catch (e) {
    print("deleteVisit error $e");
    return ApiData(success: false, message: '$e', statusCode: 0);
  }
}
