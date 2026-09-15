import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/register_enroll_popup.dart';

/// main screen controller
/// prachi
class ScreenSizeController extends GetxController {
  /// Flag to determine if it's a tablet screen
  RxBool isTabletScreen = false.obs;
  RxBool isMobileScreen = false.obs;
  RxBool isDesktopScreen = false.obs;

  /// Method to check and set the screen type
  void checkScreenType(double screenWidth) {
    isTabletScreen.value = screenWidth < 800 && screenWidth > 414;
    isMobileScreen.value = screenWidth <= 414;
    isDesktopScreen.value = screenWidth > 800;
  }
}

class MyAppTabBarController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final List<Widget> tabs;
  final List<Widget> tabViews;
  final double tabBarViewHeight;
  final double tabBarViewWidth;

  MyAppTabBarController(
      {required this.tabs,
      required this.tabViews,
      this.tabBarViewHeight = 600.0,
      required this.tabBarViewWidth});

  @override
  void onInit() {
    tabController = TabController(length: tabs.length, vsync: this);
    super.onInit();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}

class CenteredTabBarController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final List<Widget> tabs;
  final List<Widget> tabViews;
  final double tabBarViewHeight;
  final double tabBarViewWidth;

  CenteredTabBarController({
    required this.tabs,
    required this.tabViews,
    this.tabBarViewHeight = 330.0,
    this.tabBarViewWidth = 600.0,
  });
///
  @override
  void onInit() {
    tabController = TabController(length: tabs.length, vsync: this);
    super.onInit();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}

class CenteredTabBarChildController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final List<Widget>? tabs;
  final List<Widget>? tabViews;
  final double tabBarViewHeight;
  final double tabBarViewWidth;
  int? employeeId;

  CenteredTabBarChildController({
    this.employeeId,
     this.tabs,
     this.tabViews,
    this.tabBarViewHeight = 250.0, //250
    this.tabBarViewWidth = 620.0,
  });

  @override
  void onInit() {
    print("Controller employeeId :: ${employeeId}");
    tabController = TabController(length: tabs!.length, vsync: this);
    super.onInit();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}


class RegisterController extends GetxController {
  final isDialogOpen = false.obs;

  void closeDialog() {
    isDialogOpen.value = false;
  }
}


class AddEmployeeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final List<Widget> tabs;
  final List<Widget> tabViews;
  final double tabBarViewHeight;
  final double tabBarViewWidth;

  AddEmployeeController({
    required this.tabs,
    required this.tabViews,
    this.tabBarViewHeight = 500.0, //250
    this.tabBarViewWidth = 500.0,
  });

  @override
  void onInit() {
    tabController = TabController(length: tabs.length, vsync: this);
    super.onInit();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}


class OnboardingController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final List<Widget> tabs;
  final List<Widget> tabViews;
  final double tabBarViewHeight;
  final double tabBarViewWidth;

  OnboardingController({
    required this.tabs,
    required this.tabViews,
    this.tabBarViewHeight = 300.0, //250
    this.tabBarViewWidth = 500.0,
  });

  @override
  void onInit() {
    tabController = TabController(length: tabs.length, vsync: this);
    super.onInit();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}


class QualificationTabBarController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  final List<Widget> tabs;
  final List<Widget> tabViews;
  final double tabBarViewHeight;
  final double tabBarViewWidth;

  QualificationTabBarController({
    required this.tabs,
    required this.tabViews,
    this.tabBarViewHeight = 400.0, //320
    this.tabBarViewWidth = 600.0,
  });

  @override
  void onInit() {
    tabController = TabController(length: tabs.length, vsync: this);
    super.onInit();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}


///rohit
class SeeAllHrController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final List<Widget> tabs;
  final List<Widget> tabViews;
  final double tabBarViewHeight;
  final double tabBarViewWidth;

  SeeAllHrController({
    required this.tabs,
    required this.tabViews,
    this.tabBarViewHeight = 300.0, //250
    this.tabBarViewWidth = 500.0,
  });

  @override
  void onInit() {
    tabController = TabController(length: tabs.length, vsync: this);
    super.onInit();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}