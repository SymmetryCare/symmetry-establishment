import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/ci_org_doc_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_corporate_compliance_doc/widgets/ci_cc_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_insurance/widgets/ci_insurance.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_templates/ci_tempalets.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/company_identity_details.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/company_identity_zone/zone.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/device_tab/device_tab_ui.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/policies_procedures/policies_procedures.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/vendor_contract/widgets/ci_cc_vendor_contract_screen.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/company_identrity_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/company_identity/company_identity_data_.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_tab_widget/widget/edit_office_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/delete_success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_icon_button_constant.dart';

typedef BackButtonCallBack = void Function(bool val);

class ManageWidget extends StatefulWidget {
  final double officeLat;
  final double officeLon;
  final String officeID;
  final int companyID;
  final int companyOfficeId;
  final String officeName;
  final String stateName;
  final String countryName;
  final BackButtonCallBack backButtonCallBack;
  /// The office as the Company Identity list loaded it; the Edit Office
  /// dialog starts from it.
  final CompanyIdentityModel office;
  /// Whether this is the head office; the delete confirmation says so.
  final bool isHeadOffice;
  ManageWidget({
    Key? key,
    required this.office,
    this.isHeadOffice = false,
    required this.officeID,
    required this.officeName,
    required this.backButtonCallBack,
    required this.companyID,
    required this.companyOfficeId, required this.stateName, required this.countryName, required this.officeLat, required this.officeLon,
    // required this.selectedIndex,
    // required this.selectButton,
  }) : super(key: key);

  @override
  State<ManageWidget> createState() => _ManageWidgetState();
}

class _ManageWidgetState extends State<ManageWidget> {
  final List<String> _categories = [
    'Details',
    'Zones',
    'Insurance',
    'Templates'
  ];
  final PageController _managePageController = PageController();

  int _selectedIndex = 0;

