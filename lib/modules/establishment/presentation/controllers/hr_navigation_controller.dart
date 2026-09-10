import 'package:get/get.dart';

/// HR-owned navigation state extracted from the legacy all-modules shell.
class HrNavigationController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  void selectButton(int index) {
    selectedIndex.value = index;
  }
}
