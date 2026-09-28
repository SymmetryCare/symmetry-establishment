/// Browser tab title, taken from the tenant subdomain.
///
/// `prohealth.symmetry.care` → "Establishment | Prohealth". Any host not in that shape
/// (localhost, an IP, a custom domain) is shown whole: "Establishment | localhost".
class AppTitle {
  AppTitle._();

  static const String _tenantSuffix = '.symmetry.care';

  static String get value => 'Establishment | ${_companyFromHost(Uri.base.host)}';

  static String _companyFromHost(String host) {
    if (host.endsWith(_tenantSuffix)) {
      final String tenant =
          host.substring(0, host.length - _tenantSuffix.length);
      if (tenant.isNotEmpty && !tenant.contains('.')) {
        return tenant[0].toUpperCase() + tenant.substring(1);
      }
    }
    return host;
  }
}
