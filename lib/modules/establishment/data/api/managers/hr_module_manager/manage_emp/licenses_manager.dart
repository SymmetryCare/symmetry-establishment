import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/manage_emp/manage_emp_repo.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/licenses_data.dart';

/// Get Licenses status wise
Future<Map<String, List<LicensesData>>> getLicenseStatusWise(
    BuildContext context, int employeeId) async {
  String safeText(dynamic value, {String fallback = '--'}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  String convertIsoToDayMonthYear(dynamic isoDate) {
    final rawDate = safeText(isoDate);
    if (rawDate == '--') return rawDate;
    // Parse ISO date string to DateTime object
    final dateTime = DateTime.tryParse(rawDate);
    if (dateTime == null) return rawDate;

    // Create a DateFormat object to format the date
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    // Format the date into "dd mm yy" format
    String formattedDate = dateFormat.format(dateTime);

    return formattedDate;
  }

  List<LicensesData> aboutToExpiryData = [];
  List<LicensesData> expiredLicenses = [];
  List<LicensesData> upToDateLicenses = [];
  try {
    final response = await Api(context).get(
        path: ManageReposotory.getLicenseStatus(
      employeeId: employeeId,
      approvedOnly: 'no',
    ));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        String formatedDate = convertIsoToDayMonthYear(item['issueDate']);
        String formatedExpDate = convertIsoToDayMonthYear(item['expDate']);
        LicensesData licenseData = LicensesData(
          country: safeText(item['country']),
          documentType: safeText(item['documentType']),
          employeeID: item['employeeId'] ?? employeeId,
          expDate: formatedExpDate,
          issueDate: formatedDate,
          licenseNumber: safeText(item['licenseNumber']),
          licenseUrl: safeText(item['licenseUrl'], fallback: ''),
          licenseure: safeText(item['licensure']),
          org: safeText(item['org']),
          status: safeText(item['status'], fallback: 'About to Expire'),
        );

        if (licenseData.status == 'Expired') {
          expiredLicenses.add(licenseData);
        } else if (licenseData.status == 'Upto date') {
          upToDateLicenses.add(licenseData);
        } else {
          aboutToExpiryData.add(licenseData);
        }
      }
    } else {
      print("License status");
    }
    return {
      'Expired': expiredLicenses,
      'Upto date': upToDateLicenses,
      'About to Expire': aboutToExpiryData
    };
  } catch (e) {
    print("error${e}");
    return {
      'Expired': expiredLicenses,
      'Upto date': upToDateLicenses,
      'About to Expire': aboutToExpiryData
    };
  }
}
