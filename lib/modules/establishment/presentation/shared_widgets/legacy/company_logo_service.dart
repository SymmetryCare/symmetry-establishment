import 'package:flutter/material.dart';

import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/whitelabelling_manager.dart';

enum LogoStatus { idle, loading, loaded, error }

class CompanyLogoService {
  CompanyLogoService._();
  static final CompanyLogoService instance = CompanyLogoService._();

  final ValueNotifier<LogoStatus> statusNotifier =
  ValueNotifier(LogoStatus.idle);

  /// Each entry is a [_LogoEntry] wrapping a [WLLogoModal.url]; matches
  /// _service.cachedLogo?[0].logoUrl usage in CompanyLogoWidget.
  List<dynamic>? cachedLogo;

  bool _initialized = false;

  // ── First load — called once from CompanyLogoWidget.initState ─────────────
  Future<void> init(BuildContext context) async {
    if (_initialized) return;
    _initialized = true;
    await _fetchAndApply(context);
  }

  // ── Force re-fetch — call after uploading/changing the logo ────────────────
  /// Use this when you DON'T already have the new URL in hand (e.g. the
  /// upload response doesn't return it) and need to hit the API again.
  Future<void> refresh(BuildContext context) async {
    await _fetchAndApply(context);
  }

  // ── Push a known URL directly — no network round-trip ───────────────────
  /// Use this when the upload/patch response already contains the new logo
  /// URL. Faster than refresh() and avoids a race with server-side processing.
  void updateLogoUrl(String newUrl) {
    cachedLogo = [
      _LogoEntry(logoUrl: newUrl),
    ];
    statusNotifier.value = LogoStatus.loaded;
  }

  Future<void> _fetchAndApply(BuildContext context) async {
    statusNotifier.value = LogoStatus.loading;
    try {
      final result = await _fetchLogoFromApi(context);
      cachedLogo = result;
      statusNotifier.value = LogoStatus.loaded;
    } catch (e) {
      debugPrint('CompanyLogoService – fetch error: $e');
      statusNotifier.value = LogoStatus.error;
    }
  }

  Future<List<dynamic>> _fetchLogoFromApi(BuildContext context) async {
    final data = await getWhiteLabellingData(context);
    return data.logos
        .where((logo) => logo.url.trim().isNotEmpty)
        .map((logo) => _LogoEntry(logoUrl: logo.url))
        .toList();
  }
}

/// Lightweight adapter exposing a `.logoUrl` getter, since CompanyLogoWidget
/// is shared across app bars and shouldn't depend on the WLLogoModal type.
class _LogoEntry {
  final String logoUrl;
  const _LogoEntry({required this.logoUrl});
}