import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/establishment_manager/establishment_repository.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/ci_manage_button/manage_insurance_data.dart';

/// Company Identity → Insurance: vendors and their contracts.
///
/// Reconstructed from the call sites when the screens were extracted, with
/// guessed PascalCase keys ("CompanyId", "VendorName"). The backend's
/// /insurance-vendor and /insurance-vendor-contract take and return the
/// columns as they are named in the database (vendorName, officeId,
/// expiry_type, ...), so Add Vendor failed with a 500 and the lists came back
/// empty. The keys below are those columns, as in the original EMR manager.

String _s(dynamic v) => v == null ? '' : '$v';
int _i(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

ApiData _result(dynamic response) {
  final ok = response.statusCode == 200 || response.statusCode == 201;
  final body = response.data;
  final serverMessage = body is Map ? body['message'] : null;
  return ApiData(
    success: ok,
    message: ok
        ? (response.statusMessage ?? '')
        : serverMessage is List
            ? serverMessage.join('\n')
            : '${serverMessage ?? response.statusMessage ?? 'Request failed'}',
    statusCode: response.statusCode ?? 0,
    data: body,
  );
}

/// A failed call as the dialog should show it: the server's own message
/// (e.g. "vendorName must be a string"), not Dio's paragraph about status
/// codes.
ApiData _failure(Object e) {
  if (e is DioException && e.response != null) return _result(e.response);
  return ApiData(
      success: false,
      message: 'Could not reach the server. Please try again.',
      statusCode: 0);
}

// ── vendors ────────────────────────────────────────────────────────────────

/// POST /insurance-vendor/add
Future<ApiData> addVendors(
    BuildContext context, String officeId, String vendorName) async {
  try {
    final int companyId = await TokenManager.getCompanyId();
    final response = await Api(context).post(
      path: EstablishmentManagerRepository.companyOfficeVendorPost(),
      data: {
        "companyId": companyId,
        "officeId": officeId,
        "vendorName": vendorName,
      },
    );
    return _result(response);
  } catch (e) {
    print("addVendors error $e");
    return _failure(e);
  }
}

/// GET /insurance-vendor/{companyId}/{officeId}/{pageNo}/{rows}
Future<List<ManageVendorData>> companyVendorGet(BuildContext context,
    String officeId, int pageNo, int rowNo) async {
  List<ManageVendorData> itemsList = [];
  try {
    final int companyId = await TokenManager.getCompanyId();
    final response = await Api(context).get(
        path: EstablishmentManagerRepository.companyOfficeVendorGet(
            companyId: companyId,
            officeId: officeId,
            pageNo: pageNo,
            rowNo: rowNo));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      final List items = data is List ? data : (data['data'] ?? []) as List;
      for (var item in items) {
        itemsList.add(ManageVendorData(
          companyId: _i(item['companyId'] ?? companyId),
          insuranceVendorId: _i(item['insuranceVendorId']),
          officeId: _s(item['officeId']),
          vendorName: _s(item['vendorName']),
          address: _s(item['vendorAddress']),
          phone: _s(item['vendorPhone']),
          sucess: true,
          message: response.statusMessage ?? '',
        ));
      }
    }
    return itemsList;
  } catch (e) {
    print("companyVendorGet error $e");
    return itemsList;
  }
}

