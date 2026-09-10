import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/establishment_manager/all_from_hr_repository.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/establishment_manager/establishment_repository.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/zone/zone_model_data.dart';

import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/pay_rates/pay_rates_finance_data.dart';

///zone GET

Future<List<AllZoneData>> getZoneByCountyId({
  required BuildContext context,
  required int countyId
}
) async {
  List<AllZoneData> itemsList = [];
  try {
    final response = await Api(context).get(path: AllZoneRepository.getZoneByCountyId(countyId: countyId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      // print("Org Document response:::::${itemsList}");
      print("1");
      for (var item in response.data) {
        itemsList.add(AllZoneData(
            zoneId: item['zone_id']??0,
            zoneName: item['zoneName']??'',
            sucess: true,
            message: response.statusMessage!,
            companyId: item['companyId']??0,
            officeId: item['officeId']??'',
            countyId: item['county_id']??0));
      }
      // print("Org Document response:::::${itemsList}");
    } else {
      print('Zone Api Error');
      return itemsList;
    }
    // print("Org response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

Future<List<AllZoneCompanyWiseData>> getZoneByCompanyidWise({
  required BuildContext context,
}
    ) async {
  List<AllZoneCompanyWiseData> itemsList = [];
  try {
    final companyId = await TokenManager.getCompanyId();
    final response = await Api(context).get(path: AllZoneRepository.getZoneByCompanyIdWise(companyId: companyId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      // print("Org Document response:::::${itemsList}");
      print("1");
      for (var item in response.data) {
        itemsList.add(AllZoneCompanyWiseData(
            zoneId: item['zone_id']??0,
            zoneName: item['zoneName']??'',
            sucess: true,
            message: response.statusMessage!,
            companyId: item['companyId']??0,
            officeId: item['officeId']??'',
            countyId: item['county_id']??0));
      }
      // print("Org Document response:::::${itemsList}");
    } else {
      print('Zone Api Error');
      return itemsList;
    }
    // print("Org response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

///county get
Future<List<AllCountyGet>> getZoneBYcompOffice(
    BuildContext context, String officeId, pageNo, noOfRow) async {
  List<AllCountyGet> itemsList = [];
  try {
    final companyId = await TokenManager.getCompanyId();
    final response = await Api(context).get(
        path: AllZoneRepository.countyGet(
            companyId: companyId,
            officeId: officeId,
            pageNo: pageNo,
            noOfRow: noOfRow));
    if (response.statusCode == 200 || response.statusCode == 201) {
      // print("Org Document response:::::${itemsList}");
      print("1");
      for (var item in response.data) {
        itemsList.add(AllCountyGet(
            countyName: item['countyName'],
            state: item['state'],
            country: item['Country'],
            zipcodes: item['zipcodes']??"",
            sucess: true,
            message: response.statusMessage,
            zoneName: (item['zones'] is List)
                ? List<String>.from(item['zones'])
                : [],
            // zoinId: item['zoneId']??0,
            countyId: item['county_id']));
      }
      print("County response:::::${itemsList}");
    } else {
      print('County Api Error');
      return itemsList;
    }
    // print("Org response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

/// Office id wise
Future<List<AllCountyByOfficeId>> getCountyByCompanyId(
    BuildContext context,String officeId) async {
  List<AllCountyByOfficeId> itemsList = [];
  try {
    final companyId = await TokenManager.getCompanyId();
    final response = await Api(context).get(
        path: AllZoneRepository.countyCompanyGet(
            officeId: officeId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      // print("Org Document response:::::${itemsList}");
      print("1");
      for (var item in response.data) {
        itemsList.add(AllCountyByOfficeId(
            countyName: item['countyName']??"",
            state: item['state']??'',
            country: item['Country']??'',
            // zoinId: item['zoneId']??0,
            countyId: item['county_id']??0,
            lat: item['latitude']??'',
            long: item['longitude']??'',
            companyId: item['companyId']??0,
            officeId: item['officeId']??''));
      }
      print("County response:::::${itemsList}");
    } else {
      print('County Api Error');
      return itemsList;
    }
    // print("Org response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}
///county get
Future<List<AllCountyZoneGet>> getZoneByCounty(BuildContext context,
    String officeId, int countyId, int pageNo, int noOfRow) async {
  List<AllCountyZoneGet> itemsList = [];
  try {
    final companyId = await TokenManager.getCompanyId();
    final response = await Api(context).get(
        path: AllZoneRepository.countyZoneGet(
            companyId: companyId,
            officeId: officeId,
            pageNo: pageNo,
            noOfRow: noOfRow,
            countyId: countyId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      // print("Org Document response:::::${itemsList}");
      print("1");
      for (var item in response.data) {
        itemsList.add(AllCountyZoneGet(
            countyName: item['county'] ?? "--",
            zipcodes: item['zipcodes'] ?? "--",
            sucess: true,
            message: response.statusMessage!,
            countyId: item['county_id'] ?? 0,
            zoneId: item['zone_id'] ?? 0,
            zoneName: item['zoneName'] ?? "--",
            cities: item['cities'] ?? "--"));
      }
      print("County response:::::${itemsList}");
    } else {
      print('County Api Error');
      return itemsList;
    }
    // print("Org response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

/// zone county prefill patch
Future<CountyZonePrefillGet> getZoneByCountyPrefill(
    BuildContext context, int zoinId) async {
  var itemsList;
  try {
    final response = await Api(context)
        .get(path: AllZoneRepository.countyZoneDelete(zoinId: zoinId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      // print("Org Document response:::::${itemsList}");
      print("1");

      itemsList = CountyZonePrefillGet(
          countyId: response.data['countyId'] ?? 0,
          zoneId: response.data['zoneId'] ?? 0,
          zoneName: response.data['zoneName'] ?? "--",
          countyName: response.data['countyName']??"--"

        // companyId: response.data['companyId'],
        // officeId: response.data['officeId']
      );
    } else {
      print('County Api Error');
      return itemsList;
    }
    // print("Org response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

/// County get List
Future<List<AllCountyGetList>> getCountyZoneList(BuildContext context) async {
  List<AllCountyGetList> itemsList = [];
  try {
    final response =
    await Api(context).get(path: AllZoneRepository.countyListGet());
    if (response.statusCode == 200 || response.statusCode == 201) {
      // print("Org Document response:::::${itemsList}");
      print("1");
      for (var item in response.data) {
        itemsList.add(AllCountyGetList(
            countyName: item['countyName'],
            state: item['state'],
            country: item['Country'],
            sucess: true,
            message: response.statusMessage!,
            officeID: item['officeId'],
            countyId: item['county_id'],
            companyId: item['companyId'],
            latitude: item['latitude'].replaceAll("°", ""),
            longitude: item['longitude'].replaceAll("°", "")));
      }
      print("County response:::::${itemsList}");
    } else {
      print('County Api Error');
      return itemsList;
    }
    // print("Org response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

/// County get office id wise
Future<List<OfficeWiseCountyData>> getCountyListOfficeIdWise({required BuildContext context, required String OfficeId}) async {
  List<OfficeWiseCountyData> itemsList = [];
  try {
    final response =
    await Api(context).get(path: AllZoneRepository.countyListGetOfficeIdWise(OfficeId: OfficeId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      // print("Org Document response:::::${itemsList}");
      print("1");
      for (var item in response.data) {
        itemsList.add(OfficeWiseCountyData(
            countyName: item['countyName'],
            state: item['state'],
            country: item['Country'],
            sucess: true,
            message: response.statusMessage!,
            officeId: item['officeId'],
            countyId: item['county_id'],
            companyId: item['companyId'],
            latitude: item['latitude'],
            longitude: item['longitude']));
      }
      print("County response:::::${itemsList}");
    } else {
      print('County Api Error');
      return itemsList;
    }
    // print("Org response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

/// Zone county add
Future<ApiData> addZoneCountyData(
    BuildContext context,
    String zoneName,
    int countyId,
    String officeId,
    ) async {
  try {
    final companyId = await TokenManager.getCompanyId();
    var response =
    await Api(context).post(path: AllZoneRepository.addCountyZone(), data: {
      "zoneName": zoneName,
      "county_id": countyId,
      "officeId": officeId,
      "companyId": companyId
    });
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Zone-County record added");
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
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

/// Zone county update
Future<ApiData> updateZoneCountyData(BuildContext context, int zoinId,
    String zoneName, int countyId, String officeId, int companyId) async {
  try {
    var response = await Api(context)
        .patch(path: AllZoneRepository.updateCountyZone(zoinId: zoinId), data: {
      "zoneName": zoneName,
      "county_id": countyId,
      "officeId": officeId,
      "companyId": companyId
    });
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Zone-County record updated");
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
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

/// Zone County Delete
Future<ApiData> deleteZoneCountyData(BuildContext context, int zoneId) async {
  try {
    var response = await Api(context)
        .delete(path: AllZoneRepository.countyZoneDelete(zoinId: zoneId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Zone-County record added");
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
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

/// Zone County add
Future<ApiData> addZoneCounty(
    BuildContext context, int zoneId, int countyId) async {
  try {
    var response = await Api(context).post(
        path: AllZoneRepository.zoneCountyPost(),
        data: {"zone_id": zoneId, "county_id": countyId});
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Zone-County record added");
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
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

/// County add
Future<ApiData> addCounty(
    BuildContext context,
    String countyName,
    String stateName,
    String countryName,
    String lat,
    String long,
    String officeId) async {
  try {
    final companyId = await TokenManager.getCompanyId();
    var response =
    await Api(context).post(path: AllZoneRepository.addCounty(), data: {
      "countyName": countyName,
      "state": stateName,
      "Country": countryName,
      "latitude": lat,
      "longitude": long,
      "companyId": companyId,
      "officeId": officeId
    });
    if (response.statusCode == 200 || response.statusCode == 201) {
      print(
          "Data all added county ${countyName} + ${stateName} + ${countryName} + ${lat} + ${long} + ${companyId} + ${officeId}");
      print("County added");
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
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

/// County Update
Future<ApiData> updateCounty(
    BuildContext context,
    int countyId,
    String countyName,
    String stateName,
    String countryName,
    String lat,
    String long,
    int companyId,
    String officeId) async {
  try {
    var response = await Api(context)
        .patch(path: AllZoneRepository.updateCounty(countyId: countyId), data: {
      "countyName": countyName,
      "state": stateName,
      "Country": countryName,
      "latitude": lat,
      "longitude": long,
      "companyId": companyId,
      "officeId": officeId
    });
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("County updates");
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
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

/// County prefill Get
Future<CountyPrefillGet> countyPrefillGet(
    BuildContext context, int countyId) async {
  var itemsList;
  try {
    final response = await Api(context)
        .get(path: AllZoneRepository.updateCounty(countyId: countyId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      // print("Org Document response:::::${itemsList}");
      print("1");

      itemsList = CountyPrefillGet(
          countyName: response.data['countyName'],
          state: response.data['state'] ?? "",
          country: response.data['Country'] ?? "",
          sucess: true,
          message: response.statusMessage,
          // zoneName: response.data['zoneName'],
          // zoinId: response.data['zoneId'],
          countyId: response.data['county_id'],
          companyId: response.data['companyId'],
          officeId: response.data['officeId']);
    } else {
      print('County prefill Api Error');
      return itemsList;
    }
    // print("Org response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

/// County delete
Future<ApiData> deleteCounty(BuildContext context, int countyId) async {
  try {
    var response = await Api(context)
        .delete(path: AllZoneRepository.deleteCounty(countyId: countyId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("County record Deleted");
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
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

///zipcode,zone get
Future<List<AllZipCodeGet>> getZipcodeSetup(
    BuildContext context, String officeId, pageNo, noOfRow, String countyId, String zoneId) async {
  List<AllZipCodeGet> itemsList = [];
  try {
    final companyId = await TokenManager.getCompanyId();
    final response = await Api(context).get(
        path: AllZoneRepository.zipcodeSetupGet(
            companyId: companyId,
            officeId: officeId,
            pageNo: pageNo,
            noOfRow: noOfRow, countyId: countyId, zoneId: zoneId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      // print("Org Document response:::::${itemsList}");
      print("1");
      for (var item in response.data) {
        itemsList.add(AllZipCodeGet(
            zipcodeSetupId: item['zipcodeSetupId'],
            zoneId: item['zoneId'],
            countyID: item['countyId'],
            companyID: item['companyId'],
            city: item['city'],
            zipcode: item['zipcode'],
            latitude: item['latitude'],
            longitude: item['longitude'],
            landmark: item['landmark'],
            officeId: item['officeId'],
            sucess: true,
            message: response.statusMessage,
            zoneName: item['zone'] ?? "--",
            countyName: item['county'] ?? "--"));
      }
      // print("Org Document response:::::${itemsList}");
    } else {
      print('Zone,zipcode Api Error');
      return itemsList;
    }
    // print("Org response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

/// Zipcode prefill
Future<ZipCodeGetPrefill> getZipcodeSetupPrefill(
    BuildContext context, int zipCodeSetupId) async {
  var itemsList;
  try {
    final response = await Api(context).get(
        path: AllZoneRepository.deleteZipCodeSetup(
            zipCodeSetupId: zipCodeSetupId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      // print("Org Document response:::::${itemsList}");
      print("1");

      itemsList = ZipCodeGetPrefill(
          zipcodeSetupId: response.data['zipcodeSetupId'],
          zoneId: response.data['zoneId'],
          countyID: response.data['countyId'],
          companyID: response.data['companyId'],
          city: response.data['city'],
          zipcode: response.data['zipcode'],
          latitude: response.data['latitude'],
          longitude: response.data['longitude'],
          landmark: response.data['landmark'],
          officeId: response.data['officeId'],
          zoneName: response.data['zoneName'] ?? "--",
          countyName: response.data['countyName'] ?? "--"
      );

      // print("Org Document response:::::${itemsList}");
    } else {
      print('Zone,zipcode Api Error');
      return itemsList;
    }
    // print("Org response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

/// Zipcode delete
Future<ApiData> deleteZipCodeSetup(
    BuildContext context, int zipCodeSetupId) async {
  try {
    var response = await Api(context).delete(
        path: AllZoneRepository.deleteZipCodeSetup(
            zipCodeSetupId: zipCodeSetupId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Zip Code record Deleted");
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
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

/// Add zipCode
Future<ApiData> addZipCodeSetup(
  BuildContext context,
  int zoneId,
  int countyId,
  String officeId,
  String cityName,
  List<String> zipCode,
  String latitude,
  String longitude,
  String landmark,
) async {
  try {
    final companyId = await TokenManager.getCompanyId();
    var response = await Api(context)
        .post(path: AllZoneRepository.addZipCodeSetupPost(), data: {
      "zoneId": zoneId,
      "countyId": countyId,
      "city": cityName,
      "zipcode": zipCode,
      "latitude": latitude,
      "longitude": longitude,
      "landmark": landmark,
      "companyId": companyId,
      "officeId": officeId
    });
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Zip Code record Added");
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
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

///zone sort by dropdown22-8
Future<List<SortByZoneData>> ZoneZipcodeDropdown(
    String officeId,
    BuildContext context,) async {
  List<SortByZoneData> itemsList = [];
  try {
    final companyID = await TokenManager.getCompanyId();
    final response = await Api(context).get(
        path: EstablishmentManagerRepository.getzonezipcodedropdown(
            companyID: companyID, officeId: officeId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(
          SortByZoneData(
            zoneId: item['zone_id'] ?? 0,
            zoneName: item['zoneName'] ?? "--",
          ),
        );
        print(" zipcode zone dropdown$response");
      }
    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}


/// Uodate zipcode setup
/// Add zipCode
Future<ApiData> updateZipCodeSetup(
    BuildContext context,
    int zipCodeSetupId,
    int zoneId,
    int countyId,
    String officeId,
    String cityName,
    String zipCode,
    String latitude,
    String longitude,
    String landmark,
    ) async {
  try {
    final companyId = await TokenManager.getCompanyId();
    var response = await Api(context).patch(
        path: AllZoneRepository.updateZipCodeSetup(
            zipCodeSetupId: zipCodeSetupId),
        data: {
          "zoneId": zoneId,
          "countyId": countyId,
          "city": cityName,
          "zipcode": zipCode,
          "latitude": latitude,
          "longitude": longitude,
          "landmark": landmark,
          "companyId": companyId,
          "officeId": officeId
        });
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Zip Code record Updated");
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
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

/// Get zipCode by countyId
Future<List<ZipcodeByCountyIdData>> getZipcodeByCountyId(
    {required BuildContext context, required int countyId}) async {
  List<ZipcodeByCountyIdData> itemsList = [];
  try {
    final companyId = await TokenManager.getCompanyId();
    final response = await Api(context).get(
        path: AllZoneRepository.zipcodeByCountyId(
            companyId: companyId, countyId: countyId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(ZipcodeByCountyIdData(
            zipcodeSetupId: item['zipcodeSetupId'],
            zoneId: item['zoneId'],
            countyId: item['countyId'],
            city: item['city'],
            zipCode: item['zipcode'],
            latitude: item['latitude'],
            longitude: item['longitude'],
            landMark: item['landmark'],
            companyId: item['companyId'],
            officeId: item['officeId']));
      }
      print("Zipcode by CountyId response:::::${itemsList}");
    } else {
      print('Zipcode by CountyId Api Error');
      return itemsList;
    }
    // print("Org response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

Future<List<ZipcodeByCompnanyIdData>> getZipcodeByCompanyLocationId(
    {required BuildContext context,}) async {
  List<ZipcodeByCompnanyIdData> itemsList = [];
  try {
    final companyId = await TokenManager.getCompanyId();
    final response = await Api(context).get(
        path: AllZoneRepository.zipcodeByCompanyId());
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(ZipcodeByCompnanyIdData(
            zipcodeSetupId: item['zipcodeSetupId'],
            zoneId: item['zoneId'],
            countyId: item['countyId'],
            city: item['city'],
            zipCode: item['zipcode'],
            latitude: item['latitude'],
            longitude: item['longitude'],
            landMark: item['landmark'],
            companyId: item['companyId'],
            officeId: item['officeId']));
      }
      print("Zipcode by CountyId response:::::${itemsList}");
    } else {
      print('Zipcode by CountyId Api Error');
      return itemsList;
    }
    // print("Org response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

/// Get zipCode by countyId & zoneId
Future<List<ZipcodeByCountyIdAndZoneIdData>> getZipcodeByCountyIdAndZoneId(
    {required BuildContext context, required int countyId,required int zoneId}) async {
  List<ZipcodeByCountyIdAndZoneIdData> itemsList = [];
  try {
    final companyId = await TokenManager.getCompanyId();
    final response = await Api(context).get(
        path: AllZoneRepository.zipcodeByCountyIdAndZoneId(
            zoneId: zoneId, countyId: countyId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(ZipcodeByCountyIdAndZoneIdData(
            zipcodeSetupId: item['zipcodeSetupId'],
            zoneId: item['zoneId'],
            countyId: item['countyId'],
            city: item['city'],
            zipCode: item['zipcode'],
            latitude: item['latitude'],
            longitude: item['longitude'],
            landMark: item['landmark'],
            companyId: item['companyId'],
            officeId: item['officeId']));
      }
      print("Zipcode by CountyId response:::::${itemsList}");
    } else {
      print('Zipcode by CountyId Api Error');
      return itemsList;
    }
    // print("Org response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}


/// Country get drop down
Future<List<CountryGetData>> getCountry(
    {required BuildContext context}) async {
  List<CountryGetData> itemsList = [];
  try {
    final companyId = await TokenManager.getCompanyId();
    final response = await Api(context).get(
        path: AllZoneRepository.countryGet());
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(CountryGetData(countryId: item['countryId'], name: item['name'], short: item['short']));
      }
      // print("country response:::::${itemsList}");
    } else {
      print('country Api Error');
      return itemsList;
    }
    // print("Org response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}