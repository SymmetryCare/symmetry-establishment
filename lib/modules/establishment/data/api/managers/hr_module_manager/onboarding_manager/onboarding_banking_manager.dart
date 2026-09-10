import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/onboarding/onboarding_qualification.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/onboarding_data/onboarding_banking_data.dart';

Future<List<OnboardingBankingData>> getOnboardingBanking(
BuildContext context, int employeeId, String approveOnly) async{
  List<OnboardingBankingData> itemsData = [];
  String convertIsoToDayMonthYear(String isoDate) {
    // Parse ISO date string to DateTime object
    DateTime dateTime = DateTime.parse(isoDate);

    // Create a DateFormat object to format the date
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    // Format the date into "dd mm yy" format
    String formattedDate = dateFormat.format(dateTime);

    return formattedDate;
  }
  try{
    final response = await Api(context).get(path:
    OnboardingQualificationRepo.getOnboardBanking(employeeid: employeeId, approveOnly: approveOnly));
    if(response.statusCode == 200 || response.statusCode == 201){
      for(var item in response.data){
        String StartDate = convertIsoToDayMonthYear(item['effectiveDate']);
        itemsData.add(OnboardingBankingData(
            empBankId: item['empBankingId'],
            accNum: item['accountNumber'],
            empId:  item['employeeId'],
            bankName:  item['bankName'],
            amtRequested:  item['amountRequested'],
            checkUrl:  item['checkUrl'],
            effectiveDate:  StartDate,//item['effectiveDate'],
            rountingNumber:  item['routingNumber'],
            type:  item['type'],
            approved:  item['approved'] ?? false,
        requestedPercentage: item['requestedPercentage']));
        itemsData.sort((a, b) => a.empBankId.compareTo(b.empBankId));
      }
    }else {
      print("Employment List");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}


///bybankid
Future<List<OnboardingBankingData>> getOnboardingBankingID(
    BuildContext context, int empBankingId) async{
  List<OnboardingBankingData> itemsData = [];
  try{
    final response = await Api(context).get(path:
    OnboardingQualificationRepo.getBankBYBankId(empBankingId: empBankingId));
    if(response.statusCode == 200 || response.statusCode == 201){
      for(var item in response.data){
        itemsData.add(OnboardingBankingData(
            empBankId: item['empBankingId'],
            accNum: item['accountNumber'],
            empId:  item['employeeId'],
            bankName:  item['bankName'],
            amtRequested:  item['amountRequested'],
            checkUrl:  item['checkUrl'],
            effectiveDate:  item['effectiveDate'],
            rountingNumber:  item['routingNumber'],
            type:  item['type'],
            approved:  item['approved'] ?? false,
            requestedPercentage: item['requestedPercentage']));
      }
    }else {
      print("Banking List By Id");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}