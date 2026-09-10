import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class HRController extends GetxController {
  var selectedItem = 'Admin'.obs;
  void changeSelectedItem(String newItem) {
    selectedItem.value = newItem;
  }

}

class CustomButtonController extends GetxController {}


class HRClincicalController extends GetxController {
  var selectedItem = 'Sort By'.obs;
  void changeSelectedItem(String newItem) {
    selectedItem.value = newItem;
  }
}