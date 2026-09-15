import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';



class FrontendConfigRepo {
  static String getFrontendConfigById({required int id}) {
    return "https://auth.symmetry.care/frontend-config/$id";
  }
}

class FrontendConfigManager {
  Future<FrontendConfigData?> getFrontendConfigById(
      BuildContext context,
      int id,
      ) async {
    FrontendConfigData? item;

    print("➡️ [FrontendConfigManager] API Call Started");
    print("➡️ Request URL: ${FrontendConfigRepo.getFrontendConfigById(id: id)}");

    try {
      final response = await Api(context).get(
        path: FrontendConfigRepo.getFrontendConfigById(id: id),
      );

      print("📥 Raw API Response: ${response.data}");
      print("📥 Status Code: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = Map<String, dynamic>.from(response.data ?? {});
        final cfg = Map<String, dynamic>.from(data['config'] ?? {});

        // ✅ Save raw response to SharedPreferences cache
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('frontend_config_data', jsonEncode(data));
          print("💾 Raw config cached successfully");
        } catch (e) {
          print("❌ Failed to cache config: $e");
        }

        item = FrontendConfigData(
          id: data['id'] ?? 0,
          name: data['name'] ?? "--",
          config: FrontendConfig(
            misc: cfg['misc'] ?? "--",
            year: cfg['year'] ?? "--",
            month: cfg['month'] ?? "--",
            other: cfg['other'] ?? "--",
            issuer: cfg['issuer'] ?? "--",
            consent: cfg['consent'] ?? 0,
            salesId: cfg['salesId'] ?? 0,
            scheduled: cfg['scheduled'] ?? "--",
            subDocId0: cfg['subDocId0'] ?? 0,
            clinicalId: cfg['clinicalId'] ?? 0,
            templateId: cfg['templateId'] ?? 0,
            healthDocId: cfg['healthDocId'] ?? 0,
            subDocId9MD: cfg['subDocId9MD'] ?? 0,
            subDocId2Adr: cfg['subDocId2Adr'] ?? 0,
            subDocId7SNF: cfg['subDocId7SNF'] ?? 0,
            subDocId8DME: cfg['subDocId8DME'] ?? 0,
            notApplicable: cfg['notApplicable'] ?? "--",
            subDocId10MISC: cfg['subDocId10MISC'] ?? 0,
            employmentDocId: cfg['employmentDocId'] ?? 0,
            subDocId6Leases: cfg['subDocId6Leases'] ?? 0,
            vendorContracts: cfg['vendorContracts'] ?? 0,
            administrationId: cfg['AdministrationId'] ?? 0,
            performanceDocId: cfg['performanceDocId'] ?? 0,
            billingAttachment: cfg['billingAttachment'] ?? 0,
            compensationDocId: cfg['compensationDocId'] ?? 0,
            defaultAttachment: cfg['defaultAttachment'] ?? 0,
            subDocId1Licenses: cfg['subDocId1Licenses'] ?? 0,
            certificationDocId: cfg['certificationDocId'] ?? 0,
            subDocId4CapReport: cfg['subDocId4CapReport'] ?? 0,
            subDocId5BalReport: cfg['subDocId5BalReport'] ?? 0,
            clinicianAttachment: cfg['clinicianAttachment'] ?? 0,
            acknowledgementDocId: cfg['acknowledgementDocId'] ?? 0,
            policiesAndProcedure: cfg['policiesAndProcedure'] ?? 0,
            corporateAndCompliance: cfg['corporateAndCompliance'] ?? 0,
            subDocId3CICCMedicalCR: cfg['subDocId3CICCMedicalCR'] ?? 0,
            clinicalVerificationDocId: cfg['clinicalVerificationDocId'] ?? 0,
            empdocumentTypeMetaDataId: cfg['empdocumentTypeMetaDataId'] ?? 0,
            employeeDocumentTypeMetaDataId: cfg['employeeDocumentTypeMetaDataId'] ?? 0,
          ),
        );
        print("✅ FrontendConfigData Object Created Successfully. salesId: ${item.config.salesId}");
      } else {
        print("❌ API FAILED: ${response.statusCode}");
        print("❌ Response Body: ${response.data}");
      }

      return item;
    } catch (e, st) {
      print("🔥 EXCEPTION OCCURRED: $e");
      print("🔥 StackTrace: $st");
      return null;
    }
  }
}
