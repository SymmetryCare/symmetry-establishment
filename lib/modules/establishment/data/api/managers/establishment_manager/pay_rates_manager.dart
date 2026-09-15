import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/establishment_manager/establishment_repository.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/pay_rates/pay_rates_finance_data.dart';

/// Get pre fill api 22-8
Future<PayRatePrefillFinanceData> payPrefillRatesDataGet(
    BuildContext context, int payRatesId) async {
  var itemsData;
  try {
    final companyId = await TokenManager.getCompanyId();
    final response = await Api(context).get(
        path: EstablishmentManagerRepository.deleteeditprefillPayRates(
            payRatesId: payRatesId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print(":::::LIST${response.data}");
      itemsData = PayRatePrefillFinanceData(
          payratesId: response.data['payratesId'] ?? 0,
          rate: response.data['rate'] ?? 0,
          typeOfVisitId: response.data['typeOfVisitId'] ?? "--",
          companyId: response.data['companyId'],
          serviceId: response.data['serviceId'],
          outOfZoneRate: response.data['outOfZoneRate'],
          outOfZoneperMile: response.data['outOfZoneperMile']
         );
    } else {
      print("Api Pay rates Data Error");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// Update pay rates
Future<ApiData> updatePayRatesSetupPost(
{
    required BuildContext context,
    required int payratesId,
    required int rate,
    required String typeOfVisitId,
    required int outOfZoneperMile,
   required int outOfZoneRate,
    required String serviceId,}
       ) async {
  try {
    final companyId = await TokenManager.getCompanyId();
    var response = await Api(context).patch(
        path: EstablishmentManagerRepository.deleteeditprefillPayRates(
            payRatesId: payratesId),
        data: {
          "typeOfVisitId": typeOfVisitId,
          "rate": rate,
          "serviceId": serviceId,
          "companyId": companyId,
          "outOfZoneRate": outOfZoneRate,
          "outOfZoneperMile": outOfZoneperMile
        });
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Pay Rates updates");
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

///zone sort by dropdown22-8
Future<List<SortByZoneData>> PayRateZoneDropdown(
    BuildContext context,) async {
  List<SortByZoneData> itemsList = [];
  try {
    final companyID = await TokenManager.getCompanyId();
    final response = await Api(context).get(
        path: EstablishmentManagerRepository.getzonedropdown(
            companyID: companyID));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(
          SortByZoneData(
            zoneId: item['zone_id'] ?? 0,
            zoneName: item['zoneName'] ?? "--",
           ),
        );
        print(" payrates dropdown$response");
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

///serviceby dropdown 22-8
Future<List<ServiceData>> PayRateServiceDropdown(
    BuildContext context,) async {
  List<ServiceData> itemsList = [];
  try {
    final companyID = await TokenManager.getCompanyId();
    final response = await Api(context).get(
        path: EstablishmentManagerRepository.companyOfficeServiceGetByCompanyId(companyId: companyID));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(
         ServiceData(
             officeServiceId: item['Office_service_id'],
             companyId: companyID,
             officeId: item['office_id'],
             serviceName: item['service_name'],
             serviceId: item['service_id'],
             npiNum: item['npi_number'],
             medicareNum: item['medicare_provider_id'],
             hcoNum: item['hco_num_id']),
        );
        print(" payrates dropdown$response");
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

/// Add pay rates POST 22-8
Future<ApiData> addPayrates(
    BuildContext context,
    int empTypeId,
    int rate,
    String typeOfVisitId,
    int perMile,
    String serviceTypeId,
    int outOfZoneRate
    ) async {
  try {
    final companyId= await TokenManager.getCompanyId();
    var response = await Api(context).post(
        path: EstablishmentManagerRepository.postPayrates(),
        data: {
          "employeeTypeId":empTypeId,
          "rate": rate,
          "typeOfVisitId": typeOfVisitId,
          "serviceId": serviceTypeId,
          "companyId": companyId,
          "outOfZoneRate": outOfZoneRate,
          "outOfZoneperMile": perMile
        });
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("payrate Addded");
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

///get 22-8
Future<List<PayRatesGet>> companyPayratesGet(BuildContext context,) async {
  List<PayRatesGet> itemsList = [];
  try {
    final companyId = await TokenManager.getCompanyId();
    final response = await Api(context)
        .get(path: EstablishmentManagerRepository.getPayrates());
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Payrates get:::::${itemsList}");
      for (var item in response.data) {
        itemsList.add(
          PayRatesGet(
            payratesId: item['payratesId'],
            rate: item['rate'],
            typeOfVisitId: item['typeOfVisitId'],
            companyId: companyId,
            serviceID: item['serviceId'],
            outOfZoneRate: item['outOfZoneRate'],
            outOfZonePerMile: item['outOfZoneperMile'],
          ),
        );
      }
      print("Payrates data:::::${itemsList}");
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


/// Get data by serviceID and employeeID
Future<List<PayRatesGetByServiceId>> companyPayratesGetByServiceAndEmployeeId({required BuildContext context,required String serviceId, required int empId}) async {
  List<PayRatesGetByServiceId> itemsList = [];
  try {
    final companyId = await TokenManager.getCompanyId();
    final response = await Api(context)
        .get(path: EstablishmentManagerRepository.getPayratesByServiceIdAnrEmpId(serviceID: serviceId, empId: empId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Payrates get by serviceId:::::${itemsList}");
      for (var item in response.data) {
        itemsList.add(
          PayRatesGetByServiceId(
            payratesId: item['payratesId'],
            rate: item['rate'],
            typeOfVisitId: item['typeOfVisitId'],
            companyId: companyId,
            serviceID: item['serviceId'],
            outOfZoneRate: item['outOfZoneRate'],
            outOfZonePerMile: item['outOfZoneperMile'],
          ),
        );
      }
      print("Payrates data:::::${itemsList}");
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

/// delete 22-8
Future<ApiData> deletePayRatesId(
    BuildContext context,
    int payRatesId,
    ) async {
  try {
    final companyId = await TokenManager.getCompanyId();
    var response = await Api(context).delete(
        path: EstablishmentManagerRepository.deleteeditprefillPayRates(
            payRatesId: payRatesId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Pay Rates Deleted");
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
///