/// GET /insurance-vendor/{insuranceVendorId}
Future<ManageVendorPrefill> getPrefillVendor(
    BuildContext context, int insuranceVendorId) async {
  try {
    final response = await Api(context).get(
        path: EstablishmentManagerRepository.companyVendorPatchDelete(
            insuranceVendorId: insuranceVendorId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final item =
          response.data is List ? (response.data as List).first : response.data;
      return ManageVendorPrefill(
        vendorId: _i(item['insuranceVendorId']),
        officeId: _s(item['officeId']),
        vendorName: _s(item['vendorName']),
        address: _s(item['vendorAddress']),
        city: _s(item['city']),
        email: _s(item['email']),
        phone: _s(item['vendorPhone']),
        workEmail: _s(item['work_email']),
        workPhone: _s(item['work_phone']),
        zone: _s(item['zone']),
      );
    }
    return ManageVendorPrefill(vendorId: insuranceVendorId);
  } catch (e) {
    print("getPrefillVendor error $e");
    return ManageVendorPrefill(vendorId: insuranceVendorId);
  }
}

/// PATCH /insurance-vendor/{insuranceVendorId}
Future<ApiData> patchCompanyVendor(BuildContext context,
    int insuranceVendorId, String officeId, String vendorName) async {
  try {
    final int companyId = await TokenManager.getCompanyId();
    final response = await Api(context).patch(
      path: EstablishmentManagerRepository.companyVendorPatchDelete(
          insuranceVendorId: insuranceVendorId),
      data: {
        "companyId": companyId,
        "officeId": officeId,
        "vendorName": vendorName,
      },
    );
    return _result(response);
  } catch (e) {
    print("patchCompanyVendor error $e");
    return _failure(e);
  }
}

/// DELETE /insurance-vendor/{insuranceVendorId}
Future<ApiData> deleteVendor(
    BuildContext context, int insuranceVendorId) async {
  try {
    final response = await Api(context).delete(
        path: EstablishmentManagerRepository.companyVendorPatchDelete(
            insuranceVendorId: insuranceVendorId));
    return _result(response);
  } catch (e) {
    print("deleteVendor error $e");
    return _failure(e);
  }
}

// ── contracts ──────────────────────────────────────────────────────────────

/// POST /insurance-vendor-contract/add
Future<ApiData> addVendorContract(
  BuildContext context,
  int insuranceVendorId,
  String contractName,
  String expiryType,
  int threshold,
  String officeId,
  String contractId,
  String expiryDate,
) async {
  try {
    final int companyId = await TokenManager.getCompanyId();
    final response = await Api(context).post(
      path: EstablishmentManagerRepository.companyOfficeContractPost(),
      data: {
        "companyId": companyId,
        "officeId": officeId,
        "insuranceVendorId": insuranceVendorId,
        "contractName": contractName,
        "contractId": contractId,
        "expiry_type": expiryType,
        "expiry_date": expiryDate,
        "threshold": threshold,
      },
    );
    return _result(response);
  } catch (e) {
    print("addVendorContract error $e");
    return _failure(e);
  }
}

/// GET /insurance-vendor-contract/{companyId}/{officeId}/{vendorId}/{page}/{rows}
Future<List<ManageInsuranceContractData>> companyContractGetByVendorId(
  BuildContext context,
  String officeId,
  int insuranceVendorId,
  int pageNo,
  int rowNo,
) async {
  List<ManageInsuranceContractData> itemsList = [];
  try {
    final int companyId = await TokenManager.getCompanyId();
    final response = await Api(context).get(
        path: EstablishmentManagerRepository.companyOfficeContractGet(
            companyId: companyId,
            officeId: officeId,
            insuranceVendorId: insuranceVendorId,
            pageNo: pageNo,
            rowNo: rowNo));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      final List items = data is List ? data : (data['data'] ?? []) as List;
      for (var item in items) {
        itemsList.add(ManageInsuranceContractData(
          insuranceVendorContracId: _i(item['insuranceVendorContracId']),
          insuranceVendorId: _i(item['insuranceVendorId']),
          contractName: _s(item['contractName']),
          contractId: _s(item['contractId']),
          expiryType: _s(item['expiry_type']),
          companyId: _i(item['companyId'] ?? companyId),
          officeId: _s(item['officeId']),
          expiryDate: _s(item['expiry_date']),
          expiryReminder: _s(item['expiry_reminder']),
          threshold: _i(item['threshold']),
          sucess: true,
          message: response.statusMessage ?? '',
        ));
      }
    }
    return itemsList;
  } catch (e) {
    print("companyContractGet error $e");
    return itemsList;
  }
}

/// GET /insurance-vendor-contract/{insuranceVendorContracId}
Future<ManageContractPrefill> getPrefillContract(
    BuildContext context, int insuranceVendorContracId) async {
  ManageContractPrefill empty = ManageContractPrefill(
    insuranceVendorContracId: insuranceVendorContracId,
    insuranceVendorId: 0,
    companyId: 0,
    officeId: '',
  );
  try {
    final response = await Api(context).get(
        path: EstablishmentManagerRepository
            .companyOfficeContractPatchDeleteprefill(
                insuranceVendorContracId: insuranceVendorContracId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final item =
          response.data is List ? (response.data as List).first : response.data;
      return ManageContractPrefill(
        insuranceVendorContracId: _i(item['insuranceVendorContracId']),
        insuranceVendorId: _i(item['insuranceVendorId']),
        companyId: _i(item['companyId']),
        officeId: _s(item['officeId']),
        contractName: _s(item['contractName']),
        contractId: _s(item['contractId']),
        expiryType: _s(item['expiry_type']),
        expiryDate: _s(item['expiry_date']),
        expiryReminder: _s(item['expiry_reminder']),
        threshold: _i(item['threshold']),
      );
    }
    return empty;
  } catch (e) {
    print("getPrefillContract error $e");
    return empty;
  }
}

/// PATCH /insurance-vendor-contract/{insuranceVendorContracId}
Future<ApiData> patchCompanyContract(
  BuildContext context,
  int insuranceVendorContracId,
  int insuranceVendorId,
  int threshold,
  String officeId,
  String contractName,
  String expiryType,
  String contractId,
  String expiryDate,
) async {
  try {
    final int companyId = await TokenManager.getCompanyId();
    final response = await Api(context).patch(
      path: EstablishmentManagerRepository.companyOfficeVendorPatchDelete(
          insuranceVendorContracId: insuranceVendorContracId),
      data: {
        "companyId": companyId,
        "insuranceVendorId": insuranceVendorId,
        "officeId": officeId,
        "contractName": contractName,
        "contractId": contractId,
        "expiry_type": expiryType,
        "expiry_date": expiryDate,
        "threshold": threshold,
      },
    );
    return _result(response);
  } catch (e) {
    print("patchCompanyContract error $e");
    return _failure(e);
  }
}

/// DELETE /insurance-vendor-contract/{insuranceVendorContracId}
Future<ApiData> deleteContract(
    BuildContext context, int insuranceVendorContracId) async {
  try {
    final response = await Api(context).delete(
        path: EstablishmentManagerRepository.companyOfficeVendorPatchDelete(
            insuranceVendorContracId: insuranceVendorContracId));
    return _result(response);
  } catch (e) {
    print("deleteContract error $e");
    return _failure(e);
  }
}