  void _selectButton(int index) {
    setState(() {
      _selectedIndex = index;
    });

    _managePageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  int listIndex = 0;

  void _listButton(int index) {
    setState(() {
      listIndex = index;
    });

    _managePageController.animateToPage(
      index,
      duration: Duration(milliseconds: 200),
      curve: Curves.ease,
    );
  }

  @override
  void initState() {
    super.initState();
    documentTypeGet(context);
    officeName = widget.officeName;
    _office = widget.office;
  }

  /// The office with any edits made from this screen applied.
  late CompanyIdentityModel _office;

  /// Bumped after an edit so the Details and Zones tabs are rebuilt and load
  /// the saved values. Without it the Details tab's own Save would send the
  /// old lat/long back.
  int _officeVersion = 0;

  double get _officeLat => double.tryParse(_office.lat) ?? widget.officeLat;
  double get _officeLon => double.tryParse(_office.long) ?? widget.officeLon;

  Future<void> _editOffice() async {
    final updated = await showDialog<CompanyIdentityModel>(
      context: context,
      builder: (_) => EditOfficePopup(office: _office),
    );
    if (updated == null || !mounted) return;
    setState(() {
      _office = updated;
      officeName = updated.officeName;
      _officeVersion++;
    });
    showDialog(
      context: context,
      builder: (_) => AddSuccessPopup(message: 'Edited successfully.'),
    );
  }

  Future<void> _deleteOffice() async {
    bool deleting = false;
    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => DeletePopup(
          title: 'Delete Office',
          text: widget.isHeadOffice
              ? '"$officeName" is the head office. Do you really want to delete it?'
              : 'Do you really want to delete "$officeName"?',
          loadingDuration: deleting,
          onCancel: () => Navigator.pop(dialogContext),
          onDelete: () async {
            if (deleting) return;
            setDialogState(() => deleting = true);
            final response =
                await deleteCompanyOffice(context, widget.companyOfficeId);
            if (!mounted) return;
            Navigator.pop(dialogContext);
            if (response.success) {
              // Show the confirmation before leaving: going back disposes
              // this screen and its context.
              showDialog(
                  context: context,
                  builder: (_) => const DeleteSuccessPopup());
              widget.backButtonCallBack(true);
            } else {
              showDialog(
                  context: context,
                  builder: (_) => FailedPopup(text: response.message));
            }
          },
        ),
      ),
    );
  }

  String officeName = '';  // local state for office name
  void updateOfficeName(String newName) {
    setState(() {
      officeName = newName;
    });
  }

  int docID = 1;
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
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
          Padding(
                  padding: const EdgeInsets.only(
                      left: AppSize.s140, right: AppPadding.p25,
                      bottom: AppPadding.p30,top: AppPadding.p20),
                  child: Row(
                    children: [
                      Text(
                        officeName,
                        style: CompanyIdentityManageHeadings.customTextStyle(context),
                      ),
                      const Spacer(),
                      CustomIconButtonConst(
                        width: AppSize.s150,
                        height: AppSize.s32,
                        text: 'Edit Office',
                        icon: Icons.mode_edit_outline_outlined,
                        onPressed: _editOffice,
                      ),
                      const SizedBox(width: AppSize.s20),
                      CustomIconButtonConst(
                        width: AppSize.s150,
                        height: AppSize.s32,
                        text: 'Delete Office',
                        icon: Icons.delete_outline_outlined,
                        onPressed: _deleteOffice,
                      ),
                    ],
                  ),
                ),
          Padding(
            padding: EdgeInsets.only(left: AppPadding.p35),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    InkWell(
                        onTap: () {
                          widget.backButtonCallBack(true);
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_back,
                              size: IconSize.I16,
                              color: ColorManager.mediumgrey,

                            ),
                            SizedBox(width: AppSize.s1,),
                            Text(
                              'Go Back',
                              style: DefineWorkWeekStyle.customTextStyle(context),
                            ),
                          ],
                        )),
                  ],
                ),
                SizedBox(width: MediaQuery.of(context).size.width / 50,),
                Container(
                  width: MediaQuery.of(context).size.width / 1.148,
                  height: AppSize.s30,
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: ColorManager.black.withOpacity(0.25),
                          spreadRadius: 0,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                      color: ColorManager.blueprime,
                      borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        child: Container(
                          height: 30,
                          width: MediaQuery.of(context).size.width / 9.5,
                          padding: EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: _selectedIndex == 0 ? Colors.white : null,
                          ),
                          child: Text(
                              ManagaeButtonheading.details,
                            textAlign: TextAlign.center,
                              style: BlueBgTabbar.customTextStyle(0, _selectedIndex)
                          ),
                        ),
                        onTap: () => _selectButton(0),
                      ),
                      InkWell(
                        child: Container(
                          height: AppSize.s30,
                          width: MediaQuery.of(context).size.width / 9.4,
                          padding: EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: _selectedIndex == 1
                                ? ColorManager.white
                                : null,
                          ),
                          child: Text(
                              ManagaeButtonheading.zones,
                            textAlign: TextAlign.center,
                              style: BlueBgTabbar.customTextStyle(1, _selectedIndex)

                          ),
                        ),
                        onTap: () => _selectButton(1),
                      ),
                      InkWell(
                        child: Container(
                          height: AppSize.s30,
                          width: MediaQuery.of(context).size.width / 5.5,
                          padding: EdgeInsets.symmetric(vertical: AppPadding.p6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: _selectedIndex == 2
                                ? ColorManager.white
                                : null,
                          ),
                          child: Text(
                              ManagaeButtonheading.cc,
                            textAlign: TextAlign.center,
                              style: BlueBgTabbar.customTextStyle(2, _selectedIndex)
                          ),
                        ),
                        onTap: () => _selectButton(2),
                      ),
                      InkWell(
                        child: Container(
                          height: AppSize.s30,
                          width: MediaQuery.of(context).size.width / 8.7,
                          padding: EdgeInsets.symmetric(vertical: AppPadding.p6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: _selectedIndex == 3
                                ? ColorManager.white
                                : null,
                          ),
                          child: Text(
                              ManagaeButtonheading.insurance,
                            textAlign: TextAlign.center,
                              style: BlueBgTabbar.customTextStyle(3, _selectedIndex)
                          ),
                        ),
                        onTap: () => _selectButton(3),
                      ),
                      InkWell(
                        child: Container(
                          height: AppSize.s30,
                          width: MediaQuery.of(context).size.width / 8.4,
                          padding: EdgeInsets.symmetric(vertical: AppPadding.p6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: _selectedIndex == 4
                                ? ColorManager.white
                                : null,
                          ),
                          child: Text(
                              ManagaeButtonheading.vc,
                            textAlign: TextAlign.center,
                              style: BlueBgTabbar.customTextStyle(4, _selectedIndex)
                          ),
                        ),
                        onTap: () => _selectButton(4),
                      ),
                      InkWell(
                        child: Container(
                          height: AppSize.s30,
                          width: MediaQuery.of(context).size.width / 8.4,
                          padding: EdgeInsets.symmetric(vertical: AppPadding.p6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: _selectedIndex == 5
                                ? ColorManager.white
                                : null,
                          ),
                          child: Text(
                              ManagaeButtonheading.pp,
                            textAlign: TextAlign.center,
                              style: BlueBgTabbar.customTextStyle(5, _selectedIndex)
                          ),
                        ),
                        onTap: () => _selectButton(5),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        child: Container(
                          height: AppSize.s30,
                          width: MediaQuery.of(context).size.width / 8.039,
                          padding: EdgeInsets.symmetric(vertical: AppPadding.p6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: _selectedIndex == 6
                                ? ColorManager.white
                                : null,
                          ),
                          child: Text(
                            "Devices",
                                  // ManagaeButtonheading.templates,
                            textAlign: TextAlign.center,
                              style: BlueBgTabbar.customTextStyle(6, _selectedIndex)
                          ),
                        ),
                        onTap: () => _selectButton(6),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: AppSize.s30,),
          Expanded(
            flex: 10,
            child: Stack(children: [
              _selectedIndex == 0
                  ? const Offstage()
                  : Container(
                height: MediaQuery.of(context).size.height / 3.5,
                decoration: BoxDecoration(
                  color: Color(0xFFF2F9FC),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Stack(
                  children: [
                    // Inner shadow effect at the top
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding:  EdgeInsets.only(top: AppPadding.p10),
                        height: 6, // Adjust the height of the shadow effect
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.2), // Darker at top
                              Colors.transparent, // Fades out
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppPadding.p5),
                child: PageView(
                    controller: _managePageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      CIDetailsScreen(
                        key: ValueKey('details-$_officeVersion'),
                        companyID: widget.companyID,
                        officeId: widget.officeID,
                        docTD: docID,
                        companyId: widget.companyID,
                        companyOfficeid: widget.companyOfficeId, stateName: _office.stateName,
                        countryName: _office.countryName, updateOfficeName: updateOfficeName,
                      ),
                      CiZone(
                        key: ValueKey('zones-$_officeVersion'),
                        companyID: widget.companyID,
                        officeId: widget.officeID,
                        docId: docID, stateName: _office.stateName, countryName: _office.countryName,
                        officeLat: _officeLat, officeLon: _officeLon,
                      ),
                      CiCorporateComplianceScreen(
                        docId: FrontendConfigStore.data!.config.corporateAndCompliance,
                        // docId: AppConfig.corporateAndCompliance,
                        officeId: widget.officeID,
                        companyID: widget.companyID,
                      ),
                      CIInsurance(
                        officeId: widget.officeID,
                        // docID: AppConfig.corporateAndCompliance,
                        docID:FrontendConfigStore.data!.config.corporateAndCompliance,
                        subDocID:FrontendConfigStore.data!.config.subDocId0,
                        // subDocID: AppConfig.subDocId0,
                        companyID: widget.companyID,
                      ),
                      CiCcVendorContractScreen(
                        companyID: widget.companyID,
                        officeId: widget.officeID,
                        docId:  FrontendConfigStore.data!.config.vendorContracts,
                        // docId: AppConfig.vendorContracts,
                      ),
                      CiPoliciesAndProcedures(
                        docID:  FrontendConfigStore.data!.config.policiesAndProcedure,
                        // docID: AppConfig.policiesAndProcedure,
                        subDocID: FrontendConfigStore.data!.config.subDocId0,
                        // subDocID: AppConfig.subDocId0,
                        companyID: widget.companyID,
                        officeId: widget.officeID,
                      ),
                      // CiTempalets()
                      DeviceTabUi(
                        companyID: widget.companyID,
                      )
                    ]),
              ),
            ]),
          ),
        ],          // Column children
      ),            // Column
              ),    // SizedBox
            ),      // Padding
          ),        // SingleChildScrollView
        );          // CustomScrollbar
      }),           // LayoutBuilder
    );
  }
}

class CustomButtonList extends StatelessWidget {
  final String buttonText;
  final int isSelected;
  final int docID;
  final Function() onTap;

  const CustomButtonList({
    required this.buttonText,
    required this.isSelected,
    required this.onTap,
    Key? key,
    required this.docID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: AppSize.s30,
        width: MediaQuery.of(context).size.width / 8.62,
        padding: const EdgeInsets.symmetric(vertical: AppPadding.p6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected == docID ? ColorManager.white : null,
        ),
        child: Text(
          buttonText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: FontSize.s14,
            fontWeight: FontWeight.bold,
            color: isSelected == docID ? Colors.grey[600] : ColorManager.white,
          ),
        ),
      ),
    );
  }
}