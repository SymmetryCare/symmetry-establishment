import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/provider/version_provider.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/login/widgets/login_mobile.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/login/widgets/login_tablet.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/login/widgets/login_web.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/responsive_screen.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/services/api/managers/version_manager/version_api_manager.dart';
import 'package:symmetry_establishment/data/api_data/version/version_model_data.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = "/logIn";
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScreen(
        mobile: const LoginMobile(),
        web: const LoginWeb(),
        tablet: const LoginTablet());
  }
}