import 'dart:async';

import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/onboarding_manager/onboarding_banking_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/onboarding_manager/qualification_bar_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/see_all/see_all_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/onboarding_data/onboarding_banking_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/onboarding_data/onboarding_qualification_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/see_all_data/see_all_data.dart';

class HrOnboardingProvider extends ChangeNotifier {
  List<SeeAllData> _allData = [];
  String _selectedValue = 'Sort';
  String _trimmedAddress = '';
  String _displayStatus = '--';
  Color? _color;
  final StreamController<List<SeeAllData>> _generalController = StreamController<List<SeeAllData>>.broadcast();
  final StreamController<List<OnboardingQualificationEmploymentData>> _qualificationempStreamController =
  StreamController<List<OnboardingQualificationEmploymentData>>.broadcast();
  final StreamController<List<OnboardingQualificationEducationData>> _educationStreamController = StreamController<List<OnboardingQualificationEducationData>>.broadcast();
  final StreamController<List<OnboardingQualificationReferanceData>> _referenceStreamController = StreamController<List<OnboardingQualificationReferanceData>>.broadcast();
  final StreamController<List<OnboardingQualificationLicenseData>> _licenseStreamController = StreamController<List<OnboardingQualificationLicenseData>>.broadcast();
  final StreamController<List<OnboardingBankingData>> _bankingStreamController = StreamController<List<OnboardingBankingData>>.broadcast();

  // NEW: debounce timer for search
  Timer? _searchDebounce;

  StreamController<List<SeeAllData>> get generalController => _generalController;
  StreamController<List<OnboardingQualificationReferanceData>> get referenceStreamController => _referenceStreamController;
  StreamController<List<OnboardingBankingData>> get bankingStreamController => _bankingStreamController;
  StreamController<List<OnboardingQualificationLicenseData>> get licenseStreamController => _licenseStreamController;
  StreamController<List<OnboardingQualificationEmploymentData>> get qualificationempStreamController => _qualificationempStreamController;
  StreamController<List<OnboardingQualificationEducationData>> get educationStreamController => _educationStreamController;
  Color? get color => _color;
  String get displayStatus => _displayStatus;
  String get selectedValue => _selectedValue;
  List<SeeAllData> get allData => _allData;
  String get trimmedAddress => _trimmedAddress;
  OverlayEntry? _overlayEntryAddress;

