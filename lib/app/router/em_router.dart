import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_establishment/app/router/em_routes.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_tab_widget/ci_org_document.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_tab_widget/ci_visit.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_tab_widget/company_identity.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/dashboard/dashboard_main_button_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/hr_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/manage_employee_documents/manage_emp_doc.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/manage_pay_rates/finance_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/manage_work_schedule/manage_work_schedule.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/responsive_screen_em.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/see_all_screen/see_all_provider.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/see_all_screen/see_all_screen.dart';

/// The signed-in screens' router: one URL per page and per tab, see
/// [EmRoutes]. The login flow is not on it — it is its own app, see main.dart.
///
/// The header and footer are a [ShellRoute] around every page, so moving
/// between pages swaps only the page. Each page keeps one Navigator page key
/// for all of its tabs: a tab change updates the page in place instead of
/// rebuilding it, and the page follows the URL with [RouteTabSync].
///
/// Back and Forward walk the pages visited, like any website. Switching tabs
/// rewrites the current history entry instead of adding one ([Router.neglect]),
/// so Back does not step through every tab clicked.
class EmRouter {
  EmRouter._();

  static GoRouter? _router;

  /// Created once and kept, so signing out and back in returns to the screen
  /// the session was on. [navigatorKey]'s context is what main.dart's start-up
  /// work (frontend config, department ids) runs its API calls with.
  static GoRouter router(GlobalKey<NavigatorState> navigatorKey) {
    return _router ??= GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: EmRoutes.home,
      redirect: (BuildContext context, GoRouterState state) =>
          EmRoutes.canonical(state.uri),
      onException: (BuildContext context, GoRouterState state,
              GoRouter router) =>
          router.go(EmRoutes.home),
      routes: <RouteBase>[
        ShellRoute(
          builder: (BuildContext context, GoRouterState state, Widget child) {
            return ResponsiveScreenEM(
              page: EmRoutes.pageOf(state.uri.path) ?? EmPage.dashboard,
              child: child,
            );
          },
          routes: <RouteBase>[
            GoRoute(
              path: '${EmPage.dashboard.path}/:tab',
              pageBuilder: (BuildContext context, GoRouterState state) {
                const EmPage page = EmPage.dashboard;
                return _page(
                  page,
                  DashboardMainButtonScreen(
                    initialTab: _tab(page, state),
                    onTabChanged: _goToTab(context, page),
                  ),
                );
              },
            ),
            GoRoute(
              path: EmPage.companyIdentity.path,
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  _page(EmPage.companyIdentity, CompanyIdentity()),
            ),
            GoRoute(
              path: EmPage.users.path,
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  _page(
                EmPage.users,
                ChangeNotifierProvider(
                  create: (_) => SeeAllProvider(),
                  child: SeeAllScreen(),
                ),
              ),
            ),
            GoRoute(
              path: EmPage.visits.path,
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  _page(EmPage.visits, CiVisitScreen()),
            ),
            GoRoute(
              path: '${EmPage.designationSettings.path}/:tab',
              pageBuilder: (BuildContext context, GoRouterState state) {
                const EmPage page = EmPage.designationSettings;
                return _page(
                  page,
                  ChangeNotifierProvider(
                    create: (_) => HrScreenProvider(),
                    child: HrScreen(
                      initialTab: _tab(page, state),
                      onTabChanged: _goToTab(context, page),
                    ),
                  ),
                );
              },
            ),
            GoRoute(
              path: '${EmPage.workSchedule.path}/:tab',
              pageBuilder: (BuildContext context, GoRouterState state) {
                const EmPage page = EmPage.workSchedule;
                final int tab = _tab(page, state);
                return _page(
                  page,
                  ChangeNotifierProvider(
                    create: (_) => WorkScheduleProvider(initialIndex: tab),
                    child: WorkSchedule(
                      initialTab: tab,
                      onTabChanged: _goToTab(context, page),
                    ),
                  ),
                );
              },
            ),
            GoRoute(
              path: '${EmPage.employeeDocuments.path}/:tab',
              pageBuilder: (BuildContext context, GoRouterState state) {
                const EmPage page = EmPage.employeeDocuments;
                final int tab = _tab(page, state);
                return _page(
                  page,
                  ChangeNotifierProvider(
                    create: (_) =>
                        ManageEmployDocumentProvider(initialIndex: tab),
                    child: ManageEmployDocument(
                      initialTab: tab,
                      onTabChanged: _goToTab(context, page),
                    ),
                  ),
                );
              },
            ),
            GoRoute(
              path: EmPage.payRates.path,
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  _page(
                EmPage.payRates,
                ChangeNotifierProvider(
                  create: (_) => FinanceProvider(),
                  child: FinanceScreen(),
                ),
              ),
            ),
            // Policies & Procedures has no sub-tabs; the other two do.
            GoRoute(
              path: '${EmPage.orgDocuments.path}/:tab',
              pageBuilder: _orgDocumentsPage,
            ),
            GoRoute(
              path: '${EmPage.orgDocuments.path}/:tab/:sub',
              pageBuilder: _orgDocumentsPage,
            ),
          ],
        ),
      ],
    );
  }

  static Page<void> _orgDocumentsPage(
      BuildContext context, GoRouterState state) {
    const EmPage page = EmPage.orgDocuments;
    final int tab = _tab(page, state);
    final int subTab = EmRoutes.orgSubTabIndexOf(
      state.pathParameters['tab'],
      state.pathParameters['sub'],
    );
    return _page(
      page,
      CiOrgDocument(
        initialTab: tab,
        initialSubTab: subTab,
        onTabChanged: _goToTab(context, page),
        onSubTabChanged: (int sub) => _replace(
          context,
          EmRoutes.location(page, tab: tab, subTab: sub),
        ),
      ),
    );
  }

  /// One key per page, whatever its tab, so a tab change updates the page in
  /// place. No transition: pages used to swap inside a PageView, not slide in
  /// as routes.
  static Page<void> _page(EmPage page, Widget child) {
    return NoTransitionPage<void>(
      key: ValueKey<String>('em-${page.name}'),
      child: child,
    );
  }

  static int _tab(EmPage page, GoRouterState state) =>
      page.tabIndexOf(state.pathParameters['tab']);

  static ValueChanged<int> _goToTab(BuildContext context, EmPage page) =>
      (int tab) => _replace(context, EmRoutes.location(page, tab: tab));

  /// Show [location] in the address bar without adding a Back step.
  static void _replace(BuildContext context, String location) {
    Router.neglect(context, () => GoRouter.of(context).go(location));
  }
}
