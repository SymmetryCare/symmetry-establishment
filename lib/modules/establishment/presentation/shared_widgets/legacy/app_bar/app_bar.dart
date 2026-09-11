import 'package:flutter/material.dart';

import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/app_bar/app_bar_mobile.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/app_bar/app_bar_tab.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/app_bar/hh_emr_appbar.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/app_bar/responsive_app_bar.dart';

/// HR application bar retained from the parent shell without other modules.
class ApplicationEmrAppBar extends StatelessWidget {
  const ApplicationEmrAppBar({
    super.key,
    required this.headingText,
    required this.body,
    this.isHrModule = true,
    this.isEmrClinicianModule = false,
    this.hideNameOnSmallScreen = false,
    this.shortHeadingText,
    this.moduleLabel = 'Establishment',
    this.onModuleTap,
    this.onNotificationTap,
    this.searchField,
  });

  final String headingText;
  final List<Widget> body;
  final bool isHrModule;
  final bool isEmrClinicianModule;
  final bool hideNameOnSmallScreen;
  final String? shortHeadingText;
  final String moduleLabel;
  final VoidCallback? onModuleTap;
  final VoidCallback? onNotificationTap;
  final Widget? searchField;

  @override
  Widget build(BuildContext context) {
    return ResponsiveAppBar(
      mobile: const AppBarMobile(),
      web: EmrAppBar(
        isHrModule: isHrModule,
        isEmrClinicianModule: isEmrClinicianModule,
        hideNameOnSmallScreen: hideNameOnSmallScreen,
        shortHeadingText: shortHeadingText,
        headingText: headingText,
        body: body,
        moduleLabel: moduleLabel,
        onModuleTap: onModuleTap,
        onNotificationTap: onNotificationTap,
        searchField: searchField,
      ),
      tablet: const AppBarTab(),
    );
  }
}
