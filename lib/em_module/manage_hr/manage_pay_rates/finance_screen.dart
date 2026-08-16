import 'dart:async';
import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/color.dart';
import 'package:prohealth/app/resources/common_resources/common_theme_const.dart';
import 'package:prohealth/app/resources/establishment_resources/establish_theme_manager.dart';
import 'package:prohealth/app/resources/establishment_resources/establishment_string_manager.dart';
import 'package:prohealth/app/services/api/managers/establishment_manager/all_from_hr_manager.dart';
import 'package:prohealth/app/services/api/managers/establishment_manager/ci_visit_manager.dart';
import 'package:prohealth/app/services/api/managers/establishment_manager/manage_details_manager.dart';
import 'package:prohealth/app/services/api/managers/establishment_manager/pay_rates_manager.dart';
import 'package:prohealth/data/api_data/establishment_data/all_from_hr/all_from_hr_data.dart';
import 'package:prohealth/data/api_data/establishment_data/ci_manage_button/manage_details_data.dart';
import 'package:prohealth/data/api_data/establishment_data/company_identity/ci_visit_data.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/ci_corporate_compliance_doc/widgets/corporate_compliance_constants.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:prohealth/presentation/screens/em_module/manage_hr/manage_pay_rates/widgets/custom_popup.dart';
import 'package:prohealth/presentation/screens/em_module/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';
import 'package:prohealth/presentation/screens/hr_module/manage/widgets/custom_icon_button_constant.dart';
import 'package:prohealth/presentation/widgets/error_popups/failed_popup.dart';
import 'package:prohealth/presentation/widgets/error_popups/four_not_four_popup.dart';
import 'package:prohealth/presentation/widgets/widgets/custom_icon_button_constant.dart';
import 'package:provider/provider.dart';
import '../../../../../app/constants/app_config.dart';
import '../../../../../app/resources/const_string.dart';
import '../../../../../app/resources/provider/delete_popup_provider.dart';
import '../../../../../app/resources/theme_manager.dart';
import '../../../../../app/resources/value_manager.dart';
import '../../../../../app/services/token/token_manager.dart';
import '../../../../../data/api_data/establishment_data/pay_rates/pay_rates_finance_data.dart';
import '../../../../../data/appconfige_data/app_confige_data.dart';
import '../../../../widgets/error_popups/delete_success_popup.dart';
import '../../../../widgets/widgets/custom_scrollbar.dart';
import '../../../../widgets/widgets/profile_bar/widget/pagination_widget.dart';
import '../../company_identity/widgets/error_pop_up.dart';
import '../../widgets/table_constant.dart';
import '../../widgets/text_form_field_const.dart';

class FinanceProvider with ChangeNotifier {
  TextEditingController payRatesController = TextEditingController();
  TextEditingController perMilesController = TextEditingController();
  TextEditingController fixedPayRatesController = TextEditingController();

  String? selectedServiceName;
  String? selectedAbbreviation;

  int empTypeId = 0;
  String serviceId = "";

  int docZoneId = 0;
  bool isLoading = false;
  int currentPage = 1;
  final int itemsPerPage = 10;

  List<PayRatesGet> payRatesList = [];
  List<ServicesMetaData> servicesMetaData = [];
  List<HRAllData> hrData = [];

  // Stream for Pay Rates
  final StreamController<List<PayRatesGetByServiceId>> _payRatesController =
  StreamController<List<PayRatesGetByServiceId>>.broadcast();

  Stream<List<PayRatesGetByServiceId>> get payRatesStream =>
      _payRatesController.stream;

  FinanceProvider();

  void goToPreviousPage() {
    if (currentPage > 1) {
      currentPage--;
      notifyListeners();
    }
  }

  void goToPage(int pageNumber) {
    currentPage = pageNumber;
    notifyListeners();
  }

