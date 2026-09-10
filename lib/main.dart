import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_establishment/app/resources/provider/version_provider.dart';
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
import 'package:symmetry_establishment/presentation/screens/login_module/email_verification/email_verification.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/forget_pass_verification/forget_pass_verification.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/forget_password/forget_password_screen.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/login/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'config/establishment.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final accessToken = await TokenManager.getAccessToken();
  runApp(EstablishmentApplication(isSignedIn: accessToken.isNotEmpty));
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
      ],
      child: MaterialApp(
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
      ),
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    final Widget page;

    switch (settings.name) {
      case RouteStrings.emDesktop:
        page = ResponsiveScreenEM();
        break;
      case LoginScreen.routeName:
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
        page = isSignedIn ? ResponsiveScreenEM() : const LoginScreen();
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
