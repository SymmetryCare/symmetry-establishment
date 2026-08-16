import 'dart:async';
import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/const_string.dart';
import 'package:prohealth/app/resources/theme_manager.dart';
import 'package:prohealth/app/services/api/managers/establishment_manager/role_manager.dart';
import 'package:prohealth/data/api_data/establishment_data/role_manager/role_manager_data.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/ci_tab_widget/widget/ci_role_manager_tab/widgets/ci_role_container_constant.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../../../../app/resources/color.dart';
import '../../../../../../../../app/resources/establishment_resources/establishment_string_manager.dart';
import '../../../../../../../../app/resources/font_manager.dart';
import '../../../../../../../../app/resources/value_manager.dart';
import '../../../../../../../../app/services/api/managers/establishment_manager/all_from_hr_manager.dart';
import '../../../../../../../../app/services/api/managers/establishment_manager/pay_rates_manager.dart';
import '../../../../../../../../data/api_data/establishment_data/all_from_hr/all_from_hr_data.dart';
import '../../../../../../../../data/api_data/establishment_data/pay_rates/pay_rates_finance_data.dart';
import '../../../../../widgets/button_constant.dart';

class RoleManagerSales extends StatefulWidget {
  const RoleManagerSales({super.key});

  @override
  State<RoleManagerSales> createState() => _RoleManagerSalesState();
}

class _RoleManagerSalesState extends State<RoleManagerSales> {
  List<bool> selectedContainers = List.generate(15, (_) => false);
  final StreamController<List<PayRateFinanceData>> _roleMDropDownController = StreamController<List<PayRateFinanceData>>();
  final StreamController<List<ModuleMetaData>> roleMetaDataSaleController =
  StreamController<List<ModuleMetaData>>();

  void toggleSelection(int index) {
    setState(() {
      selectedContainers[index] = !selectedContainers[index];
    });
  }
  String? selectedValue;
  @override
  void initState() {
    super.initState();
     // payRatesDataGet(context,1,1,10).then((data) {
    //   _roleMDropDownController.add(data);
    // }).catchError((error) {
    //   // Handle error
    // });
    roleMabagerMetaData(context).then((data) {
      roleMetaDataSaleController.add(data);
    }).catchError((error) {
      // Handle error
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
    child: SingleChildScrollView(
      child:
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: AppPadding.p220),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pick Employee Type',
                      style: TextStyle(
                        fontSize: FontSize.s10,
                        fontWeight: FontWeight.w700,
                        color: ColorManager.fmediumgrey,
                        decoration: TextDecoration.none,
                      ),),
                    SizedBox(height: AppSize.s4,),
                    FutureBuilder<List<HRClinical>>(
                        future: companyAllHrClinicApi(context),
                        builder: (context, snapshot) {
                          if(snapshot.connectionState == ConnectionState.waiting){
                            return Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: 300,
                                  height: 30,
                                  decoration: BoxDecoration( color: ColorManager.faintGrey,borderRadius: BorderRadius.circular(10)),
                                )
                            );
                          }
                          if(snapshot.hasData) {
                            List<String> dropDownList = [];
                            List<String> dropDownAbbreviation = [];
                            for (var i in snapshot.data!) {
                              dropDownList.add(i.empType!,);
                              dropDownAbbreviation.add(i.abbrivation!);
                            }
                            // for(var i in snapshot.data!){
                            //
                            // }
                            print("::::::${dropDownList}");
                            print("::::::${dropDownAbbreviation}");
                            return Row(
                              children: [
                                Container(
                                  height: 30,
                                  width: 354,
                                  padding: EdgeInsets.symmetric(vertical: 3, horizontal: 15),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Color(0xff686464).withOpacity(0.5),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    focusColor: Colors.transparent,
                                    icon: Icon(
                                      Icons.arrow_drop_down_sharp,
                                      color: Color(0xff686464),
                                    ),
                                    decoration: InputDecoration.collapsed(hintText: ''),
                                    // items: <String>[
                                    //   'Pick Office',
                                    //   'RN',
                                    //   'LVN',
                                    //   'PT',
                                    //   'PTA',
                                    //   'OT',
                                    //   'COTA',
                                    //   'ST',
                                    //   'MSW',
                                    //   'HHA',
                                    // ].map<DropdownMenuItem<String>>((String value) {
                                    //   return DropdownMenuItem<String>(
                                    //     value: value,
                                    //     child: Text(value),
                                    //   );
                                    // }).toList(),
                                    items: dropDownList.map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value == null ? "1" : value,
                                        child: Text(value),
                                        // Container(
                                        //   height: 200,
                                        //   width: 400,
                                        //   child: ListView.builder(
                                        //     itemCount: dropDownList.length,
                                        //       itemBuilder: (BuildContext context, index){
                                        //     return Text(dropDownList[index]);
                                        //   }),
                                        // ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {

                                    },
                                    value:  dropDownList[0],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xff686464),
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }else{return Offstage();

                          }
                        }
                    ),
                  ],
                ),
            ],),
          ),
          SizedBox(height: 20,),
          ///row 1
          StreamBuilder<List<ModuleMetaData>>(
              stream: roleMetaDataSaleController.stream,
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
                              children: List.generate(10, (index){
                                return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 10),
                                    child: Container(
                                      height: MediaQuery.of(context).size.height / 5.3,
                                      width: MediaQuery.of(context).size.width / 6.5,
                                      decoration: BoxDecoration(
                                        color: ColorManager.faintGrey,
                                        borderRadius: BorderRadius.all(Radius.circular(24)),
                                      ),
                                    )
                                );
                              })
                          ),
                        ),
                      ),
                    ),
                  );
                }
                if (snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      AppString.dataNotFound,
                      style: CustomTextStylesCommon.commonStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: FontSize.s14,
                        color: ColorManager.mediumgrey,
                      ),
                    ),
                  );
                }
                if(snapshot.hasData){
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Container(
                      width: MediaQuery.of(context).size.width / 1,
                      child: Center(
                        child: Wrap(
                            children: List.generate(snapshot.data!.length, (index){
                              var metaModule = snapshot.data![index];
                              bool isSelected = selectedContainers[metaModule.appModuleMetaDataId] ?? false;

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 10),
                                child: InkWell(
                                  onTap: () {
                                    toggleSelection(metaModule.appModuleMetaDataId);
                                  },
                                  child: Stack(
                                    children: [CIRoleContainerConstant(
                                      metaModule.mainModule,
                                     //metaModule.iconUrl.toString(),
                                      AssetImage('images/other.png'),
                                      borderColor: selectedContainers[metaModule.appModuleMetaDataId]
                                          ? ColorManager.blueprime
                                          : Colors.white,
                                    ),
                                      if (isSelected)
                                        Positioned(
                                          top: 3,
                                          right: 5,
                                          child: Icon(
                                            Icons.check_circle,
                                            color: ColorManager.blueprime,
                                          ),
                                        ),]
                                  ),
                                ),
                              );
                            })
                        ),
                      ),
                    ),
                  );
                }else{
                  return SizedBox();
                }

              }
          ),
          SizedBox(height: 40,),
          ///button
          Center(
            child: CustomElevatedButton(
              width: AppSize.s105,
              height: AppSize.s30,
              text: AppStringEM.save,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    ),
    );
  }
}