  void goToNextPage(int totalPages) {
    if (currentPage < totalPages) {
      currentPage++;
      notifyListeners();
    }
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> loadPayRatesData(BuildContext context) async {
    try {
      payRatesList = await companyPayratesGet(context);
      notifyListeners();
    } catch (error) {
      print("Error loading pay rates: $error");
    }
  }

  ///defauld service id
  Future<void> loadServicesMetaData(BuildContext context) async {
    try {
      servicesMetaData = await getServicesMetaData(context);
      if (servicesMetaData.isNotEmpty) {
        selectedServiceName = servicesMetaData[0].serviceName;
        serviceId = servicesMetaData[0].serviceId;
      }
      notifyListeners();
    } catch (error) {
      print("Error loading services metadata: $error");
    }
  }

  ///defualt emptypeid
  Future<void> loadHrData(BuildContext context) async {
    try {
      hrData = await getAllHrDeptWise(context, FrontendConfigStore.data!.config.clinicalId);
      // hrData = await getAllHrDeptWise(context, AppConfig.clinicalId);
      if (hrData.isNotEmpty) {
        selectedAbbreviation = hrData[0].abbrivation;
        empTypeId = hrData[0].employeeTypesId;
      }
      notifyListeners();
    } catch (error) {
      print("Error loading HR data: $error");
    }
  }

  void fetchPayRates(BuildContext context, String serviceId, int empTypeId) {
    if (serviceId.isEmpty || empTypeId == 0) {
      print("Service ID or Employee Type ID is not set. Cannot fetch pay rates.");
      return;
    }

    companyPayratesGetByServiceAndEmployeeId(
      context: context,
      serviceId: serviceId,
      empId: empTypeId,
    ).then((data) {
      _payRatesController.add(data); // Emit fetched data
    }).catchError((error) {
      print("Error fetching pay rates: $error");
      _payRatesController.addError(error); // Emit error to the stream
    });
  }

  void updateSelectedService(String serviceName, BuildContext context) {
    final selectedService = servicesMetaData.firstWhere(
          (service) => service.serviceName == serviceName,
      orElse: () => ServicesMetaData(
        serviceName: "Default Service",
        serviceId: "0", serviceMetaDataId: 0, // Default serviceId
        // Add other required fields with default values
      ),
    );

    serviceId = selectedService.serviceId;
    selectedServiceName = selectedService.serviceName;

    // Fetch pay rates based on updated serviceId and empTypeId
    fetchPayRates(context, serviceId, empTypeId);

    notifyListeners();
  }

  void updateSelectedAbbreviation(
      String abbreviation, int employeeTypeId, BuildContext context) {
    final selectedHR = hrData.firstWhere(
          (hr) => hr.abbrivation == abbreviation,
      orElse: () => HRAllData(
        abbrivation: "Default Abbreviation",
        employeeTypesId: 0, deptID: 0,
      ),
    );

    empTypeId = selectedHR.employeeTypesId;
    selectedAbbreviation = selectedHR.abbrivation;

    fetchPayRates(context, serviceId, empTypeId);

    notifyListeners();
  }

  void logCurrentState() {
    print("Current Service: $selectedServiceName (ID: $serviceId)");
    print("Current Abbreviation: $selectedAbbreviation (ID: $empTypeId)");
  }

  void removePayRateById(int payRateId) {
    payRatesList.removeWhere((payRate) => payRate.payratesId == payRateId);
    notifyListeners();
  }

  void updatePayRate(PayRatesGet updatedPayRate) {
    int index = payRatesList.indexWhere((item) => item.payratesId == updatedPayRate.payratesId);

    if (index != -1) {
      payRatesList[index] = updatedPayRate;
      notifyListeners();
    }
  }

}

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FinanceProvider()
        ..loadPayRatesData(context)
        ..loadServicesMetaData(context)
        ..loadHrData(context),
      child: Consumer<FinanceProvider>(
        builder: (context, provider, child) {
          return Material(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 13),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Clinicians Pay Rates',
                        style: DefineWorkWeekStyle.customTextStyle(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSize.s32),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pick Service Type',
                            style: DefineWorkWeekStyle.customTextStyle(context),
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height / 100),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Consumer<FinanceProvider>(
                                builder: (context, provider, _) {
                                  if (provider.servicesMetaData.isEmpty) {
                                    return Container(
                                      width: AppSize.s300,
                                      height: AppSize.s30,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: ColorManager.containerBorderGrey,
                                            width: AppSize.s1),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: AppPadding.p10, vertical: AppPadding.p5),
                                        child: Text(
                                          ErrorMessageString.noserviceAdded,
                                          style:
                                          ConstTextFieldRegister.customTextStyle(
                                              context),
                                        ),
                                      ),
                                    );
                                  }

