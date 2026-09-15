import 'dart:async';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/user.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/company_identity/company_identity_data_.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/user/user_modal.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/see_all_screen/widgets/user_popup_const_provider.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/delete_success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/profile_bar/widget/pagination_widget.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/register_manager/register_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/confirmation_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/see_all_screen/see_all_provider.dart';

///old no bugs
class SeeAllScreen extends StatefulWidget {
  const SeeAllScreen({super.key});

  @override
  State<SeeAllScreen> createState() => _SeeAllScreenState();
}

class _SeeAllScreenState extends State<SeeAllScreen> {
  final StreamController<List<CompanyModel>> _controller =
  StreamController<List<CompanyModel>>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController userIdController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController companyIdController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final StreamController<List<UserModal>> _companyUsersList =
  StreamController<List<UserModal>>();
  final PageController _pageController = PageController();

  late List<String> items;
  bool showStreamBuilder = true;
  bool showManageScreen = false;
  bool showWhitelabellingScreen = false;
  bool firstNameValid = true;
  bool lastNameValid = true;
  bool roleValid = true;
  bool emailValid = true;
  bool passwordValid = true;
  bool companyIdValid = true;
  bool isLoading = false;
  bool _isLoading = false;
  bool _showErrorMessage = false;
  bool isButtonEnabled = false;
  String? userLogin;

  Future<String> isUserLoggedIn() async {
    userLogin = await TokenManager.getEmail();
    print('???????????????????????????????? see all $userLogin');
    return userLogin!;
  }

  void handleSubmit() async {
    try {
      await createUserPost(
          context,
          firstNameController.text,
          lastNameController.text,
          selectedDeptId!,
          emailController.text,
          passwordController.text);
      firstNameController.clear();
      lastNameController.clear();
      roleController.clear();
      emailController.clear();
      companyIdController.clear();
      passwordController.clear();
      print('Form validated and submitted!');
    } catch (error) {
      print('Error: $error');
    } finally {
      Future.delayed(Duration(seconds: 2), () {
        print('Submit action completed!');
      });
    }
  }

  @override
  void initState() {
    super.initState();
    isUserLoggedIn();
    getUser(context, '').then((data) {
      _companyUsersList.add(data);
    }).catchError((error) {
      // Handle error
    });
    userIdController.addListener(_checkFields);
    firstNameController.addListener(_checkFields);
    lastNameController.addListener(_checkFields);
    roleController.addListener(_checkFields);
    emailController.addListener(_checkFields);
    companyIdController.addListener(_checkFields);
  }

  void _checkFields() {
    setState(() {
      isButtonEnabled = userIdController.text.isNotEmpty &&
          firstNameController.text.isNotEmpty &&
          lastNameController.text.isNotEmpty &&
          roleController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          companyIdController.text.isNotEmpty;
    });
  }