  // NEW: generic overlay entry for the width-based hover tooltips used by
  // QualificationEmployment's _adaptiveValue (and any other tab that needs
  // a plain "hover to see full value" tooltip, distinct from the
  // address-specific overlay above).
  OverlayEntry? _overlayEntry;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners(); // This triggers UI rebuild
  }

  void trimAddress(String address) {
    const int maxLength = 15;
    if (address.length > maxLength) {
      _trimmedAddress = '${address.substring(0, maxLength)}...';
    }
    else {
      _trimmedAddress = address;
    }
    notifyListeners();
  }


  void getStreamData(BuildContext context){
    getEmployeeSeeAll(context, searchText: '').then((data) {
      final filteredData = data.where((item) =>
      item.status == 'Partial' ||
          item.status == 'Enrolled' ||
          item.status == 'Completed').toList();

      _allData = filteredData;

      _generalController.add(allData);
    }).catchError((error) {
      print('Error fetching data: $error');
    });
    notifyListeners();
  }

  // NEW: search directly via API using provided searchText
  void searchData(BuildContext context, String searchText) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      getEmployeeSeeAll(context, searchText: searchText).then((data) {
        final filteredData = data.where((item) =>
        item.status == 'Partial' ||
            item.status == 'Enrolled' ||
            item.status == 'Completed').toList();

        _allData = filteredData;
        _currentPage = 1; // reset to first page on new search
        _generalController.add(_allData);
        notifyListeners();
      }).catchError((error) {
        print('Error searching data: $error');
      });
    });
  }

  void filterData() {
    if (_selectedValue == 'Sort') {
      // Show all data.
      _generalController.add(allData);
    } else {
      // Filter data based on selected status.
      List<SeeAllData> filteredData = allData.where((data) {
        String status = data.status == 'Enrolled' ? 'Opened' : data.status ?? '';
        return data.status?.toLowerCase() == _selectedValue.toLowerCase();
      }).toList();
      _generalController.add(filteredData);
    }
    notifyListeners();
  }

  void sortData(String? newValue){
    _selectedValue = newValue!;
    filterData(); // Call filter method on dropdown selection.
    notifyListeners();
  }

  void getColorStatus(String? status){
    _color = getStatusColor(status);
    notifyListeners();
  }
  Color getStatusColor(String? status) {
    switch (status) {
      case 'Opened':
      case 'Enrolled':
        return ColorManager.blueprime;
      case 'Partial':
        return const Color(0xffCA8A04);
      case 'Completed':
        return ColorManager.greenF;
      default:
        return  ColorManager.greenF;
    }

  }
  void showOverlayAddress(BuildContext context, Offset position, String address) {
    _overlayEntryAddress = OverlayEntry(
      builder: (context) => Positioned(
        left: 300,
        top: position.dy + 15, // Adjust to position below the text
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 250,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 2),
              ],
            ),
            child: Text(
              address, // Display the actual address here
              style: ThemeManagerAddressPB.customTextStyle(context),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntryAddress!);
  }

  void removeOverlayAddress() {
    _overlayEntryAddress?.remove();
    _overlayEntryAddress = null;
  }

  // FIX: rewritten to match showOverlayAddress's style — white background,
  // subtle box shadow, dark87 text — instead of the old bare-Material
  // white Container with no shadow and ThemeManagerDarkFont styling (which
  // resolves to a light/white text color meant for dark surfaces, and is
  // what rendered as the black-background tooltip on screen). Also
  // dropped the fixed width: 150 in favor of a maxWidth constraint so
  // longer values (like full addresses/country names) aren't clipped
  // inside the tooltip itself, and moved top offset to dy + 15 to match
  // showOverlayAddress's spacing.
  void showOverlay(BuildContext context, Offset position, String text) {
    removeOverlay(); // clear any existing overlay first

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy + 15,
        child: Material(
          color: Colors.transparent,
          elevation: 8.0,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
            constraints: const BoxConstraints(maxWidth: 300),
            child: Text(
              text,
              style: ThemeManagerDarkFont.customTextStyle(context),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }


  /// Qualification employeement
  void getEmployeeData(BuildContext context, int employeeId){
    getOnboardingQualificationEmp(context, employeeId, "no").then((data) {
      _qualificationempStreamController.add(data);
    }).catchError((error) {});
    notifyListeners();
  }

  /// Qualification education
  void getEducationData(BuildContext context, int employeeId){
    getOnboardingQualificationEducation(context, employeeId,'no').then((data){
      _educationStreamController.add(data);
    }).catchError((error){});
    notifyListeners();
  }

  /// Qualification reference
  void getReferenceData(BuildContext context, int employeeId){
    getOnboardingQualificationReference(context, employeeId,'no').then((data){
      _referenceStreamController.add(data);
    }).catchError((error){});
    notifyListeners();
  }

  /// Qualification license
  void getLicenseData(BuildContext context, int employeeId){
    getOnboardingQualificationLicense(context, employeeId,'no').then((data) {
      _licenseStreamController.add(data);
    }).catchError((error) {});
    notifyListeners();
  }

  /// Banking
  void getBankingData(BuildContext context, int employeeId){
    getOnboardingBanking(context, employeeId,'no').then((data){
      bankingStreamController.add(data);
    }).catchError((error){});
    notifyListeners();
  }

  // NEW: cancel debounce timer on dispose
  @override
  void dispose() {
    _searchDebounce?.cancel();
    _overlayEntry?.remove();
    super.dispose();
  }
}