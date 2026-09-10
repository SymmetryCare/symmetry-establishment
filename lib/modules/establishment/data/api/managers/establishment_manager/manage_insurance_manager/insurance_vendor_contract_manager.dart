import 'package:flutter/cupertino.dart';

import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/establishment_manager/establishment_repository.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/ci_manage_button/manage_insurance_data.dart';

/// Company Identity → Insurance: vendors and their contracts.
///
/// Reconstructed from the call sites in
/// `.../company_identity/widgets/ci_insurance`; the original lived in the
/// `prohealth` monolith and did not come across with the extracted screens.
/// The models ([ManageVendorData] and friends) did come across with HR, so only
/// the calls are rebuilt here, against the endpoints in
/// [EstablishmentManagerRepository].

String _s(dynamic v) => v == null ? '' : '$v';
int _i(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

ApiData _result(dynamic response) => ApiData(
      success: response.statusCode == 200 || response.statusCode == 201,
      message: response.statusMessage ?? '',
      statusCode: response.statusCode ?? 0,
      data: response.data,
    );

// ── vendors ────────────────────────────────────────────────────────────────

/// POST /insurance-vendor/add
Future<ApiData> addVendors(
    BuildContext context, String officeId, String vendorName) async {
  try {
    final int companyId = await TokenManager.getCompanyId();
    final response = await Api(context).post(
      path: EstablishmentManagerRepository.companyOfficeVendorPost(),
      data: {
        "CompanyId": companyId,
        "OfficeId": officeId,
        "VendorName": vendorName,
      },
    );
    return _result(response);
  } catch (e) {
    print("addVendors error $e");
    return ApiData(success: false, message: '$e', statusCode: 0);
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
          companyId: _i(item['CompanyId']),
          insuranceVendorId: _i(item['InsuranceVendorId']),
          officeId: _s(item['OfficeId']),
          vendorName: _s(item['VendorName']),
          address: _s(item['Address']),
          phone: _s(item['Phone']),
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
        vendorId: _i(item['InsuranceVendorId']),
        officeId: _s(item['OfficeId']),
        vendorName: _s(item['VendorName']),
        address: _s(item['Address']),
        city: _s(item['City']),
        email: _s(item['Email']),
        phone: _s(item['Phone']),
        workEmail: _s(item['WorkEmail']),
        workPhone: _s(item['WorkPhone']),
        zone: _s(item['Zone']),
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
    final response = await Api(context).patch(
      path: EstablishmentManagerRepository.companyVendorPatchDelete(
          insuranceVendorId: insuranceVendorId),
      data: {"OfficeId": officeId, "VendorName": vendorName},
    );
    return _result(response);
  } catch (e) {
    print("patchCompanyVendor error $e");
    return ApiData(success: false, message: '$e', statusCode: 0);
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
    return ApiData(success: false, message: '$e', statusCode: 0);
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
        "CompanyId": companyId,
        "OfficeId": officeId,
        "InsuranceVendorId": insuranceVendorId,
        "ContractName": contractName,
        "ContractId": contractId,
        "ExpiryType": expiryType,
        "ExpiryDate": expiryDate,
        "Threshold": threshold,
      },
    );
    return _result(response);
  } catch (e) {
    print("addVendorContract error $e");
    return ApiData(success: false, message: '$e', statusCode: 0);
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
          insuranceVendorContracId: _i(item['InsuranceVendorContracId']),
          insuranceVendorId: _i(item['InsuranceVendorId']),
          contractName: _s(item['ContractName']),
          contractId: _s(item['ContractId']),
          expiryType: _s(item['ExpiryType']),
          companyId: _i(item['CompanyId']),
          officeId: _s(item['OfficeId']),
          expiryDate: _s(item['ExpiryDate']),
          expiryReminder: _s(item['ExpiryReminder']),
          threshold: _i(item['Threshold']),
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
        insuranceVendorContracId: _i(item['InsuranceVendorContracId']),
        insuranceVendorId: _i(item['InsuranceVendorId']),
        companyId: _i(item['CompanyId']),
        officeId: _s(item['OfficeId']),
        contractName: _s(item['ContractName']),
        contractId: _s(item['ContractId']),
        expiryType: _s(item['ExpiryType']),
        expiryDate: _s(item['ExpiryDate']),
        expiryReminder: _s(item['ExpiryReminder']),
        threshold: _i(item['Threshold']),
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
    final response = await Api(context).patch(
      path: EstablishmentManagerRepository.companyOfficeVendorPatchDelete(
          insuranceVendorContracId: insuranceVendorContracId),
      data: {
        "InsuranceVendorId": insuranceVendorId,
        "OfficeId": officeId,
        "ContractName": contractName,
        "ContractId": contractId,
        "ExpiryType": expiryType,
        "ExpiryDate": expiryDate,
        "Threshold": threshold,
      },
    );
    return _result(response);
  } catch (e) {
    print("patchCompanyContract error $e");
    return ApiData(success: false, message: '$e', statusCode: 0);
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
    return ApiData(success: false, message: '$e', statusCode: 0);
  }
}
