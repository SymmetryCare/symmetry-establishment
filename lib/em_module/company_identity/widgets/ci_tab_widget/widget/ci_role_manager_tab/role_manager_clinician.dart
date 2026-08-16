import 'dart:async';
import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/common_resources/common_theme_const.dart';
import 'package:prohealth/app/resources/theme_manager.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/ci_tab_widget/widget/ci_role_manager_tab/widgets/ci_role_container_constant.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../../../../app/resources/color.dart';
import '../../../../../../../../app/resources/establishment_resources/establishment_string_manager.dart';
import '../../../../../../../../app/resources/font_manager.dart';
import '../../../../../../../../app/services/api/managers/establishment_manager/role_manager.dart';
import '../../../../../../../../data/api_data/establishment_data/pay_rates/pay_rates_finance_data.dart';
import '../../../../../../../../data/api_data/establishment_data/role_manager/role_manager_data.dart';
import '../../../../../widgets/button_constant.dart';
import '../../../ci_corporate_compliance_doc/widgets/corporate_compliance_constants.dart';
import '../../../whitelabelling/success_popup.dart';

class RoleManagerClinician extends StatefulWidget {
  const RoleManagerClinician({super.key});

  @override
  State<RoleManagerClinician> createState() => _RoleManagerClinicianState();
}

class _RoleManagerClinicianState extends State<RoleManagerClinician> {
  List<bool> selectedContainers = List.generate(15, (_) => false);
  final StreamController<List<PayRateFinanceData>> _roleMDropDownController = StreamController<List<PayRateFinanceData>>();
  final StreamController<List<ModuleMetaData>> roleMetaDataClinicalController = StreamController<List<ModuleMetaData>>();
  final StreamController<List<RoleManagerDepartmentEmpType>> empTypeController = StreamController<List<RoleManagerDepartmentEmpType>>();

  void toggleSelection(int index) {
    setState(() {
      selectedContainers[index] = !selectedContainers[index];
    });
  }

  int DepartmentId = 1;
  int subEmpType = 0;
  bool isDeptSelected = false;
  String? selectedDept;
  String? selectedEmpType;

