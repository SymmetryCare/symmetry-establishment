import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/color.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import 'package:prohealth/app/services/api/managers/establishment_manager/manage_insurance_manager/insurance_vendor_contract_manager.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/ci_insurance/ci_insurance_contract.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/ci_insurance/ci_insurance_vendor.dart';
import '../../../../../../../app/resources/establishment_resources/establish_theme_manager.dart';
import '../../../../../../../app/resources/establishment_resources/establishment_string_manager.dart';
import '../../../../../../../data/api_data/establishment_data/ci_manage_button/manage_insurance_data.dart';
import '../../../../../../widgets/widgets/custom_icon_button_constant.dart';
import '../../../company_identity_screen.dart';
import '../../ci_corporate_compliance_doc/widgets/corporate_compliance_constants.dart';
import '../../vendor_contract/widgets/ci_cc_vendor_contract_screen.dart';
import '../../whitelabelling/success_popup.dart';
import 'contract_add_dialog.dart';
import 'custome_dialog.dart';

class CIInsurance extends StatefulWidget {
  final String officeId;
  final int docID;
  final int subDocID;
  final int companyID;

  const CIInsurance({
    super.key,
    required this.officeId,
    required this.docID,
    required this.subDocID,
    required this.companyID,
  });

  @override
  State<CIInsurance> createState() => _CiOrgDocumentState();
}

class _CiOrgDocumentState extends State<CIInsurance> {
  final PageController _tabPageController = PageController();
  TextEditingController vendorNameController = TextEditingController();
  TextEditingController contractNameController = TextEditingController();
  TextEditingController contractIdController = TextEditingController();
  TextEditingController calenderController = TextEditingController();
  TextEditingController dummyCtrl = TextEditingController();
  int _selectedIndex = 0;
  int selectedVendorId = 0;
  String? selectedVendorName;
  String? selectedExpiryType;

  bool isAddButtonEnabled = false;

  void _selectButton(int index,[bool? selected]) {
    setState(() {
      _selectedIndex = index;
      selected = false;
    });
    _tabPageController.animateToPage(
      index,
      duration: Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  String? expiryType;
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppPadding.p65),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child:  _selectedIndex == 0
                      ? Container(width: AppSize.s285)
                      : FutureBuilder<List<ManageVendorData>>(
                    future: companyVendorGet(context, widget.officeId, 1, 50),
                    builder: (context, snapshotZone) {
                      if (snapshotZone.connectionState == ConnectionState.waiting &&
                          selectedValue == null) {
                        return Container(
                          width:  AppSize.s285,
                          height: AppSize.s30,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: ColorManager.containerBorderGrey, width: AppSize.s1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: AppSize.s10),
                              Expanded(
                                child: Text(
                                  "Select",
                                  style: DocumentTypeDataStyle.customTextStyle(context),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppPadding.p8),
                                child: Icon(Icons.arrow_drop_down),
                              ),
                            ],
                          ),
                        );
                      }

                      if (snapshotZone.hasError || snapshotZone.data == null) {
                        return Container(width:  AppSize.s285,
                          height: AppSize.s30,
                          decoration: BoxDecoration(
                            // color: Colors.red,
                            border: Border.all(
                                color: ColorManager.containerBorderGrey, width: AppSize.s1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: AppSize.s10),
                              Expanded(
                                child: Text(
                                  "Select",
                                  style: DocumentTypeDataStyle.customTextStyle(context),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: AppPadding.p8),
                                child: Icon(Icons.arrow_drop_down),
                              ),
                            ],
                          ),
                        );
                      }
                      if (snapshotZone.data!.isEmpty) {
                        return Container(
                          width:  AppSize.s285,
                          height: AppSize.s30,
                          // padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            // color: Colors.red,
                            border: Border.all(
                                color: ColorManager.containerBorderGrey, width: AppSize.s1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(ErrorMessageString.noVendorAdded,
                              style: DocumentTypeDataStyle.customTextStyle(context),),
                          ),
                        );

                      }
                      if (snapshotZone.hasData) {
                        List<DropdownMenuItem<String>> dropDownTypesList = [];
                        for (var i in snapshotZone.data!) {
                          dropDownTypesList.add(
                            DropdownMenuItem<String>(
                              value: i.vendorName,
                              child: Text(i.vendorName),
                            ),
                          );
                        }
                        if (selectedValue == null && dropDownTypesList.isNotEmpty) {
                          selectedValue = dropDownTypesList[0].value;
                        }

                        return CICCDropdown(
                          initialValue: "Select",
                          onChange: (val) {
                            setState(() {
                              selectedValue = val;
                              for (var a in snapshotZone.data!) {
                                if (a.vendorName == val) {
                                  int docType = a.insuranceVendorId;
                                  print("Insurance vendor id :: ${a.insuranceVendorId}");
                                  selectedVendorId = docType;
                                  isAddButtonEnabled = true;
                                  _selectButton(1);
                                  break;
                                }
                              }
                            });
                          },
                          items: dropDownTypesList,
                        );
                      }

                      return const SizedBox();
                    },
                  ),),
                Expanded(
                    flex: 2,
                    child: Container(
                      height: 30,
                      //  color: ColorManager.red,
                    )),
                ///tabbar
                Expanded(
                  flex: 2,
                  child: Container(
                    //  color: Colors.greenAccent,
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppPadding.p10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          EMTabbar(onTap: (int index){
                            _selectButton(0);
                          }, index: 0, grpIndex: _selectedIndex, heading: AppStringEM.vendor),
                          EMTabbar(onTap: (int index){
                            _selectButton(1);
                          }, index: 1, grpIndex: _selectedIndex, heading: AppStringEM.contract),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                    flex: 3,
                    child: Container(
                      height: 30,
                      //  color: Colors.grey,
                    )),
                ///buttons
                _selectedIndex == 0
                    ? CustomIconButtonConst(
                    icon: Icons.add,
                    text: AppStringEM.addVendor,
                    width: AppSize.s140,
                    onPressed: () {
                      vendorNameController.clear();
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AddVendorPopup(
                            namecontroller: vendorNameController,
                            officeID: widget.officeId,

                          );

                        },


                      );
                      // print('Request Body: ${yourRequestBody}');

                    })
                    : CustomIconButtonConst(
                  icon: Icons.add,
                  width: AppSize.s140,
                  text: AppStringEM.adddoctype,
                  onPressed: isAddButtonEnabled ? () {
                    //selectedExpiryType = expiryType;
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (BuildContext context, void Function(void Function()) setState) {
                            return ContractAddDialog(
                              selectedVendorId :selectedVendorId,
                              officeid:widget.officeId,
                              title: 'Add Contract',
                            );
                          },
                        );
                      },
                    );
                  }
                      : () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return VendorSelectNoti(message: "No Vendor Added.",);
                      },
                    );
                  },
                  enabled: isAddButtonEnabled,
                )

              ],
            ),
          ),
          SizedBox(height: AppSize.s30),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: AppPadding.p65),
              child: NonScrollablePageView(
                controller: _tabPageController,
                onPageChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                children: [
                  // Page 1
                  CiInsuranceVendor(
                    officeId: widget.officeId,
                  ),
                  CiInsuranceContract(
                    insuranceVendorId: selectedVendorId,
                    officeId: widget.officeId,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

