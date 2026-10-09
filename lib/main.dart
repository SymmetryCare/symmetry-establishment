import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:symmetry_establishment/app/services/title/app_title.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_establishment/app/login_flow_app.dart';
import 'package:symmetry_establishment/app/resources/provider/version_provider.dart';
import 'package:symmetry_establishment/app/router/em_router.dart';
import 'package:symmetry_establishment/app/services/config/error_surface.dart';
import 'package:symmetry_establishment/app/services/config/frontend_config_boot.dart';
import 'package:symmetry_establishment/app/services/session/app_session.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/firebase_options.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/see_all_screen/widgets/user_edit_provider.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/see_all_screen/widgets/user_pagination.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/manage_work_schedule/work_schedule/widgets/add_holiday_popup_const.dart';
import 'package:symmetry_establishment/modules/establishment/providers/em_main_provider.dart';
import 'package:symmetry_establishment/modules/establishment/providers/navigation_provider.dart';
import 'package:symmetry_establishment/modules/establishment/providers/office_location.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/hr_home_screen/referesh_provider.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/manage_work_schedule/work_schedule/define_holidays.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/offer_letter_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/see_all_screen/widgets/user_delete_provider.dart';
import 'package:symmetry_establishment/modules/establishment/providers/hr_onboarding_provider.dart';
import 'package:symmetry_establishment/modules/establishment/providers/hr_register_provider.dart';
import 'package:symmetry_establishment/modules/establishment/providers/hr_search_provider.dart';
import 'package:symmetry_establishment/app/services/config/department_ids.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/all_from_hr_manager.dart';

/// The signed-in app's root navigator (the router's). The post-first-frame
/// frontend-config refresh needs a `BuildContext` that outlives any one screen.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// The login flow's navigator. Its own key: the signed-in app's router owns
/// [navigatorKey], and one GlobalKey cannot sit on two navigators.
final GlobalKey<NavigatorState> loginNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  // Real paths in the address bar — /establishment/users, not
  // /establishment/#/establishmentDesktop — so every page and tab has a URL
  // that behaves like any website's: refresh and Enter in the address bar
  // reload that screen, and a copied link opens it. Must run before the
  // first frame.
  //
  // The server has to answer every path under /establishment/ with
  // /establishment/index.html (see README.md, "Deploy"), or a refresh on any
  // page but the first is a 404. Old #/ links are rewritten in
  // web/index.html.
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  // No-op unless built with --dart-define=DEBUG_ERRORS=true.
  ErrorSurface.install();
  await dotenv.load(fileName: 'config/establishment.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Must complete before the first frame: the Establishment screens read
  // `FrontendConfigStore.data!` in ~340 places, so a null store is a white
  // screen rather than a degraded one. See FrontendConfigBoot.
  await FrontendConfigBoot.ensureLoaded();

  final accessToken = await TokenManager.getAccessToken();
  if (accessToken.isNotEmpty) AppSession.instance.start();
  runApp(const EstablishmentApplication());
}

/// Establishment runs in the same two shapes HR does — standalone at the site
/// root with its own login screen, or hosted behind symmetry-shell at
/// `/establishment/` on one origin, where the session written by the shell's
/// login is already in `localStorage` and this boots straight to the module.
/// Which one is decided at build time by `--dart-define=SHELL_PATH=/`; see
/// `app/services/shell/shell_link.dart`.
///
/// Signed out, it shows the login flow ([LoginFlowApp]); signed in, the
/// Establishment pages on go_router ([EmRouter]), one URL per page and tab.
/// [AppSession] decides which, and switches on login, sign-out and expiry.
/// Every provider sits above both, so neither swap loses app-wide state.
class EstablishmentApplication extends StatelessWidget {
  const EstablishmentApplication({super.key});

  static final ThemeData _theme = ThemeData(
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: const Color(0xff50B5E5),
    ),
    fontFamily: GoogleFonts.firaSans().fontFamily,
    useMaterial3: false,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  /// Start-up work that needs a context under the providers: the live
  /// frontend config, and this tenant's own department ids. Each runs its API
  /// call with [key]'s navigator context once the first frame is up.
  static TransitionBuilder _startUpWork(GlobalKey<NavigatorState> key) {
    return (BuildContext context, Widget? child) {
      // Replace the cached/default config with the live one once there is
      // a context to make the call with.
      FrontendConfigBoot.refreshInBackground(key);
      // And this tenant's own department ids, which the global
      // config above does NOT supply — its clinicalId/salesId/
      // administrationId are the same for every tenant, while
      // Department.DepartmentId is per-tenant and need not match.
      // Warmed here so the screens that need it have it; every
      // lookup falls back to the configured id regardless.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = key.currentState?.context;
        if (ctx != null) {
          // companyHRHeadApi takes a deptId it only prints — the
          // endpoint behind it (getHrType) lists every department
          // and takes no id — so the 0 here is ignored.
          DepartmentIds.ensureLoaded(
            ctx,
            (c) => companyHRHeadApi(c, 0),
          );
        }
      });
      return child ?? const SizedBox.shrink();
    };
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VersionProviderManager()),
        ChangeNotifierProvider(create: (_) => RouteProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => EmMainProvider()),
        ChangeNotifierProvider(
            create: (_) => SeeAllPaginationProvider(itemsPerPage: 10)),
        ChangeNotifierProvider(create: (_) => EditUserProvider()),
        ChangeNotifierProvider(create: (_) => AddHolidayProvider()),

        // Consumed by screens the module reaches from the dashboard, and
        // provided nowhere below them - a `Consumer<T>` with no matching
        // provider above it throws ProviderNotFoundException and takes the
        // whole screen down. symmetry-hr registers the same set app-wide in
        // its own main.dart; these were simply not carried over when this
        // entrypoint was written, so each screen crashed the first time it
        // was opened.
        ChangeNotifierProvider(create: (_) => HrManageProvider()),
        ChangeNotifierProvider(create: (_) => HrSearchProviderManager()),
        ChangeNotifierProvider(create: (_) => HrRegisterProvider()),
        ChangeNotifierProvider(create: (_) => HrEnrollEmployeeProvider()),
        ChangeNotifierProvider(create: (_) => HrEnrollOfferLatterProvider()),
        ChangeNotifierProvider(create: (_) => HrOnboardingProvider()),
        ChangeNotifierProvider(create: (_) => HrProgressMultiStape()),
        ChangeNotifierProvider(create: (_) => HRLicenseProvider()),
        ChangeNotifierProvider(create: (_) => HRBankingProvider()),
        ChangeNotifierProvider(create: (_) => PageIndexProvider()),

        // Not in HR's list - these belong to Establishment-only screens
        // (Manage HR > Work Schedule > Define Holidays, and the See All user
        // table's delete action), which likewise provide them nowhere.
        ChangeNotifierProvider(create: (_) => DefineHolidaysProvider()),
        ChangeNotifierProvider(create: (_) => DeleteUserProvider()),
      ],
      child: ListenableBuilder(
        listenable: AppSession.instance,
        builder: (BuildContext context, Widget? _) {
          if (!AppSession.instance.isSignedIn) {
            return LoginFlowApp(
              navigatorKey: loginNavigatorKey,
              title: AppTitle.value,
              theme: _theme,
              builder: _startUpWork(loginNavigatorKey),
            );
          }
          return MaterialApp.router(
            title: AppTitle.value,
            debugShowCheckedModeBanner: false,
            theme: _theme,
            routerConfig: EmRouter.router(navigatorKey),
            builder: _startUpWork(navigatorKey),
          );
        },
      ),
    );
  }
}
