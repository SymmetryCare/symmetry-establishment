import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_establishment/app/resources/provider/version_provider.dart';
import 'package:symmetry_establishment/app/services/config/error_surface.dart';
import 'package:symmetry_establishment/app/services/config/frontend_config_boot.dart';
import 'package:symmetry_establishment/app/resources/screen_route_name.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/data/navigator_arguments/screen_arguments.dart';
import 'package:symmetry_establishment/firebase_options.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/responsive_screen_em.dart';
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
import 'package:symmetry_establishment/presentation/screens/login_module/email_verification/email_verification.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/forget_pass_verification/forget_pass_verification.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/forget_password/forget_password_screen.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/login/login_screen.dart';

/// Global navigator key. The app bar reaches for it, and the post-first-frame
/// frontend-config refresh needs a `BuildContext` that outlives any one screen.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
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
  final bool signedIn = accessToken.isNotEmpty;
  EstablishmentApplication.markSession(signedIn);
  runApp(EstablishmentApplication(isSignedIn: signedIn));
}

/// Establishment runs in the same two shapes HR does — standalone at the site
/// root with its own login screen, or hosted behind symmetry-shell at
/// `/establishment/` on one origin, where the session written by the shell's
/// login is already in `localStorage` and this boots straight to the module.
/// Which one is decided at build time by `--dart-define=SHELL_PATH=/`; see
/// `app/services/shell/shell_link.dart`.
class EstablishmentApplication extends StatelessWidget {
  const EstablishmentApplication({super.key, required this.isSignedIn});

  final bool isSignedIn;

  /// Whether a session exists *now*, as opposed to at boot.
  ///
  /// [isSignedIn] is a snapshot taken in `main()`, before the first frame. It
  /// is the right thing for `initialRoute`, but it is wrong for the fallback
  /// in [_generateRoute]: after a successful login it still says `false`, so
  /// any route this table does not name would send a signed-in user back to
  /// the login screen. `onGenerateRoute` is synchronous and cannot re-read the
  /// async token store, so the login hand-off flips this instead.
  static bool _hasSession = false;

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
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Symmetry Establishment',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xff50B5E5),
          ),
          fontFamily: GoogleFonts.firaSans().fontFamily,
          useMaterial3: false,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute:
            isSignedIn ? RouteStrings.emDesktop : LoginScreen.routeName,
        onGenerateRoute: _generateRoute,
        builder: (BuildContext context, Widget? child) {
          // Replace the cached/default config with the live one once there is
          // a context to make the call with.
          FrontendConfigBoot.refreshInBackground(navigatorKey);
          return child ?? const SizedBox.shrink();
        },
      ),
    );
  }

  /// Record whether a session exists. Called from `main()` with the boot
  /// snapshot, and again when the login flow hands off to the module.
  static void markSession(bool value) => _hasSession = value;

  Route<dynamic> _generateRoute(RouteSettings settings) {
    final Widget page;

    switch (settings.name) {
      // Reaching the module means the login flow completed (or the app booted
      // with a session), so the token is written by now.
      case RouteStrings.emDesktop:
      case RouteStrings.home:
        _hasSession = true;
        page = ResponsiveScreenEM();
        break;
      case LoginScreen.routeName:
        // Logout and session-expiry both land here; the session is gone.
        _hasSession = false;
        page = const LoginScreen();
        break;
      case EmailVerification.routeName:
        final email = _emailFrom(settings.arguments);
        page = email == null
            ? const LoginScreen()
            : EmailVerification(email: email);
        break;
      case ForgetPassword.routeName:
        page = const ForgetPassword();
        break;
      case VerifyPassword.routeName:
        final email = _emailFrom(settings.arguments);
        page =
            email == null ? const LoginScreen() : VerifyPassword(email: email);
        break;
      default:
        page = _hasSession ? ResponsiveScreenEM() : const LoginScreen();
        break;
    }

    return MaterialPageRoute<void>(builder: (_) => page, settings: settings);
  }

  String? _emailFrom(Object? arguments) {
    if (arguments is ScreenArguments) {
      final email = arguments.title?.trim();
      return email == null || email.isEmpty ? null : email;
    }
    return null;
  }
}
