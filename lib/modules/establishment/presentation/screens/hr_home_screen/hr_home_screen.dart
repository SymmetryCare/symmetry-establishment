import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:symmetry_establishment/app/resources/screen_route_name.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/controllers/hr_navigation_controller.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/hr_home_screen/desk_dashboard_hrm.dart';

class HRHomeScreen extends StatelessWidget {
  static const String routeName = RouteStrings.hrDesktop;
  HRHomeScreen({super.key});
  final HrNavigationController myController =
      Get.put(HrNavigationController());

  @override
  Widget build(BuildContext context) {
    myController.selectButton(0);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 855) {
          return Padding(
            padding: MediaQuery.of(context).size.width > 1920
                ? EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 8)
                : const EdgeInsets.all(0.0),
            child: const HomeScreenHRM(),
          );
        } else {
          return Material(
            color: Colors.white,
            child: Center(
              child: SvgPicture.asset(
                'images/tablet.svg',
                fit: BoxFit.contain,
              ),
            ),
          );
        }
      },
    );
  }
}