  @override
  void initState() {
    super.initState();
      // payRatesDataGet(context,1, 1, 10).then((data) {
    //   _roleMDropDownController.add(data);
    // }).catchError((error) {
    //   // Handle error
    // });
    roleMabagerMetaData(context).then((data) {
      roleMetaDataClinicalController.add(data);
    }).catchError((error) {
      // Handle error
    });
    roleManagerGetByDepartmentID(context, DepartmentId).then((data){
      empTypeController.add(data);
    }).catchError((error){});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: SingleChildScrollView(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: AppSize.s20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStringEM.pickDept,
                      style: AllPopupHeadings.customTextStyle(context),
                    ),
                    const SizedBox(height: 4),
                    // FutureBuilder<List<RoleManagerData>>(
                    //     future: roleManagerDataGet(context),
                    //     builder: (context,snapshot) {
                    //       if(snapshot.connectionState == ConnectionState.waiting){
                    //         return Shimmer.fromColors(
                    //             baseColor: Colors.grey[300]!,
                    //             highlightColor: Colors.grey[100]!,
                    //             child: Container(
                    //               width: AppSize.s350,
                    //               height: AppSize.s30,
                    //               decoration: BoxDecoration(color: ColorManager.faintGrey,borderRadius: BorderRadius.circular(10)),
                    //             )
                    //         );
                    //       }
                    //       if (snapshot.data!.isEmpty) {
                    //         return Center(
                    //           child: Text(
                    //            ErrorMessageString.noSDepartment,
                    //            // AppString.dataNotFound,
                    //             style: AllNoDataAvailable.customTextStyle(context),
                    //           ),
                    //         );
                    //       }
                    //       if(snapshot.hasData){
                    //         List dropDown = [];
                    //         int docType = 0;
                    //         List<DropdownMenuItem<String>> dropDownMenuItems = [];
                    //         for(var i in snapshot.data!){
                    //           dropDownMenuItems.add(
                    //             DropdownMenuItem<String>(
                    //               child: Text(i.deptName),
                    //               value: i.deptName,
                    //             ),
                    //           );
                    //         }
                    //         return CICCDropdown(
                    //             initialValue: selectedDept,
                    //             onChange: (val){
                    //               for(var a in snapshot.data!){
                    //                 if(a.deptName == val){
                    //                   docType = a.deptID;
                    //                   DepartmentId = docType;
                    //
                    //                 }
                    //               }
                    //               roleManagerGetByDepartmentID(context, DepartmentId).then((data){
                    //                 empTypeController.add(data);
                    //               }).catchError((error){});
                    //               setState(() {
                    //                 selectedDept = val;
                    //                 isDeptSelected = true;
                    //                 selectedEmpType = null;
                    //               });
                    //
                    //               print(":::${docType}");
                    //               print(":::<>${DepartmentId}");
                    //             },
                    //             items:dropDownMenuItems
                    //         );
                    //       }else{
                    //         return SizedBox();
                    //       }
                    //     }
                    // ),
                  ],
                ),
                SizedBox(width: MediaQuery.of(context).size.width / 18),
                if(isDeptSelected)
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStringEM.pickEmpType,
                      style: AllPopupHeadings.customTextStyle(context),
                    ),
                    SizedBox(height: AppSize.s4),
                    StreamBuilder<List<RoleManagerDepartmentEmpType>>(
                        stream: empTypeController.stream,
                        builder: (context,snapshot) {
                          if(snapshot.connectionState == ConnectionState.waiting){
                            return Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: AppSize.s350,
                                  height: AppSize.s30,
                                  decoration: BoxDecoration(color: ColorManager.faintGrey,borderRadius: BorderRadius.circular(10)),
                                )
                            );
                          }
                          if (snapshot.data!.isEmpty) {
                            return Center(
                              child: Text(
                                ErrorMessageString.noClinicianRole,
                                // AppString.dataNotFound,
                                style: AllNoDataAvailable.customTextStyle(context),
                              ),
                            );
                          }
                          if(snapshot.hasData){
                            List dropDown = [];
                            int docType = 0;
                            List<DropdownMenuItem<String>> dropDownMenuItems = [];
                            for(var i in snapshot.data!){
                              dropDownMenuItems.add(
                                DropdownMenuItem<String>(
                                  value: i.employeeType,
                                  child: Text(i.employeeType),
                                ),
                              );
                            }
                            return CICCDropdown(
                                initialValue: selectedEmpType,
                                onChange: (val){
                                  for(var a in snapshot.data!){
                                    if(a.employeeType == val){
                                      docType = a.DepartmentId;
                                      subEmpType = docType;
                                    }
                                  }
                                  setState(() {
                                    selectedEmpType = val;
                                  });
                                  print(":::${docType}");
                                  //print(":::<>${docSubTypeMetaId}");
                                },
                                items:dropDownMenuItems
                            );
                          }else{
                            return SizedBox(
                              height:AppSize.s1,
                              width: AppSize.s1,);
                          }
                        }
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: AppSize.s20),
            /// row 1
            StreamBuilder<List<ModuleMetaData>>(
                stream: roleMetaDataClinicalController.stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Container(
                          width: MediaQuery.of(context).size.width / 1,
                          child: Center(
                            child: Wrap(
                                children: List.generate(10, (index) {
                              return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 10),
                                  child: Container(
                                    height: MediaQuery.of(context).size.height /
                                        5.3,
                                    width:
                                        MediaQuery.of(context).size.width / 6.5,
                                    decoration: BoxDecoration(
                                      color: ColorManager.faintGrey,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(24)),
                                    ),
                                  ));
                            })),
                          ),
                        ),
                      ),
                    );
                  }
                  if (snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        ErrorMessageString.noModules,
                       // AppString.dataNotFound,
                        style:AllNoDataAvailable.customTextStyle(context),
                      ),
                    );
                  }
                  if (snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 1,
                        child: Center(
                          child: Wrap(
                            children: List.generate(snapshot.data!.length, (index) {
                              var metaModule = snapshot.data![index];
                              bool isSelected = selectedContainers[metaModule.appModuleMetaDataId] ?? false;

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                                child: InkWell(
                                  onTap: selectedDept != null && selectedEmpType != null
                                    ? () {
                                    toggleSelection(metaModule.appModuleMetaDataId);
                                  }
                                  : null,
                                  child: Stack(
                                    children: [
                                      CIRoleContainerConstant(
                                        metaModule.mainModule,
                                        // CachedNetworkImage(
                                        //   imageUrl: metaModule.iconUrl,
                                        //   placeholder: (context, url) => CircularProgressIndicator(),
                                        //   errorWidget: (context, url, error) => Icon(Icons.error),
                                        // ) as ImageProvider<Object>,
                                        //NetworkImage(metaModule.iconUrl),
                                        AssetImage('images/rehab.png'),
                                        borderColor: isSelected ? ColorManager.blueprime : ColorManager.white,
                                      ),
                                      if (isSelected)
                                        Positioned(
                                          top: 3,
                                          right: 5,
                                          child: Icon(
                                            Icons.check_circle,
                                            color: ColorManager.blueprime,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    );

                    // return Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 40),
                    //   child: Container(
                    //     width: MediaQuery.of(context).size.width / 1,
                    //     child: Center(
                    //       child: Wrap(
                    //           children:
                    //               List.generate(snapshot.data!.length, (index) {
                    //         var metaModule = snapshot.data![index];
                    //         return Padding(
                    //           padding: const EdgeInsets.symmetric(
                    //               horizontal: 40, vertical: 10),
                    //           child: InkWell(
                    //             onTap: () {
                    //               toggleSelection(metaModule.appModuleMetaDataId);
                    //             },
                    //             child: CIRoleContainerConstant(
                    //               metaModule.mainModule,
                    //               //metaModule.iconUrl.toString(),
                    //               AssetImage('images/rehab.png'),
                    //               borderColor: selectedContainers[metaModule.appModuleMetaDataId]
                    //                   ? ColorManager.blueprime
                    //                   : Colors.white,
                    //             ),
                    //           ),
                    //         );
                    //       })),
                    //     ),
                    //   ),
                    // );
                  } else {
                    return SizedBox();
                  }
                }),
            SizedBox(height: AppSize.s40),

            /// button
            Center(
              child: CustomElevatedButton(
                width: AppSize.s105,
                height: AppSize.s30,
                text: AppStringEM.save,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CCSuccessPopup();
                    },
                  );
                },
              ),
            ),
          ]),
    ));
  }
}