                                  return CICCDropdown(
                                    width: AppSize.s300,
                                    initialValue: provider.selectedServiceName,
                                    onChange: (val) {
                                      provider.updateSelectedService(val,context);
                                    },
                                    items: provider.servicesMetaData
                                        .map((service) => DropdownMenuItem<String>(
                                      value: service.serviceName,
                                      child: Text(service.serviceName ?? ''),
                                    ))
                                        .toList(),
                                  );
                                },
                              ),
                              const SizedBox(width: AppSize.s10),
                              Consumer<FinanceProvider>(
                                builder: (context, provider, _) {
                                  if (provider.hrData.isEmpty) {
                                    return Container(
                                      width: AppSize.s300,
                                      height: AppSize.s30,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: ColorManager.containerBorderGrey,
                                            width: AppSize.s1),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: AppPadding.p10, vertical: AppPadding.p5),
                                        child: Text(
                                          ErrorMessageString.noserviceAdded,
                                          style:
                                          ConstTextFieldRegister.customTextStyle(
                                              context),
                                        ),
                                      ),
                                    );
                                  }

                                  return CICCDropdown(
                                    width: AppSize.s300,
                                    initialValue: provider.selectedAbbreviation,
                                    onChange: (val) {
                                      final selectedHR = provider.hrData.firstWhere(
                                            (hr) => hr.abbrivation == val,
                                      );
                                      provider.updateSelectedAbbreviation(
                                          val,
                                          selectedHR.employeeTypesId,context
                                      );
                                    },
                                    items: provider.hrData
                                        .map((hr) => DropdownMenuItem<String>(
                                      value: hr.abbrivation,
                                      child: Text(hr.abbrivation ?? ''),
                                    ))
                                        .toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                          CustomIconButtonConst(
                            height: AppSize.s30,
                            width: AppSize.s130,
                            text: AddPopupString.addPayrate,
                            icon: Icons.add,
                            onPressed: () async {

                              showDialog(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
                                  print(";;;;;;;;;;;;;;;;;;; ");
                                  print(";;;;;;;;;;;;;;;;;; ");
                                  print(";;;;;;;;;;;;;;;;;;; ");
                                  print("serviceId ;;;;;;;;;;;;;;;;;;; ${financeProvider.serviceId}");
                                  print("empTypeId ;;;;;;;;;;;;;;;;;;; ${financeProvider.empTypeId}");
                                  return FutureBuilder<List<VisitListDataByServiceId>>(
                                      future:  getVisitListByServiceId(context: context, serviceId: financeProvider.serviceId),
                                      builder: (context, snapshot) {
                                        if(snapshot.connectionState == ConnectionState.waiting){
                                          return Center(child:CircularProgressIndicator(color: ColorManager.blueprime,));
                                        }
                                        return ChangeNotifierProvider(
                                          create: (_) => PayRatesProvider(),
                                          child: PayRateAddPopup(
                                            onSave: () {
                                              provider.fetchPayRates(context, financeProvider.serviceId, financeProvider.empTypeId);
                                            },
                                            serviceId: financeProvider.serviceId ?? "",
                                            empTypeId: financeProvider.empTypeId ?? 0,
                                            fixPayRatesController: TextEditingController(),
                                            visitTypeTextActive: true,
                                            payRatesController: TextEditingController(),
                                            perMilesController: TextEditingController(),
                                            title: AddPopupString.addPayrate, visitList: snapshot.data!,
                                          ),
                                        );
                                      }
                                  );
                                },
                              );
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSize.s15),

                  // StreamBuilder to display pay rates
                  Expanded(
                    child: Consumer<FinanceProvider>(
                      builder: (context, provider, _) {
                        provider.fetchPayRates(context, provider.serviceId, provider.empTypeId);

                        return StreamBuilder<List<PayRatesGetByServiceId>>(
                          stream: provider.payRatesStream,
                          builder: (context, snapshot) {
                            // Debugging: Log the connection state
                            print("Stream connection state: ${snapshot.connectionState}");
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: ColorManager.blueprime,
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              print("Error: ${snapshot.error}");
                              return Center(
                                child: Text("Error: ${snapshot.error}"),
                              );
                            }

                            if (snapshot.hasData && snapshot.data!.isEmpty) {
                              return Center(
                                child: Text('No Payrates available.'),
                              );
                            }

                            if (snapshot.hasData) {
                              int totalItems = snapshot.data!.length;
                              int totalPages = (totalItems / provider.itemsPerPage).ceil();
                              List<PayRatesGetByServiceId> paginatedData = snapshot.data!
                                  .skip((provider.currentPage - 1) * provider.itemsPerPage)
                                  .take(provider.itemsPerPage)
                                  .toList();

                              return Column(
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
                                                  const TableHeadConstant(
                                                    items: [
                                                      TableHeadItem(text: AppStringEM.srNo, textAlign: TextAlign.center),
                                                      TableHeadItem(text: AppStringEM.typeVisit, textAlign: TextAlign.start),
                                                      TableHeadItem(text: AppStringEM.rate, textAlign: TextAlign.center),
                                                      TableHeadItem(text: AppStringEM.actions, textAlign: TextAlign.center),
                                                    ],
                                                  ),
                                                  SizedBox(height: AppSize.s10),
                                                  Expanded(
                                                    child: ListView.builder(
                                                      itemCount: paginatedData.length,
                                                      itemBuilder: (context, index) {
                                        final finance = paginatedData[index];
                                        final formattedSerialNumber = ((provider.currentPage - 1) * provider.itemsPerPage + index + 1).toString();

                                        return Column(
                                          children: [
                                            const SizedBox(height: AppSize.s5),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(4),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(0xff000000).withOpacity(0.25),
                                                    spreadRadius: 0,
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              height: AppSize.s50,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  Expanded(
                                                    child: Center(
                                                      child: Text(
                                                        formattedSerialNumber,
                                                        style: TableSubHeading.customTextStyle(context),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Center(
                                                      child: Text(
                                                        finance.typeOfVisitId,
                                                        style: TableSubHeading.customTextStyle(context),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Center(
                                                      child: Text(
                                                        '\$${finance.rate}',
                                                        style: TableSubHeading.customTextStyle(context),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Center(
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          IconButton(
                                                            splashColor: Colors.transparent,
                                                            highlightColor: Colors.transparent,
                                                            hoverColor: Colors.transparent,
                                                            onPressed: () {
                                                              // Clear controllers before showing the dialog
                                                              provider.payRatesController.clear();
                                                              provider.perMilesController.clear();

                                                              showDialog(
                                                                context: context,
                                                                builder: (BuildContext context) {
                                                                  return FutureBuilder<PayRatePrefillFinanceData>(
                                                                    future: payPrefillRatesDataGet(context, finance.payratesId),
                                                                    builder: (context, snapshotPrefill) {
                                                                      if (snapshotPrefill.connectionState == ConnectionState.waiting) {
                                                                        return Center(
                                                                          child: CircularProgressIndicator(
                                                                            color: ColorManager.blueprime,
                                                                          ),
                                                                        );
                                                                      }

                                                                      var fixPayRates = snapshotPrefill.data?.outOfZoneRate;
                                                                      var payRates = snapshotPrefill.data?.payratesId;
                                                                      var visitTypeId = snapshotPrefill.data?.typeOfVisitId;
                                                                      var perMile = snapshotPrefill.data?.outOfZoneperMile;

                                                                      provider.fixedPayRatesController = TextEditingController(text: snapshotPrefill.data?.outOfZoneRate.toString());
                                                                      provider.payRatesController = TextEditingController(text: snapshotPrefill.data?.rate.toString());
                                                                      provider.perMilesController = TextEditingController(text: snapshotPrefill.data?.outOfZoneperMile.toString());

                                                                      return ChangeNotifierProvider(
                                                                        create: (_) => PayRatesEditProvider(),
                                                                        child: PayRatesEditsPopup(
                                                                          visitTypeTextActive: false,
                                                                          title: 'Edit Payrate',
                                                                          child1: SMTextFConst(
                                                                            enable: false,
                                                                            readOnly: true,
                                                                            controller: TextEditingController(
                                                                              text: visitTypeId.toString(),
                                                                            ),
                                                                            keyboardType: TextInputType.number,
                                                                            text: 'Type of Visit',
                                                                          ),
                                                                          child2: FutureBuilder<List<SortByZoneData>>(
                                                                            future: PayRateZoneDropdown(context),
                                                                            builder: (context, snapshot) {
                                                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                                                return CICCDropDownExcel(
                                                                                  width: AppSize.s354,
                                                                                  initialValue: 'Select',
                                                                                  items: [],
                                                                                );
                                                                              }

                                                                              if (snapshot.data!.isEmpty) {
                                                                                return Center(
                                                                                  child: Text(
                                                                                    AppString.dataNotFound,
                                                                                    style: AllNoDataAvailable.customTextStyle(context),
                                                                                  ),
                                                                                );
                                                                              }

                                                                              if (snapshot.hasData) {
                                                                                List dropDown = [];
                                                                                int docType = 0;
                                                                                List<DropdownMenuItem<String>> dropDownTypesList = [];
                                                                                for (var i in snapshot.data!) {
                                                                                  dropDownTypesList.add(
                                                                                    DropdownMenuItem<String>(
                                                                                      child: Text(i.zoneName),
                                                                                      value: i.zoneName,
                                                                                    ),
                                                                                  );
                                                                                }

                                                                                return CICCDropDownExcel(
                                                                                  initialValue: dropDownTypesList[0].value,
                                                                                  onChange: (val) {
                                                                                    for (var a in snapshot.data!) {
                                                                                      if (a.zoneName == val) {
                                                                                        docType = a.zoneId;
                                                                                        provider.docZoneId = docType;
                                                                                      }
                                                                                    }
                                                                                  },
                                                                                  items: dropDownTypesList,
                                                                                );
                                                                              }

                                                                              return const SizedBox();
                                                                            },
                                                                          ),
                                                                          payRatesController: provider.payRatesController,
                                                                          perMilesController: provider.perMilesController,
                                                                          fixPayRatesController: provider.fixedPayRatesController,
                                                                          onPressed: () async {
                                                                            var response = await updatePayRatesSetupPost(
                                                                              context: context,
                                                                              payratesId: finance.payratesId,
                                                                              rate: payRates == int.parse(provider.payRatesController.text)
                                                                                  ? payRates!
                                                                                  : int.parse(provider.payRatesController.text),
                                                                              typeOfVisitId: visitTypeId!,
                                                                              outOfZoneperMile: perMile == int.parse(provider.perMilesController.text)
                                                                                  ? perMile!
                                                                                  : int.parse(provider.perMilesController.text),
                                                                              outOfZoneRate: fixPayRates == int.parse(provider.fixedPayRatesController.text)
                                                                                  ? fixPayRates!
                                                                                  : int.parse(provider.fixedPayRatesController.text),
                                                                              serviceId: snapshotPrefill.data!.serviceId,
                                                                            );

                                                                            if (response.statusCode == 200 || response.statusCode == 201) {
                                                                              final companyId = await TokenManager.getCompanyId();
                                                                              // Update the pay rate in the provider
                                                                              PayRatesGet updatedPayRate = PayRatesGet(
                                                                                payratesId: finance.payratesId,
                                                                                rate: int.parse(provider.payRatesController.text),
                                                                                outOfZoneRate: int.parse(provider.fixedPayRatesController.text),
                                                                                outOfZonePerMile: int.parse(provider.perMilesController.text),
                                                                                serviceID: finance.serviceID,
                                                                                typeOfVisitId: finance.typeOfVisitId, companyId: companyId,
                                                                              );
                                                                              provider.updatePayRate(updatedPayRate);
                                                                              provider.fetchPayRates(context, provider.serviceId, provider.empTypeId);
                                                                              Navigator.pop(context);
                                                                              provider.updatePayRate(updatedPayRate);
                                                                              showDialog(
                                                                                context: context,
                                                                                builder: (BuildContext context) {
                                                                                  return const AddSuccessPopup(
                                                                                    message: 'Edit Successfully',
                                                                                  );
                                                                                },
                                                                              );
                                                                            } else {
                                                                              Navigator.pop(context);
                                                                              showDialog(
                                                                                context: context,
                                                                                builder: (BuildContext context) => FailedPopup(text: response.message),
                                                                              );
                                                                            }

                                                                            provider.payRatesController.clear();
                                                                            provider.perMilesController.clear();
                                                                            provider.fixedPayRatesController.clear();
                                                                          },
                                                                        ),
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            icon: Icon(
                                                              Icons.edit_outlined,
                                                              size: IconSize.I18,
                                                              color: ColorManager.blueprime,
                                                            ),
                                                          ),
                                                          IconButton(
                                                            splashColor: Colors.transparent,
                                                            highlightColor: Colors.transparent,
                                                            hoverColor: Colors.transparent,
                                                            onPressed: () {
                                                              showDialog(
                                                                context: context,
                                                                builder: (context) => StatefulBuilder(
                                                                  builder: (BuildContext context, void Function(void Function()) setState) {
                                                                    return DeletePopupProvider(
                                                                      title: 'Delete Pay Rates',
                                                                      loadingDuration: provider.isLoading,
                                                                      onCancel: () {
                                                                        Navigator.pop(context); // Close the dialog
                                                                      },
                                                                      onDelete: () async {
                                                                        setState(() {
                                                                          provider.isLoading = true; // Show loading state
                                                                        });

                                                                        try {
                                                                          // Perform the deletion operation
                                                                          await deletePayRatesId(context, finance.payratesId);

                                                                          // Remove from the list in the provider
                                                                          provider.removePayRateById(finance.payratesId);

                                                                          // Close the dialog after successful deletion
                                                                          Navigator.pop(context);

                                                                          // Show success dialog
                                                                          showDialog(
                                                                            context: context,
                                                                            builder: (context) => DeleteSuccessPopup(),
                                                                          );
                                                                        } catch (error) {
                                                                          // Handle deletion error
                                                                          print("Error deleting pay rates: $error");
                                                                          showDialog(
                                                                            context: context,
                                                                            builder: (context) => ErrorPopUp(text: "Failed to delete pay rates.", title: "Payrates",),
                                                                          );
                                                                        } finally {
                                                                          setState(() {
                                                                            provider.isLoading = false; // Hide loading state
                                                                          });
                                                                        }
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                              );
                                                            },
                                                            icon: Icon(
                                                              Icons.delete_outline_outlined,
                                                              size: IconSize.I18,
                                                              color: ColorManager.red,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),

                                                  SizedBox(width: AppSize.s30),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                  PaginationControlsWidget(
                                    currentPage: provider.currentPage,
                                    items: snapshot.data!,
                                    itemsPerPage: provider.itemsPerPage,
                                    onPreviousPagePressed: provider.goToPreviousPage,
                                    onPageNumberPressed: provider.goToPage,
                                    onNextPagePressed: () =>
                                        provider.goToNextPage(totalPages),
                                  ),
                                  SizedBox(height: AppSize.s10),
                                ],
                              );
                            }

                            return Offstage();
                          },
                        );
                      },
                    ),
                  )


                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
///
///
///
///
///
///
///
///
///
///
///
///
///
///

///
// class FinanceScreen extends StatefulWidget {
//   FinanceScreen({
//     super.key,
//   });
//
//   @override
//   State<FinanceScreen> createState() => _FinanceScreenState();
// }
//
// class _FinanceScreenState extends State<FinanceScreen> {
//   TextEditingController nameController = TextEditingController();
//   TextEditingController addressController = TextEditingController();
//   TextEditingController payRatesController = TextEditingController();
//   TextEditingController perMilesController = TextEditingController();
//   TextEditingController fixedPayRatesController = TextEditingController();
//   TextEditingController dummyCtrl = TextEditingController();
//   final StreamController<List<PayRatesGetByServiceId>> _payRatesController =
//   StreamController<List<PayRatesGetByServiceId>>();
//
//   String? _selectedZone;
//   int currentPage = 1;
//   final int itemsPerPage = 10;
//   List<PayRatesGet> _fullPayRatesList = [];
//   String _selectedOption = 'Option 1';
//   int docZoneId = 0;
//   String? docAddVisitTypeId;
//   int docVisitTypeId = 0;
//   int empTypeId = 0;
//   bool _isLoading = false;
//   int? selectedServiceId;
//   bool isServiceSelected = false;
//   String? selectedServiceName;
//   int? firstServiceId;
//   String? abbrivtionName;
//   int? employeeTypeId;
//   int? firstEmployeeTypeId;
//   String abbNameVal = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _loadPayRatesData();
//   }
//
//   void _loadPayRatesData() async {
//     try {
//       List<PayRatesGet> data = await companyPayratesGet(context);
//       setState(() {
//         _fullPayRatesList = data;
//       });
//     } catch (error) {
//     }
//   }
//
//   String serviceId = "";
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 12),
//         child: Column(
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Clinicians Pay Rates',
//                   style: DefineWorkWeekStyle.customTextStyle(context),
//                 ),
//               ],
//             ),
//             const SizedBox(
//               height: AppSize.s30,
//             ),
//             Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Pick Service Type',
//                       style: DefineWorkWeekStyle.customTextStyle(context),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: MediaQuery.of(context).size.height / 100),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     ///disabled container
//                     Row(
//                       children: [
//                         FutureBuilder<List<ServicesMetaData>>(
//                           future: getServicesMetaData(context),
//                           builder: (context, snapshot) {
//                             if (snapshot.connectionState == ConnectionState.waiting) {
//                               return Container(
//                                 width: AppSize.s300,
//                                 height: AppSize.s30,
//                                 decoration: BoxDecoration(
//                                   border: Border.all(
//                                       color: ColorManager.containerBorderGrey,
//                                       width: AppSize.s1),
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     SizedBox(width: AppSize.s8),
//                                     Expanded(
//                                       child: Text(
//                                         "",
//                                         style: MobileMenuText.MenuTextConst(
//                                             context),
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.only(right: 10),
//                                       child: Icon(Icons.arrow_drop_down),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             }
//                             if (snapshot.data!.isEmpty) {
//                               return Container(
//                                 width: AppSize.s300,
//                                 height: AppSize.s30,
//                                 decoration: BoxDecoration(
//                                   border: Border.all(
//                                       color: ColorManager.containerBorderGrey,
//                                       width: AppSize.s1),
//                                   borderRadius: BorderRadius.circular(5),
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: AppPadding.p10, vertical: AppPadding.p5),
//                                   child: Text(
//                                     ErrorMessageString.noserviceAdded,
//                                     style:
//                                     ConstTextFieldRegister.customTextStyle(
//                                         context),
//                                   ),
//                                 ),
//                               );
//                             }
//                             if (snapshot.hasData) {
//                               List<DropdownMenuItem<String>>
//                               dropDownServiceList = [];
//                               for (var service in snapshot.data!) {
//                                 dropDownServiceList.add(
//                                   DropdownMenuItem<String>(
//                                     value: service.serviceName,
//                                     child: Text(service.serviceName ?? ''),
//                                   ),
//                                 );
//                               }
//                               if (selectedServiceName == null &&
//                                   dropDownServiceList.isNotEmpty) {
//                                 selectedServiceName =
//                                     dropDownServiceList[0].value;
//                                 selectedServiceId = firstServiceId;
//                               }
//                               serviceId = snapshot.data![0].serviceId;
//
//                               return StatefulBuilder(
//                                 builder: (BuildContext context,
//                                     void Function(void Function()) setState) {
//                                   return CICCDropdown(
//                                     width: AppSize.s300,
//                                     initialValue: selectedServiceName,
//                                     onChange: (val) {
//                                       setState(() {
//                                         selectedServiceName = val;
//                                         for (var service in snapshot.data!) {
//                                           if (service.serviceName == val) {
//                                             // selectedServiceId =
//                                             //     service.officeServiceId;
//                                             serviceId = service.serviceId;
//                                           }
//                                         }
//                                       });
//                                     },
//                                     items: dropDownServiceList,
//                                   );
//                                 },
//                               );
//                             }
//                             return const SizedBox();
//                           },
//                         ),
//                         SizedBox(
//                           width: AppSize.s10,
//                         ),
//                         FutureBuilder<List<HRAllData>>(
//                           future:
//                           getAllHrDeptWise(context, AppConfig.clinicalId),
//                           builder: (context, snapshotAbbreavition) {
//                             if (snapshotAbbreavition.connectionState ==
//                                 ConnectionState.waiting) {
//                               return Container(
//                                 width: AppSize.s300,
//                                 height: AppSize.s30,
//                                 decoration: BoxDecoration(
//                                   border: Border.all(
//                                       color: ColorManager.containerBorderGrey,
//                                       width: AppSize.s1),
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     SizedBox(width: AppSize.s8),
//                                     Expanded(
//                                       child: Text(
//                                         "",
//                                         style: MobileMenuText.MenuTextConst(
//                                             context),
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.only(right: 10),
//                                       child: Icon(Icons.arrow_drop_down),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             }
//                             if (snapshotAbbreavition.data!.isEmpty) {
//                               return Container(
//                                 width: AppSize.s300,
//                                 height: AppSize.s30,
//                                 child: Center(
//                                   child: Text(
//                                     ErrorMessageString.noserviceAdded,
//                                     style:
//                                     ConstTextFieldRegister.customTextStyle(
//                                         context),
//                                   ),
//                                 ),
//                               );
//                             }
//                             if (snapshotAbbreavition.hasData) {
//                               List<DropdownMenuItem<String>> dropDownTypesList =
//                               [];
//                               int docType = 0;
//
//                               for (var i in snapshotAbbreavition.data!) {
//                                 dropDownTypesList.add(
//                                   DropdownMenuItem<String>(
//                                     value: i.abbrivation,
//                                     child: Text(i.abbrivation!),
//                                   ),
//                                 );
//                               }
//                               abbNameVal =
//                               snapshotAbbreavition.data![0].abbrivation!;
//                               empTypeId =
//                                   snapshotAbbreavition.data![0].employeeTypesId;
//                               return StatefulBuilder(
//                                 builder: (BuildContext context,
//                                     void Function(void Function()) setState) {
//                                   return CICCDropdown(
//                                     width: AppSize.s300,
//                                     initialValue: abbNameVal,
//                                     onChange: (val) {
//                                       setState(() {
//                                         abbNameVal = val!;
//                                         for (var a
//                                         in snapshotAbbreavition.data!) {
//                                           if (a.abbrivation == val) {
//                                             docType = a.employeeTypesId;
//                                             empTypeId = docType;
//                                             //_selectButton(1);
//                                           }
//                                         }
//                                       });
//                                     },
//                                     items: dropDownTypesList,
//                                   );
//                                 },
//                               );
//                             }
//                             return const SizedBox();
//                           },
//                         )
//                       ],
//                     ),
//                     // SizedBox(width: 10,),
//                     CustomIconButton(
//                       text: AddPopupString.addPayrate,
//                       icon: Icons.add,
//                       onPressed: () async {
//                         payRatesController.clear();
//                         perMilesController.clear();
//                         fixedPayRatesController.clear();
//                         showDialog(
//                           context: context,
//                           builder: (BuildContext context) {
//                             String serviceTypeId = serviceId;
//                             return ChangeNotifierProvider(
//                               create: (_) => PayRatesProvider(),
//                               child: PayRateAddPopup(
//                                 serviceId: serviceTypeId,
//                                 empTypeId: empTypeId,
//                                 fixPayRatesController: fixedPayRatesController,
//                                 visitTypeTextActive: true,
//                                 payRatesController: payRatesController,
//                                 perMilesController: perMilesController,
//                                 title: AddPopupString.addPayrate,
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(
//               height: 15,
//             ),
//             const TableHeadConstant(
//               items: [
//                 TableHeadItem(text: AppStringEM.srNo, textAlign: TextAlign.center),
//                 TableHeadItem(text: AppStringEM.typeVisit, textAlign: TextAlign.start),
//                 TableHeadItem(text: AppStringEM.rate, textAlign: TextAlign.center),
//                 TableHeadItem(text: AppStringEM.actions, textAlign: TextAlign.center),
//               ],
//             ),
//             SizedBox(
//               height: AppSize.s5,
//             ),
//
//             /// List
//             Expanded(
//               child: StreamBuilder<List<PayRatesGetByServiceId>>(
//                 stream: _payRatesController.stream,
//                 //companyPayratesGet(context);
//                 builder: (context, snapshot) {
//                   companyPayratesGetByServiceAndEmployeeId(
//                       context: context,
//                       serviceId: serviceId!,
//                       empId: empTypeId)
//                       .then((data) {
//                     _payRatesController.add(data);
//                   }).catchError((error) {});
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(
//                       child: CircularProgressIndicator(
//                         color: ColorManager.blueprime,
//                       ),
//                     );
//                   }
//                   if (snapshot.data!.isEmpty) {
//                     return Center(
//                       child: Text(
//                         ErrorMessageString.noPayRates,
//                         //AppString.dataNotFound,
//                         style: AllNoDataAvailable.customTextStyle(context),
//                       ),
//                     );
//                   }
//                   if (snapshot.hasData) {
//                     int totalItems = snapshot.data!.length;
//                     int totalPages = (totalItems / itemsPerPage).ceil();
//                     List<PayRatesGetByServiceId> paginatedData = snapshot.data!
//                         .skip((currentPage - 1) * itemsPerPage)
//                         .take(itemsPerPage)
//                         .toList();
//
//                     return Column(
//                       children: [
//                         Expanded(
//                           child: ListView.builder(
//                               scrollDirection: Axis.vertical,
//                               itemCount: paginatedData.length,
//                               itemBuilder: (context, index) {
//                                 int reverseIndex = paginatedData.length - 1 - index;
//                                 int serialNumber = index + 1;
//                                 String formattedSerialNumber = serialNumber.toString().padLeft(2, '0');
//                                 PayRatesGetByServiceId finance = paginatedData[reverseIndex];
//                                 return Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const SizedBox(height: AppSize.s5),
//                                     Container(
//                                         decoration: BoxDecoration(
//                                           color: Colors.white,
//                                           borderRadius: BorderRadius.circular(4),
//                                           boxShadow: [
//                                             BoxShadow(
//                                               color: const Color(0xff000000).withOpacity(0.25),
//                                               spreadRadius: 0,
//                                               blurRadius: 4,
//                                               offset: const Offset(0, 2),
//                                             ),
//                                           ],
//                                         ),
//                                         height: AppSize.s50,
//                                         child: Row(
//                                           mainAxisAlignment:
//                                           MainAxisAlignment.spaceAround,
//                                           children: [
//                                             Expanded(
//                                               child: Center(
//                                                 child: Text(
//                                                   formattedSerialNumber,
//                                                   style:TableSubHeading.customTextStyle(context),
//                                                 ),
//                                               ),
//                                             ),
//                                             Expanded(
//                                               child: Center(
//                                                 child: Text(
//                                                   finance.typeOfVisitId,
//                                                   style: TableSubHeading.customTextStyle(context),
//                                                 ),
//                                               ),
//                                             ),
//                                             Expanded(
//                                               child: Center(
//                                                 child: Text(
//                                                   '\$${finance.rate}',
//                                                   style: TableSubHeading.customTextStyle(context),
//                                                 ),
//                                               ),
//                                             ),
//                                             Expanded(
//                                               child: Center(
//                                                 child: Row(
//                                                   mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                                   children: [
//                                                     IconButton(
//                                                       splashColor: Colors.transparent,
//                                                       highlightColor: Colors.transparent,
//                                                       hoverColor: Colors.transparent,
//                                                       onPressed: () {
//                                                         payRatesController.clear();
//                                                         perMilesController.clear();
//                                                         showDialog(
//                                                           context: context,
//                                                           builder: (BuildContext context) {
//                                                             return FutureBuilder<PayRatePrefillFinanceData>(
//                                                                 future: payPrefillRatesDataGet(context, finance.payratesId),
//                                                                 builder: (context, snapshotPrefill) {
//                                                                   if (snapshotPrefill.connectionState ==
//                                                                       ConnectionState.waiting) {
//                                                                     return Center(
//                                                                       child: CircularProgressIndicator(
//                                                                         color: ColorManager.blueprime,
//                                                                       ),
//                                                                     );
//                                                                   }
//                                                                   var fixPayRates = snapshotPrefill.data?.outOfZoneRate;
//                                                                   var payRates = snapshotPrefill.data?.payratesId;
//                                                                   var visitTypeId = snapshotPrefill.data?.typeOfVisitId;
//                                                                   var perMile = snapshotPrefill.data?.outOfZoneperMile;
//                                                                   print(":::PAYRATESTYPE${visitTypeId}");
//                                                                   fixedPayRatesController = TextEditingController(text: snapshotPrefill.data?.outOfZoneRate.toString());
//                                                                   payRatesController = TextEditingController(text: snapshotPrefill.data?.rate.toString());
//                                                                   perMilesController = TextEditingController(text: snapshotPrefill.data?.outOfZoneperMile.toString());
//                                                                   return ChangeNotifierProvider(
//                                                                     create: (_) => PayRatesEditProvider(),
//                                                                     child: PayRatesEditsPopup(
//                                                                       visitTypeTextActive: false,
//                                                                       title: 'Edit Payrate',
//                                                                       child1: SMTextFConst(
//                                                                         enable: false,
//                                                                         readOnly: true,
//                                                                         controller: TextEditingController(
//                                                                           text: visitTypeId.toString(),
//                                                                         ),
//                                                                         keyboardType: TextInputType.number,
//                                                                         text: 'Type of Visit',
//                                                                       ),
//                                                                       child2: FutureBuilder<List<SortByZoneData>>(
//                                                                           future: PayRateZoneDropdown(context),
//                                                                           builder: (context, snapshot) {
//                                                                             if (snapshot.connectionState == ConnectionState.waiting) {
//                                                                               return CICCDropDownExcel(
//                                                                                 width: AppSize.s354,
//                                                                                 initialValue: 'Select',
//                                                                                 items: [],
//                                                                               );
//                                                                             }
//                                                                             if (snapshot
//                                                                                 .data!
//                                                                                 .isEmpty) {
//                                                                               return Center(
//                                                                                 child: Text(
//                                                                                   AppString.dataNotFound,
//                                                                                   style: AllNoDataAvailable.customTextStyle(context),
//                                                                                 ),
//                                                                               );
//                                                                             }
//                                                                             if (snapshot.hasData) {
//                                                                               List dropDown = [];
//                                                                               int docType = 0;
//                                                                               List<DropdownMenuItem<String>>dropDownTypesList = [];
//                                                                               for (var i in snapshot.data!) {
//                                                                                 dropDownTypesList.add(
//                                                                                   DropdownMenuItem<String>(
//                                                                                     child: Text(i.zoneName),
//                                                                                     value: i.zoneName,
//                                                                                   ),
//                                                                                 );
//                                                                               }
//                                                                               return CICCDropDownExcel(
//                                                                                   initialValue: dropDownTypesList[0].value,
//                                                                                   onChange: (val) {
//                                                                                     for (var a in snapshot.data!) {
//                                                                                       if (a.zoneName == val) {
//                                                                                         docType = a.zoneId;
//                                                                                         docZoneId = docType;
//                                                                                       }
//                                                                                     }
//                                                                                     print(":::${docType}");
//                                                                                     print(":::<>${docZoneId}");
//                                                                                   },
//                                                                                   items: dropDownTypesList);
//                                                                             }
//                                                                             return const SizedBox();
//                                                                           }),
//                                                                       payRatesController: payRatesController,
//                                                                       perMilesController: perMilesController,
//                                                                       fixPayRatesController: fixedPayRatesController,
//                                                                       onPressed: () async {
//                                                                         var response = await updatePayRatesSetupPost(
//                                                                             context: context,
//                                                                             payratesId: finance.payratesId,
//                                                                             rate: payRates == int.parse(payRatesController.text)
//                                                                                 ? payRates!
//                                                                                 : int.parse(payRatesController.text),
//                                                                             typeOfVisitId: visitTypeId!,
//                                                                             outOfZoneperMile: perMile == int.parse(perMilesController.text)
//                                                                                 ? perMile!
//                                                                                 : int.parse(perMilesController.text),
//                                                                             outOfZoneRate: fixPayRates == int.parse(fixedPayRatesController.text)
//                                                                                 ? fixPayRates!
//                                                                                 : int.parse(fixedPayRatesController.text),
//                                                                             serviceId: snapshotPrefill.data!.serviceId);
//                                                                         if(response.statusCode == 200 || response.statusCode == 201){
//                                                                           Navigator.pop(context);
//                                                                           showDialog(
//                                                                             context: context,
//                                                                             builder: (BuildContext context) {
//                                                                               return const AddSuccessPopup(
//                                                                                 message: 'Edit Successfully',
//                                                                               );
//                                                                             },
//                                                                           );
//                                                                         }else if(response.statusCode == 400 || response.statusCode == 404){
//                                                                           Navigator.pop(context);
//                                                                           showDialog(
//                                                                             context: context,
//                                                                             builder: (BuildContext context) => const FourNotFourPopup(),
//                                                                           );
//                                                                         }
//                                                                         else {
//                                                                           Navigator.pop(context);
//                                                                           showDialog(
//                                                                             context: context,
//                                                                             builder: (BuildContext context) => FailedPopup(text: response.message),
//                                                                           );
//                                                                         }
//                                                                         payRatesController.clear();
//                                                                         perMilesController.clear();
//                                                                         fixedPayRatesController.clear();
//                                                                       },
//                                                                     ),
//                                                                   );
//                                                                 });
//                                                           },
//                                                         );
//                                                       },
//                                                       icon: Icon(
//                                                         Icons.edit_outlined,
//                                                         size: IconSize.I18,
//                                                         color: ColorManager.blueprime,
//                                                       ),
//                                                     ),
//                                                     IconButton(
//                                                         splashColor: Colors.transparent,
//                                                         highlightColor: Colors.transparent,
//                                                         hoverColor: Colors.transparent,
//                                                         onPressed: () {
//                                                           showDialog(
//                                                               context: context,
//                                                               builder: (context) =>
//                                                                   StatefulBuilder(
//                                                                     builder: (BuildContext
//                                                                     context,
//                                                                         void Function(void Function())
//                                                                         setState) {
//                                                                       return DeletePopup(
//                                                                           title:
//                                                                           'Delete Pay Rates',
//                                                                           loadingDuration:
//                                                                           _isLoading,
//                                                                           onCancel:
//                                                                               () {
//                                                                             Navigator.pop(context);
//                                                                           },
//                                                                           onDelete:
//                                                                               () async {
//                                                                             setState(() {
//                                                                               _isLoading = true;
//                                                                             });
//                                                                             try {
//                                                                               await deletePayRatesId(context, finance.payratesId);
//                                                                               Navigator.pop(context);
//                                                                               showDialog(context: context, builder: (context) => DeleteSuccessPopup());
//                                                                             } finally {
//                                                                               setState(() {
//                                                                                 _isLoading = false;
//                                                                               });
//                                                                             }
//                                                                           });
//                                                                     },
//                                                                   ));
//                                                         },
//                                                         icon: Icon(
//                                                           Icons.delete_outline_outlined,
//                                                           size: IconSize.I18,
//                                                           color: ColorManager.red,
//                                                         ))
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                             SizedBox(width: AppSize.s30),
//                                           ],
//                                         )),
//                                   ],
//                                 );
//                               }),
//                         ),
//                         PaginationControlsWidget(
//                           currentPage: currentPage,
//                           items: snapshot.data!,
//                           itemsPerPage: itemsPerPage,
//                           onPreviousPagePressed: () {
//                             setState(() {
//                               currentPage =
//                               currentPage > 1 ? currentPage - 1 : 1;
//                             });
//                           },
//                           onPageNumberPressed: (pageNumber) {
//                             setState(() {
//                               currentPage = pageNumber;
//                             });
//                           },
//                           onNextPagePressed: () {
//                             setState(() {
//                               currentPage = currentPage < totalPages
//                                   ? currentPage + 1
//                                   : totalPages;
//                             });
//                           },
//                         ),
//                         SizedBox(height: AppSize.s10),
//                       ],
//                     );
//                   }
//                   return const Offstage();
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

