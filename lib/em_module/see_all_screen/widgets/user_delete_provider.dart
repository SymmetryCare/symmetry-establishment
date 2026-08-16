
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/color.dart';
import 'package:prohealth/app/resources/common_resources/common_theme_const.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import 'package:provider/provider.dart';

///DeleteUserProvider
class DeleteUserProvider extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  Future<void> deleteUser(
      BuildContext context,
      String userId,
      Future<void> Function() deleteFunction,
      Future<void> Function() refreshFunction,
      ) async {
    setLoading(true);
    try {
      await deleteFunction();
      await refreshFunction();

      showDialog(
        context: context,
        builder: (context) => SuccessUserPopup(
          message: "User deleted successfully.....",
        ),
      );
      print("Delete user triggered for userId: $userId");
    } catch (e) {
      print("Error deleting user: $e");

    } finally {
      setLoading(false);
    }
  }

  Future<void> handlePress(
      BuildContext context, int userId, VoidCallback onCancel) async {
    await deleteUser(
      context,
      userId.toString(),
          () async {
        print("Deleting user with ID: $userId");
      },
          () async {
        print("Refreshing data after delete");
      },
    );
    onCancel();
  }

  bool _isPopupVisible = false;

  bool get isPopupVisible => _isPopupVisible;

  void showPopup() {
    _isPopupVisible = true;
    notifyListeners();
  }

  void hidePopup() {
    _isPopupVisible = false;
    notifyListeners();
  }
}

///delete user
class DeleteConfirmationPopup extends StatelessWidget {
  final String title;
  // final String content;
  final VoidCallback onConfirmed;

  const DeleteConfirmationPopup({
    super.key,
    required this.title,
    // required this.content,
    required this.onConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DeleteUserProvider>(builder: (context, provider, child) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
            width: 300,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(children: [
              Container(
                decoration: BoxDecoration(
                  color: ColorManager.bluebottom,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppPadding.p20,
                  horizontal: AppPadding.p20,
                ),
                child: Row(
                  children: [
                    Text('Do you really want to delete?',
                        style: PopupTextConst.customTextStyle(context)),
                  ],
                ),
              ),
              Spacer(),
              Center(
                child: Container(
                  height: 50,
                  width: 210,
                  child: Center(
                    child: Row(
                      children: [
                        Padding(
                            padding:
                            const EdgeInsets.only(bottom: AppPadding.p24),
                            child: SizedBox(
                              width: AppSize.s100,
                              child: ElevatedButton(
                                onPressed: () {

                                  Navigator.of(context).pop(true);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: ColorManager.bluebottom,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TransparentButtonTextConst
                                      .customTextStyle(context),
                                ),
                              ),
                            )),
                        SizedBox(width: 20),

                        Padding(padding: EdgeInsets.only(bottom: AppPadding.p24),
                          child:
                          provider.isLoading
                              ? SizedBox(
                            height: 25,
                            width: 25,
                            child: CircularProgressIndicator(
                              color: ColorManager.blueprime,
                            ),
                          )
                              : SizedBox(
                            width: AppSize.s90,
                            child:
                            ElevatedButton(
                              onPressed: () async {
                                provider.setLoading(true);
                                await Future.delayed(Duration(seconds: 2));
                                onConfirmed();
                                provider.setLoading(false);

                                Navigator.of(context).pop();


                                showDialog(
                                  context: context,
                                  builder: (context) => SuccessUserPopup(
                                    message: "User deleted successfully",
                                  ),

                                );
                                /// Close the popup after 1 sec
                                Future.delayed(Duration(milliseconds: 200), () {
                                  Navigator.of(context).pop();
                                });
                                /// Close the popup after 0 sec
                                // Future.microtask(() {
                                //   Navigator.of(context).pop();
                                // });

                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:ColorManager.bluebottom,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: ColorManager.bluebottom,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Delete',
                                style: BlueButtonTextConst.customTextStyle(context),
                              ),
                            ),
                            ///
                            // ElevatedButton(
                            //   onPressed: () async {
                            //     Navigator.of(context)
                            //         .pop(); // Close the popup
                            //     provider.setLoading(true); // Show loading
                            //     await Future.delayed(Duration(seconds: 2));
                            //     onConfirmed(); // Perform delete
                            //     provider.setLoading(false); // Stop loading
                            //     showDialog(
                            //       context: context,
                            //       builder: (context) => SuccessUserPopup(
                            //         message:
                            //         "User deleted successfully.....",
                            //       ),
                            //     );
                            //   },
                            //   style: ElevatedButton.styleFrom(
                            //     backgroundColor: Colors.blue,
                            //     elevation: 5,
                            //     shape: RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.circular(12),
                            //       side: BorderSide(
                            //         color: ColorManager.bluebottom,
                            //         width: 1,
                            //       ),
                            //     ),
                            //   ),
                            //   child: Text(
                            //     'Delete',
                            //     style: BlueButtonTextConst
                            //         .customTextStyle(context),
                            //   ),
                            // ),
                          ),

                        )

                      ],
                    ),
                  ),
                ),
              ),
              Spacer(),
            ])),
      );
    });
  }

// Padding(
//   padding: const EdgeInsets.only(bottom: AppPadding.p24, right: AppPadding.p10),
//   child: provider.isLoading
//       ? SizedBox(
//     height: AppSize.s25,
//     width: AppSize.s25,
//     child: CircularProgressIndicator(
//       color: ColorManager.blueprime,
//     ),
//   )
//       : ElevatedButton(
//     onPressed: () async {
//       provider.setLoading(true);
//       await Future.delayed(Duration(seconds: 2));
//       onConfirmed();
//       Navigator.of(context).pop(true);
//     },
//     style: ElevatedButton.styleFrom(
//       backgroundColor: Colors.white,
//       elevation: 5,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(
//           color: ColorManager.bluebottom,
//           width: 1,
//         ),
//       ),
//     ),
//     child: Text(
//       'Delete',
//       style: TransparentButtonTextConst.customTextStyle(context),
//     ),
//   ),
// ),
///
//   AlertDialog(
//   title: Text(title),
//   content: Text(content),
//   actions: [
//     TextButton(
//       onPressed: () {
//         Navigator.of(context).pop(false);
//       },
//       child: Text("NO"),
//     ),
//     TextButton(
//       onPressed: () {
//         onConfirmed();
//         Navigator.of(context).pop(true);
//       },
//       child: Text("YES"),
//     ),
//   ],
// );
}

///successfully deleted
class SuccessUserPopup extends StatelessWidget {
  final String message;

  const SuccessUserPopup({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 300,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
        color: ColorManager.bluebottom,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      "Success",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Spacer(),
            Center(
              child: Container(
                height: 50,
                width: 210,
                child: Center(
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

// InkWell(
//   child: Text(
//     'No',
//     textAlign: TextAlign.center,
//     style: TextStyle(
//       color: Colors.black,
//       fontSize: 16,
//     ),
//   ),
//   onTap: () {
//     Navigator.of(context).pop(false);
//   },
// ),
///

// class DeleteUserProvider extends ChangeNotifier {
//   bool _isLoading = false;
//
//   bool get isLoading => _isLoading;
//
//   // Set loading state
//   void setLoading(bool value) {
//     _isLoading = value;
//     notifyListeners();
//   }
// }
