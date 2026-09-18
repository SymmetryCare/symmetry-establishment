import 'package:flutter/widgets.dart';

/// This tenant's department ids, looked up by name.
///
/// ## Why this exists
///
/// `Department.DepartmentId` is per-tenant data. The ids in
/// `FrontendConfigStore` — `clinicalId`, `salesId`, `administrationId` — come
/// from one global config every tenant shares
/// (`auth.symmetry.care/frontend-config/1`). All three modules treated them as
/// the same thing, which only holds on a tenant whose departments happen to
/// have been created with those exact ids.
///
/// prohealth's were not:
///
/// ```
///   tenant table          global config
///   1 = Clinical          clinicalId: 1        agrees
///   2 = Administration    salesId: 2           disagrees
///   3 = Sales             administrationId: 3  disagrees
///   4 = Patient           (absent from config)
/// ```
///
/// The consequences all pointed away from the cause. Establishment's "Sales"
/// tab wrote employee types into department 2 — Administration on that tenant.
/// An employee actually in Sales (department 3) was labelled "Select Admin
/// Type" and offered Administration's types. RIS's Marketer dropdown asked for
/// department 2 outright and so read the wrong department entirely. A Marketer
/// added for RIS was never reachable by the person who needed it.
///
/// Resolving by name fixes all of it without depending on how a tenant's
/// departments were numbered.
///
/// ## Behaviour
///
/// Loaded once per session from the same authenticated endpoint the rest of
/// the app uses; departments are reference data that does not change under a
/// running page. Every lookup takes a `fallback`, so a tenant whose ids do line
/// up behaves exactly as before, and a failed load degrades to today's
/// behaviour rather than breaking.
class DepartmentIds {
  DepartmentIds._();

  static Map<String, int>? _byLowerName;
  static Future<void>? _inFlight;

  /// Whether the tenant's departments are cached.
  static bool get isLoaded => _byLowerName != null;

  /// Names as the tenant has them. For diagnostics.
  static List<String> get names =>
      _byLowerName?.keys.toList(growable: false) ?? const <String>[];

  /// Fetch and cache the tenant's departments.
  ///
  /// Safe to call repeatedly: a completed load is not repeated and concurrent
  /// callers share one request. Never throws — a failure leaves the cache empty
  /// and every lookup falls through to its configured id.
  static Future<void> ensureLoaded(
    BuildContext context,
    Future<List<dynamic>> Function(BuildContext) fetch,
  ) {
    if (_byLowerName != null) return Future<void>.value();
    return _inFlight ??= _load(context, fetch).whenComplete(() {
      _inFlight = null;
    });
  }

  static Future<void> _load(
    BuildContext context,
    Future<List<dynamic>> Function(BuildContext) fetch,
  ) async {
    try {
      final List<dynamic> rows = await fetch(context);
      final Map<String, int> map = <String, int>{};
      for (final dynamic row in rows) {
        final String name = (row.deptName ?? '').toString().trim();
        final int id = (row.deptId ?? 0) as int;
        if (name.isEmpty || id == 0) continue;
        map[name.toLowerCase()] = id;
      }
      if (map.isEmpty) {
        // An empty result is not a cache worth keeping — leaving it null lets
        // the next screen try again rather than pinning the fallbacks for the
        // rest of the session.
        print('DepartmentIds: no departments returned — configured ids stand');
        return;
      }
      _byLowerName = map;
      print('DepartmentIds: loaded ${map.length} for this tenant: '
          '${map.entries.map((e) => "${e.value}=${e.key}").join(", ")}');
    } catch (e) {
      print('DepartmentIds: load failed ($e) — configured ids stand');
    }
  }

  /// This tenant's id for [name], or [fallback] when it is not known.
  ///
  /// Matched case-insensitively on the whole name, so "Sales" finds "sales" and
  /// never "Sales Manager" — a partial match could route people into the wrong
  /// department, which is the failure this class exists to end.
  static int idFor(String name, {required int fallback}) {
    final Map<String, int>? map = _byLowerName;
    if (map == null) return fallback;
    return map[name.trim().toLowerCase()] ?? fallback;
  }

  /// Clear the cache — for tests, and for a sign-out that may be followed by a
  /// sign-in to a different tenant on the same origin.
  static void reset() {
    _byLowerName = null;
    _inFlight = null;
  }
}
