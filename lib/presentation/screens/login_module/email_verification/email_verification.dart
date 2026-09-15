import 'package:flutter/material.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/email_verification/widgets/email_verification_mobile.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/email_verification/widgets/email_verification_tab.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/email_verification/widgets/email_verification_web.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/responsive_screen.dart';

class EmailVerification extends StatelessWidget {
  static const String routeName = "/emailVerification";
  final String email;
  const EmailVerification({
    super.key,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveScreen(
        mobile: EmailVerifyMobile(
          email: email,
        ),
        web: EmailVerifyWeb(
          email: email,
        ),
        tablet: EmailVerifyTab(
          email: email,
        ));
  }
}