  bool _validateForm() {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        roleController.text.isEmpty ||
        emailController.text.isEmpty ||
        companyIdController.text.isEmpty ||
        passwordController.text.isEmpty) {
      return false;
    }
    return true;
  }

  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    userIdController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    roleController.dispose();
    emailController.dispose();
    companyIdController.dispose();
    super.dispose();
  }

  int currentPage = 1;
  final int itemsPerPage = 10;
  final int totalPages = 5;

  void onPageNumberPressed(int pageNumber) {
    setState(() {
      currentPage = pageNumber;
    });
  }

  var deptId = 1;
  int? firstDeptId;
  String? selectedDeptName;
  int? selectedDeptId;
  List<UserModal> _latestUsers = [];
  int _latestTotalPages = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 24),
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
          const double minContentWidth = 1200;
          final double contentWidth = constraints.maxWidth > minContentWidth
              ? constraints.maxWidth
              : minContentWidth;
          return CustomScrollbar(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppPadding.p10),
                child: SizedBox(
                  width: contentWidth,
                  height: constraints.maxHeight,
                  child: Column(
          children: [
            ///Create User Button
            Padding(
              padding: const EdgeInsets.only(right: AppPadding.p25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: AppSize.s30,
                    width: AppSize.s150,
                    child: CustomIconButton(
                      icon: Icons.add,
                      text: 'Create User',
                      isNotPopUpButton: true,
                      onPressed: () async {
                        lastNameController.clear();
                        emailController.clear();
                        firstNameController.clear();
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomDialogSEE(
                              title: "Create User",
                              lastNameController: lastNameController,
                              emailController: emailController,
                              firstNameController: firstNameController,
                              passwordController: passwordController,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSize.s10),
            Column(
              children: [
                Container(
                  height: AppSize.s30,
                  margin: EdgeInsets.symmetric(horizontal: 25),
                  decoration: BoxDecoration(
                    color: ColorManager.fmediumgrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(left: AppPadding.p80),
                            child: Text(
                              AppString.srNo,
                              style: TableHeading.customTextStyle(context),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(left: AppPadding.p60),
                            child: Text(
                              AppString.userId,
                              style: TableHeading.customTextStyle(context),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(left: AppPadding.p20),
                            child: Text(
                              AppString.fname,
                              style: TableHeading.customTextStyle(context),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(right: AppPadding.p40),
                            child: Text(
                              AppString.lname,
                              textAlign: TextAlign.start,
                              style: TableHeading.customTextStyle(context),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            AppString.role,
                            style: TableHeading.customTextStyle(context),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(left: AppPadding.p20),
                            child: Text(
                              AppString.email,
                              textAlign: TextAlign.start,
                              style: TableHeading.customTextStyle(context),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                              padding: const EdgeInsets.only(left: AppPadding.p40),
                              child: Text(
                                AppString.actions,
                                textAlign: TextAlign.start,
                                style: TableHeading.customTextStyle(context),
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSize.s10),
              ],
            ),
            Expanded(
              child: StreamBuilder<List<UserModal>>(
                stream: _companyUsersList.stream,
                builder: (BuildContext context, snapshot) {
                  getUser(context, '').then((data) {
                    _companyUsersList.add(data);
                  }).catchError((error) {});
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                    );
                  }
                  if (snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        ErrorMessageString.noUser,
                        style: AllNoDataAvailable.customTextStyle(context),
                      ),
                    );
                  }
                  if (snapshot.hasData) {
                    List<UserModal> sortedData = snapshot.data!;
                    sortedData.sort((a, b) => b.userId.compareTo(a.userId));
                    int totalItems = sortedData.length;
                    int totalPages = (totalItems / itemsPerPage).ceil();
                    if (currentPage > totalPages && totalPages > 0) {
                      currentPage = totalPages;
                    }
                    List<UserModal> paginatedData = sortedData
                        .skip((currentPage - 1) * itemsPerPage)
                        .take(itemsPerPage)
                        .toList();
                    _latestUsers = snapshot.data!;
                    _latestTotalPages = totalPages;
                    return ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: paginatedData.length,
                            itemBuilder: (context, index) {
                              int serialNumber =
                                  index + 1 + (currentPage - 1) * itemsPerPage;
                              String formattedSerialNumber =
                              serialNumber.toString().padLeft(2, '0');
                              UserModal user = paginatedData[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: AppPadding.p30),
                                    decoration: BoxDecoration(
                                      color: ColorManager.white,
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 1,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.5),
                                          offset: Offset(-4, 0),
                                        ),
                                      ],
                                    ),
                                    height: AppSize.s65,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              width: 80,
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: user.isActive
                                                    ? ColorManager.greenbg
                                                    : ColorManager.redbgd,
                                              ),
                                              child: Center(
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 4,
                                                      backgroundColor: user.isActive
                                                          ? ColorManager.greenDark
                                                          : ColorManager.redd,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      user.isActive
                                                          ? "Active"
                                                          : "Inactive",
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w600,
                                                        color: user.isActive
                                                            ? ColorManager.greenDark
                                                            : ColorManager.redd,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                          children: [
                                            const SizedBox(width: 10),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                formattedSerialNumber,
                                                style: TableSubHeading
                                                    .customTextStyle(context),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                user.userId.toString(),
                                                textAlign: TextAlign.center,
                                                style: TableSubHeading
                                                    .customTextStyle(context),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                user.firstName,
                                                textAlign: TextAlign.center,
                                                style: TableSubHeading
                                                    .customTextStyle(context),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: AppPadding.p20),
                                                child: Text(
                                                  user.lastName,
                                                  textAlign: TextAlign.center,
                                                  style: TableSubHeading
                                                      .customTextStyle(context),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: AppPadding.p50),
                                                child: Text(
                                                  user.department,
                                                  textAlign: TextAlign.center,
                                                  style: TableSubHeading
                                                      .customTextStyle(context),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: AppPadding.p100),
                                                child: Text(
                                                  user.email,
                                                  textAlign: TextAlign.start,
                                                  style: TableSubHeading
                                                      .customTextStyle(context),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  /// Edit button
                                                  InkWell(
                                                    child: Container(
                                                      height:
                                                      MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                          30,
                                                      width:
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                          25,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                        border: Border.all(
                                                            color: ColorManager
                                                                .bluebottom),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          "Edit",
                                                          style: TextStyle(
                                                              fontSize:
                                                              FontSize.s12,
                                                              fontWeight:
                                                              FontWeight.w500,
                                                              color: ColorManager
                                                                  .mediumgrey),
                                                        ),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder:
                                                            (BuildContext context) {
                                                          return FutureBuilder<
                                                              UserModalPrefill>(
                                                            future: getUserPrefill(
                                                                context,
                                                                user.userId),
                                                            builder: (context,
                                                                snapshotPrefill) {
                                                              if (snapshotPrefill
                                                                  .connectionState ==
                                                                  ConnectionState
                                                                      .waiting) {
                                                                return Center(
                                                                  child:
                                                                  CircularProgressIndicator(
                                                                      color: ColorManager
                                                                          .blueprime),
                                                                );
                                                              }
                                                              firstNameController =
                                                                  TextEditingController(
                                                                      text: snapshotPrefill
                                                                          .data!
                                                                          .firstName ??
                                                                          " ");
                                                              lastNameController =
                                                                  TextEditingController(
                                                                      text: snapshotPrefill
                                                                          .data!
                                                                          .lastName ??
                                                                          "");
                                                              emailController =
                                                                  TextEditingController(
                                                                      text: snapshotPrefill
                                                                          .data!
                                                                          .email ??
                                                                          " ");
                                                              companyIdController =
                                                                  TextEditingController(
                                                                      text: snapshotPrefill
                                                                          .data!
                                                                          .companyId
                                                                          .toString() ??
                                                                          "0");
                                                              return EditUserPopUp(
                                                                title:
                                                                "Edit User ",
                                                                deptName:
                                                                user.role,
                                                                userId:
                                                                user.userId,
                                                                firstname:
                                                                user.firstName,
                                                                lastname:
                                                                user.lastName,
                                                                email: user.email,
                                                                departmentId:
                                                                snapshotPrefill
                                                                    .data!
                                                                    .deptId,
                                                                department:
                                                                snapshotPrefill
                                                                    .data!
                                                                    .department,
                                                              );
                                                            },
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                  SizedBox(width: AppSize.s10),

                                                  /// Delete button
                                                  userLogin != user.email
                                                      ? InkWell(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            StatefulBuilder(
                                                              builder: (BuildContext
                                                              context,
                                                                  void Function(
                                                                      void
                                                                      Function())
                                                                  setState) {
                                                                return DeletePopup(
                                                                  title:
                                                                  "Delete User",
                                                                  loadingDuration:
                                                                  _isLoading,
                                                                  onCancel: () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  // ✅ FIXED: Recalculate totalPages after deletion
                                                                  // and clamp currentPage so it never shows an empty page
                                                                  onDelete: () async {
                                                                    setState(() {
                                                                          _isLoading = true;
                                                                        });
                                                                    try {
                                                                      await deleteUser(context, user.userId);

                                                                      final data = await getUser(context, '');

                                                                      // Recalculate total pages with updated list
                                                                      int newTotalPages = (data.length / itemsPerPage).ceil();

                                                                      // Clamp currentPage to valid range
                                                                      // so deleted last-page items shift view to last valid page
                                                                      this.setState(
                                                                              () {
                                                                            if (currentPage > newTotalPages && newTotalPages > 0) {
                                                                              currentPage = newTotalPages;
                                                                            }
                                                                          });

                                                                      _companyUsersList.add(data);

                                                                      Navigator.pop(context);
                                                                      showDialog(context: context, builder: (context) => DeleteSuccessPopup(),
                                                                      );
                                                                    } catch (
                                                                    error) {
                                                                      print('Delete error: $error');
                                                                    } finally {
                                                                      setState(() {
                                                                            _isLoading = false;
                                                                          });
                                                                    }
                                                                  },
                                                                );
                                                              },
                                                            ),
                                                      );
                                                    },
                                                    child: Container(
                                                      height: MediaQuery.of(context).size.height / 30,
                                                      width: MediaQuery.of(context).size.width / 25,
                                                      decoration:
                                                      BoxDecoration(borderRadius: BorderRadius.circular(10),
                                                        border: Border.all(color: ColorManager.bluebottom),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          AppString.delete,
                                                          style: TextStyle(fontSize: FontSize.s12,
                                                              fontWeight: FontWeight.w500,
                                                              color: ColorManager.mediumgrey),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                      : SizedBox(
                                                    height: MediaQuery.of(
                                                        context).size.height / 30,
                                                    width: MediaQuery.of(context).size.width / 25,
                                                  ),

                                                  SizedBox(width: AppSize.s10),

                                                  /// Toggle Active/Inactive button
                                                  InkWell(
                                                    onTap: () async {
                                                      bool newStatus =
                                                      !user.isActive;
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                        dialogContext) {
                                                          return ConfirmationPopup(
                                                            title:
                                                            "Change Status",
                                                            containerText: user
                                                                .isActive
                                                                ? "Do you want to make this user Inactive?"
                                                                : "Do you want to make this user Active?",
                                                            onCancel: () {
                                                              Navigator.pop(
                                                                  dialogContext);
                                                            },
                                                            onConfirm: () async {
                                                              try {
                                                                final response =
                                                                await updateUserActivePatch(
                                                                  context,
                                                                  user.userId,
                                                                  newStatus,
                                                                );
                                                                if (response
                                                                    .success) {
                                                                  final updatedUsers =
                                                                  await getUser(context, '');
                                                                  _companyUsersList
                                                                      .add(
                                                                      updatedUsers);
                                                                }
                                                              } catch (e) {
                                                                print(
                                                                    "Status update error: $e");
                                                              } finally {
                                                                Navigator.pop(
                                                                    dialogContext);
                                                              }
                                                            },
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Icon(
                                                      Icons.refresh,
                                                      size: 18,
                                                      color:
                                                      ColorManager.mediumgrey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                  }
                  return Scaffold();
                },
              ),
            )
          ],
        ),
                ),
              ),
            ),
          );
        }),            // LayoutBuilder
            ),         // Expanded
            if (_latestUsers.isNotEmpty)
              PaginationControlsWidget(
                currentPage: currentPage,
                items: _latestUsers,
                itemsPerPage: itemsPerPage,
                onPreviousPagePressed: () {
                  setState(() {
                    currentPage = currentPage > 1 ? currentPage - 1 : 1;
                  });
                },
                onPageNumberPressed: (pageNumber) {
                  setState(() {
                    currentPage = pageNumber;
                  });
                },
                onNextPagePressed: () {
                  setState(() {
                    currentPage = currentPage < _latestTotalPages
                        ? currentPage + 1
                        : _latestTotalPages;
                  });
                },
              ),
          ],
        ),            // outer Column
      ),              // Padding
    );
  }
}





///see all screen using provider working code
// class SeeAllScreen extends StatelessWidget {
//   final int itemsPerPage = 10;
//   String? selectedDeptName;
//   int? selectedDeptId;
//
//   @override
//   Widget build(BuildContext context) {
//     Future.microtask(() =>
//         Provider.of<SeeAllProvider>(context, listen: false).fetchUser(context));
//     // final seeAllProvider = Provider.of<SeeAllProvider>(context);
//
//     // final userCreationProvider = context.watch<UserCreationProvider>();
//     final paginationProvider = context.watch<SeeAllPaginationProvider>();
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: EdgeInsets.symmetric(
//             horizontal: MediaQuery.of(context).size.width / 24),
//         child: Column(
//           children: [
//             /// working
//             Padding(
//               padding: const EdgeInsets.only(right: AppPadding.p30),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   // Container(
//                   //   height: AppSize.s30,
//                   //   width: AppSize.s150,
//                   //   child: CustomIconButtonProvider(
//                   //     icon: Icons.add,
//                   //     text: AppString.createUser,
//                   //     onPressed: () async {
//                   //       final provider = Provider.of<UserCreationProvider>(
//                   //           context,
//                   //           listen: false);
//                   //       provider.clearForm();
//                   //       showDialog(
//                   //         context: context,
//                   //         builder: (BuildContext context) {
//                   //           return CustomDialoghSEE(
//                   //             title: AppString.createUser,
//                   //             firstNameController: provider.firstNameController,
//                   //             lastNameController: provider.lastNameController,
//                   //             emailController: provider.emailController,
//                   //             passwordController: provider.passwordController,
//                   //           );
//                   //         },
//                   //       );
//                   //     },
//                   //   ),
//                   // ),
//
//                   ///
//                   Container(
//                     height: 30,
//                     width: 150,
//                     child: CustomIconButtonProvider(
//                       icon: Icons.add,
//                       text: "Create User",
//                       onPressed: () async {
//                         final provider = Provider.of<UserCreationProvider>(context, listen: false);
//                         provider.clearForm();
//
//                         // Reset dropdown values before showing the dialog
//                         selectedDeptName = null;
//                         selectedDeptId = null;
//
//                         showDialog(
//                           context: context,
//                           builder: (BuildContext context) {
//                             return CustomDialoghSEE(
//                               title: "Create User",
//                               firstNameController: provider.firstNameController,
//                               lastNameController: provider.lastNameController,
//                               emailController: provider.emailController,
//                               passwordController: provider.passwordController,
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ),
//
//                   ///
//                   // Container(
//                   //   height: 30,
//                   //   width: 150,
//                   //   child: CustomIconButtonProvider(
//                   //     icon: Icons.add,
//                   //     text: "Create User",
//                   //     onPressed: () async {
//                   //       final provider = Provider.of<UserCreationProvider>(
//                   //           context,
//                   //           listen: false);
//                   //       provider.clearForm();
//                   //       showDialog(
//                   //         context: context,
//                   //         builder: (BuildContext context) {
//                   //           return CustomDialoghSEE(
//                   //             title: "Create User",
//                   //             firstNameController: provider.firstNameController,
//                   //             lastNameController: provider.lastNameController,
//                   //             emailController: provider.emailController,
//                   //             passwordController: provider.passwordController,
//                   //           );
//                   //         },
//                   //       );
//                   //     },
//                   //   ),
//                   // ),
//                 ],
//               ),
//             ),
//
//             ///
//             SizedBox(height: 10),
//             Column(
//               children: [
//                 Container(
//                   height: AppSize.s30,
//                   margin: EdgeInsets.symmetric(horizontal: 30),
//                   decoration: BoxDecoration(
//                     color: ColorManager.fmediumgrey,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.2),
//                         blurRadius: 4,
//                         spreadRadius: 1,
//                         offset: Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 1),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         Expanded(
//                           flex: 2,
//                           child: Padding(
//                             padding:
//                                 const EdgeInsets.only(left: AppPadding.p90),
//                             child: Text(
//                               AppString.srNo,
//                               textAlign: TextAlign.start,
//                               style: TableHeading.customTextStyle(context),
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: Padding(
//                             padding:
//                                 const EdgeInsets.only(left: AppPadding.p40),
//                             child: Text(
//                               AppString.userId,
//                               style: TableHeading.customTextStyle(context),
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: Text(
//                             AppString.fname,
//                             textAlign: TextAlign.start,
//                             style: TableHeading.customTextStyle(context),
//                           ),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: Text(
//                             AppString.lname,
//                             textAlign: TextAlign.start,
//                             style: TableHeading.customTextStyle(context),
//                           ),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: Padding(
//                             padding: const EdgeInsets.only(left: 20),
//                             child: Text(
//                               AppString.role,
//                               textAlign: TextAlign.start,
//                               style: TableHeading.customTextStyle(context),
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: Text(
//                             AppString.email,
//                             textAlign: TextAlign.center,
//                             style: TableHeading.customTextStyle(context),
//                           ),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: Text(
//                             AppString.actions,
//                             textAlign: TextAlign.center,
//                             style: TableHeading.customTextStyle(context),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: AppSize.s10),
//               ],
//             ),
//
//             ///stream builder used
//             Expanded(
//               child: Consumer<SeeAllProvider>(
//                 builder: (context, seeAllProviderState, child) {
//                   return StreamBuilder<List<UserModal>>(
//                     stream: seeAllProviderState.userStream,
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return Center(child: CircularProgressIndicator());
//                       }
//                       if (snapshot.hasError) {
//                         return Center(child: Text('Error: ${snapshot.error}'));
//                       }
//                       if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                         return Center(child: Text(AppString.noavailabledata));
//                       }
//
//                       List<UserModal> sortedData = snapshot.data!;
//                       sortedData.sort((a, b) => b.userId.compareTo(a.userId));
//
//                       /// Update PaginationProvider's items
//                       final paginationProvider =
//                           Provider.of<SeeAllPaginationProvider>(context,
//                               listen: false);
//                       Future.microtask(() {
//                         paginationProvider.updateItems(sortedData);
//                       });
//
//                       List<UserModal> paginatedData =
//                           paginationProvider.currentPageItems;
//
//                       return Column(children: [
//                         Expanded(
//                             child: ListView.builder(
//                                 itemCount: paginatedData.length,
//                                 itemBuilder: (context, index) {
//                                   int globalSerialNumber =
//                                       (paginationProvider.currentPage - 1) *
//                                               paginationProvider.itemsPerPage +
//                                           index +
//                                           1;
//
//                                   String formattedSerialNumber =
//                                       globalSerialNumber
//                                           .toString()
//                                           .padLeft(2, '0');
//
//                                   UserModal user = paginatedData[index];
//
//                                   // Fetch logged-in user's email
//                                   // String? userLogin = Provider.of<AuthProvider>(context, listen: false).userEmail;
//
//                                   return Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         SizedBox(height: 5),
//                                         Container(
//                                           margin: EdgeInsets.symmetric(
//                                               horizontal: 30),
//                                           decoration: BoxDecoration(
//                                             color: Colors.white,
//                                             borderRadius:
//                                                 BorderRadius.circular(4),
//                                             boxShadow: [
//                                               ///
//                                               BoxShadow(
//                                                 color: Colors.grey
//                                                     .withOpacity(0.5),
//                                                 spreadRadius: 1,
//                                                 blurRadius: 4,
//                                                 offset: Offset(0, 2),
//                                               ),
//                                               BoxShadow(
//                                                 color: Colors.blue
//                                                     .withOpacity(0.5),
//                                                 offset: Offset(-4, 0),
//                                               ),
//                                             ],
//                                           ),
//                                           height: 56,
//                                           child: Padding(
//                                               padding: EdgeInsets.symmetric(
//                                                   horizontal: 10),
//                                               child: Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment
//                                                           .spaceEvenly,
//                                                   children: [
//                                                     Expanded(
//                                                         flex: 1,
//                                                         child: Text(
//                                                             formattedSerialNumber,
//                                                             style: TableSubHeading
//                                                                 .customTextStyle(
//                                                                     context),
//                                                             textAlign: TextAlign
//                                                                 .center)),
//                                                     Expanded(
//                                                         flex: 1,
//                                                         child: Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .only(
//                                                                   left: 40),
//                                                           child: Text(
//                                                             user.userId
//                                                                 .toString(),
//                                                             textAlign:
//                                                                 TextAlign.start,
//                                                             style: TableSubHeading
//                                                                 .customTextStyle(
//                                                                     context),
//                                                           ),
//                                                         )),
//                                                     Expanded(
//                                                         flex: 1,
//                                                         child: Text(
//                                                           user.firstName,
//                                                           textAlign:
//                                                               TextAlign.start,
//                                                           style: TableSubHeading
//                                                               .customTextStyle(
//                                                                   context),
//                                                         )),
//                                                     Expanded(
//                                                         flex: 1,
//                                                         child: Text(
//                                                           user.lastName,
//                                                           textAlign:
//                                                               TextAlign.start,
//                                                           style: TableSubHeading
//                                                               .customTextStyle(
//                                                                   context),
//                                                         )),
//                                                     Expanded(
//                                                         flex: 1,
//                                                         child: Text(
//                                                           user.role,
//                                                           textAlign:
//                                                               TextAlign.start,
//                                                           style: TableSubHeading
//                                                               .customTextStyle(
//                                                                   context),
//                                                         )),
//                                                     Expanded(
//                                                         flex: 1,
//                                                         child: Text(
//                                                           user.email,
//                                                           textAlign:
//                                                               TextAlign.start,
//                                                           style: TableSubHeading
//                                                               .customTextStyle(
//                                                                   context),
//                                                         )),
//                                                     SizedBox(
//                                                         width: AppSize.s10),
//                                                     InkWell(
//                                                       child: Container(
//                                                         height: MediaQuery.of(
//                                                                     context)
//                                                                 .size
//                                                                 .height /
//                                                             30,
//                                                         width: MediaQuery.of(
//                                                                     context)
//                                                                 .size
//                                                                 .width /
//                                                             25,
//                                                         decoration:
//                                                             BoxDecoration(
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(10),
//                                                           border: Border.all(
//                                                               color: ColorManager
//                                                                   .bluebottom),
//                                                         ),
//                                                         child: Center(
//                                                           child: Text(
//                                                             AppString.edit,
//                                                             style: TextStyle(
//                                                               fontSize:
//                                                                   FontSize.s12,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .w500,
//                                                               color: ColorManager
//                                                                   .mediumgrey,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       onTap: () async {
//                                                         final editUserProvider =
//                                                             Provider.of<
//                                                                     EditUserProvider>(
//                                                                 context,
//                                                                 listen: false);
//
//                                                         await editUserProvider
//                                                             .fetchPrefillData(
//                                                                 context,
//                                                                 user.userId);
//
//                                                         if (editUserProvider
//                                                                 .prefillData !=
//                                                             null) {
//                                                           showDialog(
//                                                             context: context,
//                                                             builder:
//                                                                 (BuildContext
//                                                                     context) {
//                                                               return EditUserPopUp(
//                                                                 title: AppString
//                                                                     .editProfile,
//                                                                 deptName: AppString
//                                                                     .selectDept,
//                                                                 userId:
//                                                                     user.userId,
//                                                                 firstname:
//                                                                     editUserProvider
//                                                                         .firstNameController
//                                                                         .text,
//                                                                 lastname:
//                                                                     editUserProvider
//                                                                         .lastNameController
//                                                                         .text,
//                                                                 email: editUserProvider
//                                                                     .emailController
//                                                                     .text,
//                                                                 departmentId:
//                                                                     editUserProvider
//                                                                         .prefillData!
//                                                                         .deptId,
//                                                                 department: editUserProvider
//                                                                     .prefillData!
//                                                                     .department,
//                                                               );
//                                                             },
//                                                           );
//                                                         } else {
//                                                           print(
//                                                               "Error: Prefill data not found");
//                                                         }
//                                                       },
//                                                     ),
//
//                                                     SizedBox(
//                                                         width: AppSize.s10),
//
//                                                     ///
//                                                     if (seeAllProviderState.userLogin != user.email)
//                                                       InkWell(
//                                                         child: Container(
//                                                           height: MediaQuery.of(
//                                                                       context)
//                                                                   .size
//                                                                   .height /
//                                                               30,
//                                                           width: MediaQuery.of(
//                                                                       context)
//                                                                   .size
//                                                                   .width /
//                                                               25,
//                                                           decoration:
//                                                               BoxDecoration(
//                                                             borderRadius:
//                                                                 BorderRadius
//                                                                     .circular(
//                                                                         10),
//                                                             border: Border.all(
//                                                                 color: ColorManager
//                                                                     .bluebottom),
//                                                           ),
//                                                           child: Center(
//                                                             child: Text(
//                                                               AppString.delete,
//                                                               style: TextStyle(
//                                                                 fontSize:
//                                                                     FontSize
//                                                                         .s12,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w500,
//                                                                 color: ColorManager
//                                                                     .mediumgrey,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         onTap: () async {
//                                                           bool? isConfirmed =
//                                                               await showDialog<
//                                                                   bool>(
//                                                             context: context,
//                                                             builder:
//                                                                 (BuildContext
//                                                                     context) {
//                                                               return DeleteConfirmationPopup(
//                                                                 title: AppString
//                                                                     .deleteUser,
//                                                                 onConfirmed:
//                                                                     () async {
//                                                                   await seeAllProviderState
//                                                                       .deleteUser(
//                                                                     context,
//                                                                     user.userId
//                                                                         .toString(),
//                                                                   );
//
//                                                                   await seeAllProviderState
//                                                                       .fetchUser(
//                                                                           context);
//
//                                                                   Navigator.of(
//                                                                           context)
//                                                                       .pop(
//                                                                           true);
//                                                                   showDialog(
//                                                                     context:
//                                                                         context,
//                                                                     builder:
//                                                                         (BuildContext
//                                                                             context) {
//                                                                       return SuccessUserPopup(
//                                                                         message:
//                                                                             AppString.userDeletedsucc,
//                                                                       );
//                                                                     },
//                                                                   );
//                                                                   Future.delayed(
//                                                                       Duration(
//                                                                           milliseconds:
//                                                                               100),
//                                                                       () {
//                                                                     Navigator.of(
//                                                                             context)
//                                                                         .pop();
//                                                                   });
//                                                                 },
//                                                               );
//                                                             },
//                                                           );
//
//                                                           if (isConfirmed ==
//                                                               true) {
//                                                             print(
//                                                                 "User deletion confirmed and completed.");
//                                                           }
//                                                         },
//                                                       )
//                                                     else
//                                                       SizedBox(
//                                                         height: MediaQuery.of(
//                                                             context)
//                                                             .size
//                                                             .height /
//                                                             30,
//                                                         width: MediaQuery.of(
//                                                             context)
//                                                             .size
//                                                             .width /
//                                                             25,
//                                                       ),
//
//                                                     SizedBox(
//                                                         width: AppSize.s10),
//                                                   ])),
//                                         ),
//                                       ]);
//                                 }))
//                       ]);
//                     },
//                   );
//                 },
//               ),
//             ),
// ///
//             // InkWell(
//             //   child: Container(
//             //     height: MediaQuery.of(
//             //                 context)
//             //             .size
//             //             .height /
//             //         30,
//             //     width: MediaQuery.of(
//             //                 context)
//             //             .size
//             //             .width /
//             //         25,
//             //     decoration:
//             //         BoxDecoration(
//             //       borderRadius:
//             //           BorderRadius
//             //               .circular(10),
//             //       border: Border.all(
//             //           color: ColorManager
//             //               .bluebottom),
//             //     ),
//             //     child: Center(
//             //       child: Text(
//             //         AppString.delete,
//             //         style: TextStyle(
//             //           fontSize:
//             //               FontSize.s12,
//             //           fontWeight:
//             //               FontWeight
//             //                   .w500,
//             //           color: ColorManager
//             //               .mediumgrey,
//             //         ),
//             //       ),
//             //     ),
//             //   ),
//             //   onTap: () async {
//             //     bool? isConfirmed =
//             //         await showDialog<
//             //             bool>(
//             //       context: context,
//             //       builder: (BuildContext
//             //           context) {
//             //         return DeleteConfirmationPopup(
//             //           title:
//             //               AppString.deleteUser,
//             //           onConfirmed:
//             //               () async {
//             //
//             //             await seeAllProviderState
//             //                 .deleteUser(
//             //                     context,
//             //                     user.userId
//             //                         .toString());
//             //
//             //             await seeAllProviderState
//             //                 .fetchUser(
//             //                     context);
//             //
//             //
//             //             Navigator.of(
//             //                     context)
//             //                 .pop(
//             //                     true);
//             //             showDialog(
//             //               context:
//             //                   context,
//             //               builder:
//             //                   (BuildContext
//             //                       context) {
//             //                 return SuccessUserPopup(
//             //                     message: AppString.userDeletedsucc);
//             //                 /// Close the popup after 0.5 seconds
//             //
//             //               },
//             //             );
//             //             Future.delayed(Duration(milliseconds: 100), () {
//             //               Navigator.of(context).pop();
//             //             });
//             //           },
//             //         );
//             //       },
//             //     );
//             //
//             //     if (isConfirmed ==
//             //         true) {
//             //       print("User deletion confirmed and completed.");
//             //     }
//             //   },
//             // ),
//             /// future builder used
//             // Expanded(
//             //   child: Consumer<SeeAllProvider>(
//             //     builder: (context, seeAllProviderState, child) {
//             //       return FutureBuilder<List<UserModal>>(
//             //         future: seeAllProviderState.fetchUser(context), // Use the updated fetchUser method
//             //         builder: (context, snapshot) {
//             //           if (snapshot.connectionState == ConnectionState.waiting) {
//             //             return Center(child: CircularProgressIndicator());
//             //           }
//             //
//             //           if (snapshot.hasError) {
//             //             print("Error: ${snapshot.error}"); // Debugging line to check if there's an error
//             //             return Center(child: Text('Error: ${snapshot.error}'));
//             //           }
//             //
//             //           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             //             print("No data available"); // Debugging line to check if data is empty
//             //             return Center(child: Text(AppString.noavailabledata));
//             //           }
//             //
//             //           List<UserModal> sortedData = snapshot.data!;
//             //           sortedData.sort((a, b) => b.userId.compareTo(a.userId));
//             //
//             //           // Update PaginationProvider's items
//             //           final paginationProvider = Provider.of<SeeAllPaginationProvider>(context, listen: false);
//             //           Future.microtask(() {
//             //             paginationProvider.updateItems(sortedData);
//             //           });
//             //
//             //           List<UserModal> paginatedData = paginationProvider.currentPageItems;
//             //
//             //           return Column(
//             //             children: [
//             //               Expanded(
//             //                 child: ListView.builder(
//             //                   itemCount: paginatedData.length,
//             //                   itemBuilder: (context, index) {
//             //                     int globalSerialNumber = (paginationProvider.currentPage - 1) * paginationProvider.itemsPerPage + index + 1;
//             //                     String formattedSerialNumber = globalSerialNumber.toString().padLeft(2, '0');
//             //                     UserModal user = paginatedData[index];
//             //
//             //                     return Column(
//             //                       crossAxisAlignment: CrossAxisAlignment.start,
//             //                       children: [
//             //                         SizedBox(height: 5),
//             //                         Container(
//             //                           margin: EdgeInsets.symmetric(horizontal: 30),
//             //                           decoration: BoxDecoration(
//             //                             color: Colors.white,
//             //                             borderRadius: BorderRadius.circular(4),
//             //                             boxShadow: [
//             //                               BoxShadow(
//             //                                 color: Colors.grey.withOpacity(0.5),
//             //                                 spreadRadius: 1,
//             //                                 blurRadius: 4,
//             //                                 offset: Offset(0, 2),
//             //                               ),
//             //                               BoxShadow(
//             //                                 color: Colors.blue.withOpacity(0.5),
//             //                                 offset: Offset(-4, 0),
//             //                               ),
//             //                             ],
//             //                           ),
//             //                           height: 56,
//             //                           child: Padding(
//             //                             padding: EdgeInsets.symmetric(horizontal: 10),
//             //                             child: Row(
//             //                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             //                               children: [
//             //                                 Expanded(
//             //                                   flex: 1,
//             //                                   child: Text(
//             //                                     formattedSerialNumber,
//             //                                     style: TableSubHeading.customTextStyle(context),
//             //                                     textAlign: TextAlign.center,
//             //                                   ),
//             //                                 ),
//             //                                 Expanded(
//             //                                   flex: 1,
//             //                                   child: Padding(
//             //                                     padding: const EdgeInsets.only(left: 40),
//             //                                     child: Text(
//             //                                       user.userId.toString(),
//             //                                       textAlign: TextAlign.start,
//             //                                       style: TableSubHeading.customTextStyle(context),
//             //                                     ),
//             //                                   ),
//             //                                 ),
//             //                                 Expanded(
//             //                                   flex: 1,
//             //                                   child: Text(
//             //                                     user.firstName,
//             //                                     textAlign: TextAlign.start,
//             //                                     style: TableSubHeading.customTextStyle(context),
//             //                                   ),
//             //                                 ),
//             //                                 Expanded(
//             //                                   flex: 1,
//             //                                   child: Text(
//             //                                     user.lastName,
//             //                                     textAlign: TextAlign.start,
//             //                                     style: TableSubHeading.customTextStyle(context),
//             //                                   ),
//             //                                 ),
//             //                                 Expanded(
//             //                                   flex: 1,
//             //                                   child: Text(
//             //                                     user.role,
//             //                                     textAlign: TextAlign.start,
//             //                                     style: TableSubHeading.customTextStyle(context),
//             //                                   ),
//             //                                 ),
//             //                                 Expanded(
//             //                                   flex: 1,
//             //                                   child: Text(
//             //                                     user.email,
//             //                                     textAlign: TextAlign.start,
//             //                                     style: TableSubHeading.customTextStyle(context),
//             //                                   ),
//             //                                 ),
//             //                                 SizedBox(width: AppSize.s10),
//             //                                 InkWell(
//             //                                   child: Container(
//             //                                     height: MediaQuery.of(context).size.height / 30,
//             //                                     width: MediaQuery.of(context).size.width / 25,
//             //                                     decoration: BoxDecoration(
//             //                                       borderRadius: BorderRadius.circular(10),
//             //                                       border: Border.all(color: ColorManager.bluebottom),
//             //                                     ),
//             //                                     child: Center(
//             //                                       child: Text(
//             //                                         AppString.edit,
//             //                                         style: TextStyle(
//             //                                           fontSize: FontSize.s12,
//             //                                           fontWeight: FontWeight.w500,
//             //                                           color: ColorManager.mediumgrey,
//             //                                         ),
//             //                                       ),
//             //                                     ),
//             //                                   ),
//             //                                   onTap: () async {
//             //                                     final editUserProvider = Provider.of<EditUserProvider>(context, listen: false);
//             //                                     await editUserProvider.fetchPrefillData(context, user.userId);
//             //                                     if (editUserProvider.prefillData != null) {
//             //                                       showDialog(
//             //                                         context: context,
//             //                                         builder: (BuildContext context) {
//             //                                           return EditUserPopUp(
//             //                                             title: AppString.editProfile,
//             //                                             deptName: AppString.selectDept,
//             //                                             userId: user.userId,
//             //                                             firstname: editUserProvider.firstNameController.text,
//             //                                             lastname: editUserProvider.lastNameController.text,
//             //                                             email: editUserProvider.emailController.text,
//             //                                             departmentId: editUserProvider.prefillData!.deptId,
//             //                                             department: editUserProvider.prefillData!.department,
//             //                                           );
//             //                                         },
//             //                                       );
//             //                                     } else {
//             //                                       print("Error: Prefill data not found");
//             //                                     }
//             //                                   },
//             //                                 ),
//             //                                 SizedBox(width: AppSize.s10),
//             //                                 InkWell(
//             //                                   child: Container(
//             //                                     height: MediaQuery.of(context).size.height / 30,
//             //                                     width: MediaQuery.of(context).size.width / 25,
//             //                                     decoration: BoxDecoration(
//             //                                       borderRadius: BorderRadius.circular(10),
//             //                                       border: Border.all(color: ColorManager.bluebottom),
//             //                                     ),
//             //                                     child: Center(
//             //                                       child: Text(
//             //                                         AppString.delete,
//             //                                         style: TextStyle(
//             //                                           fontSize: FontSize.s12,
//             //                                           fontWeight: FontWeight.w500,
//             //                                           color: ColorManager.mediumgrey,
//             //                                         ),
//             //                                       ),
//             //                                     ),
//             //                                   ),
//             //                                   onTap: () async {
//             //                                     bool? isConfirmed = await showDialog<bool>(
//             //                                       context: context,
//             //                                       builder: (BuildContext context) {
//             //                                         return DeleteConfirmationPopup(
//             //                                           title: AppString.deleteUser,
//             //                                           onConfirmed: () async {
//             //                                             await seeAllProviderState.deleteUser(context, user.userId.toString());
//             //                                             await seeAllProviderState.fetchUser(context);
//             //                                             Navigator.of(context).pop(true);
//             //                                             showDialog(
//             //                                               context: context,
//             //                                               builder: (BuildContext context) {
//             //                                                 return SuccessUserPopup(message: AppString.userDeletedsucc);
//             //                                               },
//             //                                             );
//             //                                           },
//             //
//             //                                             // Navigator.of(context).pop(false);
//             //
//             //                                         );
//             //                                       },
//             //                                     );
//             //                                     if (isConfirmed != null && isConfirmed) {
//             //                                       print("User deleted");
//             //                                     } else {
//             //                                       print("User deletion cancelled");
//             //                                     }
//             //                                   },
//             //                                 ),
//             //                               ],
//             //                             ),
//             //                           ),
//             //                         ),
//             //                       ],
//             //                     );
//             //                   },
//             //                 ),
//             //               ),
//             //
//             //             ],
//             //           );
//             //         },
//             //       );
//             //     },
//             //   ),
//             // ),
//
//             ///Pagination
//             PaginationnControlsWidget()
//           ],
//         ),
//       ),
//     );
//   }
// }
