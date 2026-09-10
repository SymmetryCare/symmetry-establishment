import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:symmetry_establishment/app/services/api/managers/appconfige_manager/appconfige_manager.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';

/// Populates [FrontendConfigStore] before the first frame.
///
/// The Establishment screens read this store through `FrontendConfigStore.data!`
/// in ~340 places — document type ids, department ids, expiry-type labels. A
/// null store is therefore not a degraded UI, it is a thrown exception and a
/// white screen, so the store must be non-null *before* any screen builds.
///
/// Three sources, in order:
///
/// 1. **The cache.** `SharedPreferences` is `localStorage` on web, scoped to the
///    origin — so when Establishment runs at `/establishment/` behind the
///    shell, the config the shell already fetched and cached under
///    `frontend_config_data` is right there, exactly like the session token.
/// 2. **Defaults**, if there is no cache. A standalone first run has nobody to
///    inherit from, and a wrong-but-present id renders a working screen while a
///    null one renders nothing at all.
/// 3. **The API**, refreshed after the first frame by [refreshInBackground],
///    which also rewrites the cache for next time.
class FrontendConfigBoot {
  FrontendConfigBoot._();

  static const String _cacheKey = 'frontend_config_data';
  static bool _refreshed = false;

  /// Await this before `runApp`. Leaves [FrontendConfigStore.data] non-null.
  static Future<void> ensureLoaded() async {
    await _loadFromCache();
    if (FrontendConfigStore.data == null) {
      print('No cached frontend config - seeding defaults until the API answers');
      FrontendConfigStore.data = _defaults();
    }
  }

  static Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      if (cached == null) return;
      final data = Map<String, dynamic>.from(jsonDecode(cached));
      FrontendConfigStore.data = _fromJson(data);
      print('Frontend config restored from cache. '
          'salesId: ${FrontendConfigStore.data?.config.salesId}');
    } catch (e) {
      print('Frontend config cache load error: $e');
    }
  }

  /// Fetch the live config once the UI exists, and replace whatever we booted
  /// with. Safe to call on every start; it only runs once per session.
  static void refreshInBackground(GlobalKey<NavigatorState> navigatorKey) {
    if (_refreshed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ctx = navigatorKey.currentState?.context;
      if (ctx == null) return;
      final res = await FrontendConfigManager().getFrontendConfigById(ctx, 1);
      if (res != null) {
        FrontendConfigStore.data = res;
        _refreshed = true;
        print('Frontend config loaded from API. '
            'salesId: ${FrontendConfigStore.data?.config.salesId}');
      } else {
        print('Frontend config API returned null - booted values still active');
      }
    });
  }

  static FrontendConfigData _fromJson(Map<String, dynamic> data) {
    final cfg = Map<String, dynamic>.from(data['config'] ?? {});
    return FrontendConfigData(
      id: data['id'] ?? 0,
      name: data['name'] ?? '--',
      config: FrontendConfig(
        misc: cfg['misc'] ?? '--',
        year: cfg['year'] ?? '--',
        month: cfg['month'] ?? '--',
        other: cfg['other'] ?? '--',
        issuer: cfg['issuer'] ?? '--',
        consent: cfg['consent'] ?? 0,
        salesId: cfg['salesId'] ?? 0,
        scheduled: cfg['scheduled'] ?? '--',
        subDocId0: cfg['subDocId0'] ?? 0,
        clinicalId: cfg['clinicalId'] ?? 0,
        templateId: cfg['templateId'] ?? 0,
        healthDocId: cfg['healthDocId'] ?? 0,
        subDocId9MD: cfg['subDocId9MD'] ?? 0,
        subDocId2Adr: cfg['subDocId2Adr'] ?? 0,
        subDocId7SNF: cfg['subDocId7SNF'] ?? 0,
        subDocId8DME: cfg['subDocId8DME'] ?? 0,
        notApplicable: cfg['notApplicable'] ?? '--',
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
        employeeDocumentTypeMetaDataId:
            cfg['employeeDocumentTypeMetaDataId'] ?? 0,
      ),
    );
  }

  /// The ids the monolith's `AppConfig` compiled in for the demo instance, used
  /// only until the API answers. The labels match the strings the screens
  /// compare against (`issuer`, `year`, ...), so expiry-type branches behave.
  static FrontendConfigData _defaults() => FrontendConfigData(
        id: 0,
        name: 'defaults',
        config: FrontendConfig(
          misc: 'MISC',
          year: 'Year',
          month: 'Month',
          other: 'Other',
          issuer: 'Issuer Expiry',
          scheduled: 'Scheduled',
          notApplicable: 'Not Applicable',
          consent: 3,
          clinicianAttachment: 1,
          billingAttachment: 2,
          defaultAttachment: 0,
          salesId: 2,
          clinicalId: 1,
          administrationId: 3,
          templateId: 2,
          corporateAndCompliance: 1,
          vendorContracts: 2,
          policiesAndProcedure: 3,
          subDocId0: 0,
          subDocId1Licenses: 1,
          subDocId2Adr: 2,
          subDocId3CICCMedicalCR: 3,
          subDocId4CapReport: 4,
          subDocId5BalReport: 5,
          subDocId6Leases: 6,
          subDocId7SNF: 7,
          subDocId8DME: 8,
          subDocId9MD: 9,
          subDocId10MISC: 10,
          healthDocId: 1,
          certificationDocId: 2,
          employmentDocId: 3,
          clinicalVerificationDocId: 4,
          acknowledgementDocId: 5,
          compensationDocId: 6,
          performanceDocId: 7,
          empdocumentTypeMetaDataId: 1,
          employeeDocumentTypeMetaDataId: 5,
        ),
      );
}
