import 'package:flutter/cupertino.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/establishment_manager/establishment_repository.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/ci_manage_button/manage_insurance_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/company_identity/company_identity_data_.dart';

/* Establishment manager API */

/// Get Company
Future<List<CompanyModel>> companyAllApi(
    BuildContext context, int pageNo, int rowsNo) async {
  List<CompanyModel> itemsList = [];
  try {
    final response = await Api(context).get(
        path: EstablishmentManagerRepository.companyOfficeGet(
            pageNo: pageNo, rowsNo: rowsNo));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("ResponseList:::::${itemsList}");
      for (var item in response.data) {
        itemsList.add(
          CompanyModel(
              companyId: item['company_id'],
              // name: item['name'],
              address: item['address'],
              officeName: item['head_office_id']),
        );
      }
      print("ResponseList:::::${itemsList}");
    } else {
      print('Api Error');
      //return itemsList;
    }
    print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

/// Get company by id
Future<CompanyModel> companyByIdApi(BuildContext context) async {
  try {
    final companyId = await TokenManager.getCompanyId();
    var response = await Api(context).get(
        path: EstablishmentManagerRepository.companyById(companyId: companyId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Company by id ::: ${response}");
      return CompanyModel(companyId: response.data['company_id']);
    } else {
      return CompanyModel();
    }
  } catch (e) {
    print("Error $e");
    return CompanyModel();
  }
}

/// Get company details
Future<CompanyModel> companyDetailsApi(
  BuildContext context,
) async {
  try {
    final companyId = await TokenManager.getCompanyId();
    var response = await Api(context).get(
        path: EstablishmentManagerRepository.companyDetails(
            companyId: companyId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Company Details id ::: ${response}");
      return CompanyModel(companyId: response.data['company_id']);
    } else {
      return CompanyModel();
    }
  } catch (e) {
    print("Error $e");
    return CompanyModel();
  }
}

/// Get company logo
Future<List<CompanyLogoData>> companyLogoGetData(
    BuildContext context,
    ) async {
  List<CompanyLogoData> logoData = [];
  try {
    final companyId = await TokenManager.getCompanyId();
    var response = await Api(context).get(
        path: EstablishmentManagerRepository.getCompanyLogo(
            companyId: companyId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Company Details id ::: ${response}");
      for(var item in response.data){
        logoData.add(CompanyLogoData(
            logoType: item['web'] ?? '',
            logoUrl: item['url'] ?? ''));
      }

      return logoData;
    } else {
      return logoData;
    }
  } catch (e) {
    print("Error Logo$e");
    return logoData;
  }
}

/// Get upload company logo
Future<ApiData> uploadCompanyLogoApi(BuildContext context, String type) async {
  try {
    final companyId = await TokenManager.getCompanyId();
    var response = await Api(context).post(
        path: EstablishmentManagerRepository.uploadCompanyLogo(
            companyId: companyId, type: type),
        data: {
          'company_id': companyId,
          'type': type,
        });
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Saved request");
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!);
    } else {
      print("Error 1");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    print("Error 2");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

/// Post add new office

Future<ApiData> addNewOffice(
    {required BuildContext context,
    required String name,
    required String address,
    required String email,
    required String primaryPhone,
    required String secondaryPhone,
    required String officeId,
    required String lat,
    required String long,
    required String cityName,
    required String stateName,
    required String country,
    required bool isHeadOffice}) async {
  try {
    var data = {
      "company_id": 2,
      "office_id": officeId,
      "primary_phone": primaryPhone,
      "secondary_phone": secondaryPhone,
      "primary_fax": primaryPhone,
      "secondary_fax": secondaryPhone,
      "alternative_phone": secondaryPhone,
      "email": email,
      "name": name,
      "address": address,
      "lat": lat,
      "lng": long,
      "city": cityName,
      "state": stateName,
      "country": country,
      "isHeadOffice": isHeadOffice
    };
    print("All inserted office data ${data}");
    final companyId = await TokenManager.getCompanyId();
    var response = await Api(context)
        .post(path: EstablishmentManagerRepository.addNewOffice(), data: {
      "company_id": companyId,
      "office_id": officeId,
      "primary_phone": primaryPhone,
      "secondary_phone": secondaryPhone,
      "primary_fax": primaryPhone,
      "secondary_fax": secondaryPhone,
      "alternative_phone": secondaryPhone,
      "email": email,
      "name": name,
      "address": address,
      "lat": lat,
      "lng": long,
      "city": cityName,
      "state": stateName,
      "country": country,
      "isHeadOffice": isHeadOffice
    });
    print('::::$response');
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Saved request");
      var officeResponse = response.data;
      var officeID = officeResponse['office_id'];
      return ApiData(
          officeId: officeID,
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!);
    } else {
      print("Error 1");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    print("Error 2");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

///Get Company by office list by company
// Future<List<CompanyIdentityModel>> companyOfficeListGet(
//     BuildContext context, int pageNo, int rowsNo) async {
//   List<CompanyIdentityModel> itemsList = [];
//   try {
//     final companyId = await TokenManager.getCompanyId();
//     final response = await Api(context).get(
//         path: EstablishmentManagerRepository.companyOfficeListGet(
//             pageNo: pageNo, rowsNo: rowsNo, companyId: companyId));
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       print("ResponseList:::::${itemsList}");
//       for (var item in response.data["OfficeList"]) {
//         itemsList.add(CompanyIdentityModel(
//           pageNo: pageNo,
//           rowsNo: rowsNo,
//           sucess: true,
//           message: response.statusMessage!,
//           officeName: item['name'],
//           companyId: companyId,
//           address: item['address'],
//           officeId: item['office_id'],
//           companyOfficeId: item['company_Office_id'],
//           cityName: item['city']??"",
//           stateName: item['state']??"",
//           countryName: item['country']??"",
//           lat: item['lat']??"37.7749",
//           long: item['lng']??"-122.4194",
//           isHeadOffice:item['isHeadOffice']??false
//         ));
//       }
//       // print("ResponseList:::::${itemsList}");
//       itemsList.sort((a, b) => b.isHeadOffice ? 1 : (a.isHeadOffice ? -1 : 0));
//     } else {
//       print('Api Error');
//       //return itemsList;
//     }
//     // print("Response:::::${response}");
//     return itemsList;
//   } catch (e) {
//     print("Error $e");
//     return itemsList;
//   }
// }



Future<List<CompanyIdentityModel>> companyOfficeListGet(
    BuildContext context, int pageNo, int rowsNo) async {
  List<CompanyIdentityModel> itemsList = [];
  try {
    final companyId = await TokenManager.getCompanyId();
    final response = await Api(context).get(
        path: EstablishmentManagerRepository.companyOfficeListGet(
            pageNo: pageNo, rowsNo: rowsNo, companyId: companyId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("ResponseList:::::${itemsList}");
      for (var item in response.data["OfficeList"]) {
        itemsList.add(CompanyIdentityModel(
          pageNo: pageNo,
          rowsNo: rowsNo,
          sucess: true,
          message: response.statusMessage!,
          officeName: item['name'],
          companyId: companyId,
          address: item['address'],
          officeId: item['office_id'],
          companyOfficeId: item['company_Office_id'],
          cityName: item['city'] ?? "",
          stateName: item['state'] ?? "",
          countryName: item['country'] ?? "",
          lat: item['lat'] ?? "37.7749",
          long: item['lng'] ?? "-122.4194",
          isHeadOffice: item['isHeadOffice'] ?? false,
        ));
      }

      // Sort first by head office, then by companyOfficeId in descending order
      itemsList.sort((a, b) {
        if (a.isHeadOffice && !b.isHeadOffice) {
          return -1; // a (head office) comes before b
        } else if (!a.isHeadOffice && b.isHeadOffice) {
          return 1; // b (head office) comes before a
        } else {
          return b.companyOfficeId.compareTo(a.companyOfficeId); // Sort by companyOfficeId in descending order
        }
      });

    } else {
      print('Api Error');
      //return itemsList;
    }
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}


///Get company office list
Future<List<CompanyOfficeListData>> getCompanyOfficeList(
  BuildContext context,
) async {
  List<CompanyOfficeListData> itemsList = [];
  try {
    final companyId = await TokenManager.getCompanyId();
    final response = await Api(context).get(
        path: EstablishmentManagerRepository.getCompanyOfficeList(
            companyId: companyId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("ResponseList:::::${itemsList}");
      for (var item in response.data) {
        itemsList.add(CompanyOfficeListData(
          name: item['name'] ?? "--",
          companyId: companyId,
          address: item['address'] ?? "--",
          officeId: item['office_id'] ?? "--",
          primaryNbr: item['primary_phone'] ?? "--",
          secondaryNbr: item['secondary_phone'] ?? "--",
          slternativeNbr: item['alternative_phone'] ?? "--",
          email: item['email'] ?? "--",
          companyOfficeId: item['company_Office_id'] ?? 0,
          primaryFax: item['primary_fax'] ?? "--",
          secondaryFax: item['secondary_fax'] ?? "--",
          latitude: item['lat'],
          longitude: item['lng'],
        ));
      }
      // print("ResponseList:::::${itemsList}");
    } else {
      print('Api Error');
      //return itemsList;
    }
    // print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}


/// Post add new services in office_id

Future<ApiData> addNewOfficeServices(
    {required BuildContext context,
      required String officeId,
      required List<ServiceList> serviceList
      }) async {
  try {
    final companyId = await TokenManager.getCompanyId();
    var data = {
      "company_id": companyId,
      "office_id": officeId,
      "ServiceList": serviceList.map((item) => item.toJson()).toList(),
    };
    print("All inserted office services ${data}");
    var response = await Api(context)
        .post(path: EstablishmentManagerRepository.addNewOfficeServices(), data:
    {
      "company_id": companyId,
      "office_id": officeId,
      "ServiceList": serviceList.map((item) => item.toJson()).toList(),
    });
    print('::::$response');
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Services added in office");
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!);
    } else {
      print("Error 1");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    print("Error 2");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}
