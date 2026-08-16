import 'package:flutter/cupertino.dart';
import 'package:prohealth/app/services/api/managers/establishment_manager/user.dart';
import 'package:prohealth/data/api_data/establishment_data/user/user_modal.dart';
import 'package:prohealth/presentation/screens/em_module/see_all_screen/see_all_provider.dart';
import 'package:provider/provider.dart';

// class EditUserProvider with ChangeNotifier {
//   UserModalPrefill? prefillData;
//   final firstNameController = TextEditingController();
//   final lastNameController = TextEditingController();
//   final emailController = TextEditingController();
//   final companyIdController = TextEditingController();
//
//   Future<void> fetchPrefillData(BuildContext context, int userId) async {
//     try {
//       prefillData = await getUserPrefill(context, userId);
//       if (prefillData != null) {
//         firstNameController.text = prefillData!.firstName ?? "";
//         lastNameController.text = prefillData!.lastName ?? "";
//         emailController.text = prefillData!.email ?? "";
//         companyIdController.text = prefillData!.companyId.toString();
//       }
//       notifyListeners();
//     } catch (e) {
//       print("Error fetching prefill data: $e");
//     }
//   }
//
//   @override
//   void dispose() {
//     firstNameController.dispose();
//     lastNameController.dispose();
//     emailController.dispose();
//     companyIdController.dispose();
//     super.dispose();
//   }
// }
///
class EditUserProvider with ChangeNotifier {
  UserModalPrefill? prefillData;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final companyIdController = TextEditingController();

  Future<void> fetchPrefillData(BuildContext context, int userId) async {
    try {
      prefillData = await getUserPrefill(context, userId);
      if (prefillData != null) {
        firstNameController.text = prefillData!.firstName ?? "";
        lastNameController.text = prefillData!.lastName ?? "";
        emailController.text = prefillData!.email ?? "";
        companyIdController.text = prefillData!.companyId.toString();
      }
      notifyListeners();
    } catch (e) {
      print("Error fetching prefill data: $e");
    }
  }

  Future<void> updateUser(BuildContext context, UserModal updatedUser) async {
    try {

      final response = await updateUserPatch(
        context: context,
        userId: updatedUser.userId,
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        deptId: prefillData!.deptId,
        email: emailController.text,
      );

      if (response.success) {

        final seeAllProvider = Provider.of<SeeAllProvider>(context, listen: false);


        seeAllProvider.updateUserInList(updatedUser);


        notifyListeners();
      } else {
        print("Error updating user: ${response.message}");
      }
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    companyIdController.dispose();
    super.dispose();
  }
}
