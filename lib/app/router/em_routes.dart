/// Every signed-in Establishment screen and the URL it lives at.
///
/// Establishment is served at `/establishment/` with real paths — no `#` — so
/// a page and the tab on it are both in the address bar:
///
///   /establishment/hr/employee-documents/compensation
///   /establishment/org-documents/vendor-contracts/snf
///
/// Refreshing, pressing Enter in the address bar and opening a copied link
/// all land on that exact screen. Paths below are relative to the base href.
library;

/// The pages under the header, in the order the old PageView held them —
/// [EmPage.index] is still what the header's dropdown hands back.
enum EmPage {
  dashboard('/dashboard', <String>[
    'general-setting',
    'office-location',
    'office-clinician',
    'contract-doc',
  ]),
  companyIdentity('/company-identity', <String>[]),
  users('/users', <String>[]),
  visits('/visits', <String>[]),
  designationSettings('/hr/designation-settings', <String>[
    'clinical',
    'sales',
    'administration',
  ]),
  workSchedule('/hr/work-schedule', <String>[
    'shifts-batches',
    'holidays',
  ]),
  employeeDocuments('/hr/employee-documents', <String>[
    'health',
    'certifications',
    'employment',
    'clinical-verification',
    'acknowledgement',
    'compensation',
    'performance',
    'degree',
  ]),
  payRates('/finance/pay-rates', <String>[]),
  orgDocuments('/org-documents', <String>[
    'corporate-compliance',
    'vendor-contracts',
    'policies-procedures',
  ]);

  const EmPage(this.path, this.tabs);

  /// The page's own path, without a tab.
  final String path;

  /// URL names of the page's tabs, in on-screen order. Empty: no tabs.
  final List<String> tabs;

  /// Index of [slug] in [tabs], or 0 (the first tab) when it is not one.
  int tabIndexOf(String? slug) {
    final int index = slug == null ? -1 : tabs.indexOf(slug);
    return index < 0 ? 0 : index;
  }
}

class EmRoutes {
  EmRoutes._();

  /// Sub-tabs of the Org Document tabs that have them, keyed by tab name.
  static const Map<String, List<String>> orgSubTabs = <String, List<String>>{
    'corporate-compliance': <String>[
      'licenses',
      'adr',
      'medical-cost-reports',
      'cap-reports',
      'quarterly-balance-reports',
    ],
    'vendor-contracts': <String>[
      'leases-services',
      'snf',
      'dme',
      'md',
      'misc',
    ],
  };

  /// Where the module opens, and where unknown or old URLs end up.
  static String get home => location(EmPage.dashboard);

  /// The URL of [page], on its [tab] (and Org Document [subTab]).
  static String location(EmPage page, {int tab = 0, int subTab = 0}) {
    if (page.tabs.isEmpty) return page.path;
    final String tabName = page.tabs[tab.clamp(0, page.tabs.length - 1)];
    final List<String>? subTabs =
        page == EmPage.orgDocuments ? orgSubTabs[tabName] : null;
    if (subTabs == null) return '${page.path}/$tabName';
    final String subName = subTabs[subTab.clamp(0, subTabs.length - 1)];
    return '${page.path}/$tabName/$subName';
  }

  /// The page [path] belongs to, or null when it is no page of ours.
  static EmPage? pageOf(String path) {
    for (final EmPage page in EmPage.values) {
      if (path == page.path || path.startsWith('${page.path}/')) return page;
    }
    return null;
  }

  /// Index of the Org Document sub-tab named [slug] under [tabSlug], or 0.
  static int orgSubTabIndexOf(String? tabSlug, String? slug) {
    final List<String>? subTabs = orgSubTabs[tabSlug];
    final int index = (subTabs == null || slug == null) ? -1 : subTabs.indexOf(slug);
    return index < 0 ? 0 : index;
  }

  /// The exact URL [uri] should be shown at, or null when it already is.
  ///
  /// Fills in a missing tab (`/hr/work-schedule` → its first tab), repairs an
  /// unknown one, and sends anything that is not a page — the module root,
  /// `/home`, the old `/establishmentDesktop`, a stale bookmark — to [home].
  static String? canonical(Uri uri) {
    final String path = uri.path;
    final EmPage? page = pageOf(path);
    if (page == null) return home;

    final List<String> rest = path
        .substring(page.path.length)
        .split('/')
        .where((String segment) => segment.isNotEmpty)
        .toList();
    final String? tabSlug = rest.isNotEmpty ? rest[0] : null;
    final int tab = page.tabIndexOf(tabSlug);
    final String? subSlug = rest.length > 1 ? rest[1] : null;
    final int subTab = orgSubTabIndexOf(
      page.tabs.isEmpty ? null : page.tabs[tab],
      subSlug,
    );

    final String target = location(page, tab: tab, subTab: subTab);
    return target == path ? null : target;
  }
}
