import 'dart:async';

import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/add_employee/clinical_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/register_manager/main_register_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/add_employee/clinical.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/register_data/main_register_screen_data.dart';

import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/company_identity/company_identity_data_.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/zone/zone_model_data.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/form_banking_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/form_licenses_screen.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/company_identrity_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/zone_manager.dart';
import 'package:flutter/material.dart';

import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/employeement_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/progress_form_manager/form_banking_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/progress_form_manager/form_licenses_manager.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';

class HrRegisterProvider extends ChangeNotifier {
  String _selectedValue = 'Sort';
  bool _load = false;
  bool get load => _load;
  String get selectedValue => _selectedValue;

  /// ✅ SEARCH + PAGINATION state (sent to the API)
  String _searchText = '';
  int _pageNumber = 1;
  int _numberOfRows = 9999;

  String get searchText => _searchText;
  int get pageNumber => _pageNumber;
  int get numberOfRows => _numberOfRows;

  List<RegisterDataCompID> _allData = [];
  List<RegisterDataCompID> get allData => _allData;

  /// ✅ Last data pushed to the stream — used by the UI as a cache so the
  /// list never flashes/blanks while a refetch is in flight.
  List<RegisterDataCompID> _lastEmitted = [];
  List<RegisterDataCompID> get lastEmitted => _lastEmitted;

  /// ✅ Fetch token — if the user types fast, several fetches can overlap;
  /// only the LATEST response is applied, stale ones are dropped.
  int _fetchToken = 0;
  //final registerController = ValueNotifier<List<RegisterDataCompID>>([]);

  final StreamController<List<RegisterDataCompID>> _registerController = StreamController.broadcast();
  Stream<List<RegisterDataCompID>> get registerStream  => _registerController.stream;

  List<AEClinicalDiscipline>? _clinicalDisciplines;
  List<AEClinicalCity>? _clinicalCities;
  List<CompanyOfficeListData>? _companyOffices;
  List<AEClinicalZone>?  _zone;

  List<AEClinicalDiscipline> get clinicalDisciplines => _clinicalDisciplines!;
  List<AEClinicalCity> get clinicalCities => _clinicalCities!;
  List<CompanyOfficeListData> get companyOffices => _companyOffices!;
  List<AEClinicalZone> get zone => _zone!;

  Future<void> fetchDropdownData(BuildContext context,) async {
    _load = true;
    notifyListeners();

    try {
      // _clinicalDisciplines = await HrAddEmplyClinicalDisciplinApi(context, 1);
      _clinicalCities = await HrAddEmplyClinicalCityApi(context);
      _companyOffices = await getCompanyOfficeList(context);
      _zone = await HrAddEmplyClinicalZoneApi(context);
    } catch (e) {
      debugPrint("Error fetching dropdown data: $e");
    }

    _load = false;
    notifyListeners();
  }

  void loaderTrue(){
    _load = true;
    notifyListeners();
  }
  void loaderFalse(){
    _load = false;
    notifyListeners();
  }
  /// Main fetch data
  Future<void> fetchData(BuildContext context,[String? value]) async {
    //_isLoading = true;
    //notifyListeners();
    if(value == 'Sort'){
      _selectedValue = 'Sort';
      notifyListeners();
    }

    // ✅ mark this request; if a newer one starts, this one's result is stale
    final int token = ++_fetchToken;

    try {
      // ✅ pass current search text + pagination to the API through the provider
      List<RegisterDataCompID> data = await GetRegisterByCompId(
        context: context,
        searchText: _searchText,
        page: _pageNumber,
        noRows: _numberOfRows,
      );

      // ✅ a newer fetch was started while this one was running → ignore
      // this (stale) response so old results never overwrite new ones
      if (token != _fetchToken) return;

      _allData = data;
      // ✅ re-apply active status filter after every refresh,
      // so the list stays consistent after enroll/delete/activate etc.
      _applyFilters();
    } catch (error) {
      // Handle error
      debugPrint('Error fetching data: $error');
    } finally {
      //_isLoading = false;
      notifyListeners();
    }
  }

  /// Sort data status wise
  void updateSelectedValue(String newValue) {
    _selectedValue = newValue;
    filterData();
    notifyListeners();
  }

  /// ✅ SEARCH — call this from the search TextField onChanged.
  /// Resets to page 1 and refetches from the API with the new search text.
  void searchRegister(BuildContext context, String query) {
    _searchText = query.trim();
    _pageNumber = 1;
    fetchData(context);
  }

  /// ✅ PAGINATION — call this from PaginationControlsWidget callbacks.
  /// Refetches the requested page from the API.
  void changePage(BuildContext context, int page) {
    if (page < 1) page = 1;
    _pageNumber = page;
    fetchData(context);
  }

  /// Optional: change rows per page
  void changeRowsPerPage(BuildContext context, int noRows) {
    _numberOfRows = noRows;
    _pageNumber = 1;
    fetchData(context);
  }

  void filterData() {
    // kept for backward compatibility — now delegates to combined filter
    _applyFilters();
  }

  /// ✅ STATUS filter pushed to the stream
  /// (search is now handled server-side by the API via searchText)
  void _applyFilters() {
    List<RegisterDataCompID> result = _allData;

    String selectedStatus = _selectedValue.trim().toLowerCase();
    if (selectedStatus != 'sort') {
      result = result.where((data) {
        String dataStatus = data.status.trim().toLowerCase();
        return dataStatus == selectedStatus;
      }).toList();
    }

    _lastEmitted = result; // ✅ cache for flicker-free rebuilds
    _registerController.add(result);
  }

  bool deleteLoad = false;

  void deleteLoaderTrue() {
    deleteLoad = true;
    notifyListeners();
  }

  void deleteLoaderFalse() {
    deleteLoad = false;
    notifyListeners();
  }

}

const String kDropdownPlaceholder = 'Select';

class HrEnrollEmployeeProvider extends ChangeNotifier{
  String? _positionError;
  String? _zoneError;
  String? _reportingOfficeError;
  String? _cityError;
  String? _phoneError;
  String? _firstnameError;
  String? _lastnameError;
  String? _emailError;
  String? _specialityError;
  String? _clinicalType;
  bool _isFormValid = true;
  String? _expiryTypeError;
  String _generatedURL = '';
  bool _load = false;

  bool isLoading = true;
  List<EnrollServices> _enrollService = [];
  List<AEClinicalDiscipline> _clinicalDisciplines = [];
  List<AllCountyByOfficeId> _allContyList = [];
  String _selectCounty = 'Select';
  List<AllZoneData> _zoneByCounty = [];

  String get generatedURL => _generatedURL;
  String get selectCounty => _selectCounty;
  bool get load => _load;
  String? get clinicalType => _clinicalType;
  String? get positionError => _positionError;
  String? get zoneError => _zoneError;
  String? get reportingOfficeError => _reportingOfficeError;
  String? get cityError => _cityError;
  String? get phoneError => _phoneError;
  String? get firstnameError => _firstnameError;
  String? get lastnameError => _lastnameError;
  String? get emailError => _emailError;
  String? get specialityError => _specialityError;
  String? get expiryTypeError => _expiryTypeError;

  bool get isFormValid => _isFormValid;
  List<EnrollServices> get enrollService => _enrollService;
  List<AEClinicalDiscipline> get clinicalDisciplines => _clinicalDisciplines;
  List<AllCountyByOfficeId> get allCountyRecord => _allContyList;
  List<AllZoneData> get zoneByCounty => _zoneByCounty;

  void fetchSelectCounty({required BuildContext context, required String countyName}){
    _selectCounty = countyName;
    notifyListeners();
  }
  void fetchZoneDropdown(BuildContext context,int countyId) async {
    _zoneByCounty = await getZoneByCountyId(context: context, countyId: countyId);
    notifyListeners();
  }
  void fetchDeptDropdownData(BuildContext context,int deptId) async {
    _clinicalDisciplines = await HrAddEmplyClinicalDisciplinApi(context, deptId);
  }
  void fetchOfficeWiseCounty(BuildContext context, String officeId) async{
    _allContyList = await getCountyByCompanyId(context,officeId);
    notifyListeners();
  }
  void loaderTrue(){
    _load = true;
    notifyListeners();
  }
  void loaderFalse(){
    _load = false;
    notifyListeners();
  }

  Future<String> generateUrlLink() async {
    final String url = '${AppConfig.endpoint}/#/onBordingWelcome';
    _generatedURL = url;
    print('Generated URL: $_generatedURL');
    return url;
  }

  ///
  void validateField(String value, String fieldName, Function(String?) setError) {
    if (value.trim().isEmpty || value == kDropdownPlaceholder) {
      setError(fieldName);
      _isFormValid = false;
    } else {
      setError(null);
    }
    notifyListeners();
  }

  void enrollServicesList(BuildContext context) async{
    _enrollService = await EmpServiceRadioButtonApi(context);
    notifyListeners();
  }
  // Specific setters for each field error
  void setPositionError(String? error) {
    _positionError = error;
    notifyListeners();
  }

  void setPhoneError(String? error) {
    _phoneError = error;
    notifyListeners();
  }

  void setSpecialityError(String? error) {
    _specialityError = error;
    notifyListeners();
  }

  void setFirstnameError(String? error) {
    _firstnameError = error;
    notifyListeners();
  }

  void setLastnameError(String? error) {
    _lastnameError = error;
    notifyListeners();
  }

  void setEmailError(String? error) {
    _emailError = error;
    notifyListeners();
  }
  void setZoneError(String? error) {
    _zoneError = error;
    notifyListeners();
  }
  void setReportingOfficeError(String? error) {
    _reportingOfficeError = error;
    notifyListeners();
  }
  void setCityError(String? error) {
    _cityError = error;
    notifyListeners();
  }

  void setClinicalTypeError(String? error) {
    _clinicalType = error;
    notifyListeners();
  }
  void validateFields({
    required String position,
    required String phone,
    required String speciality,
    required String firstName,
    required String lastName,
    required String email,
    required String clinicalType,
    required String repoartingOffice,
    required String zone,
    required String city
  }) {
    _isFormValid = true;

    validateField(position, 'Please enter position. ', (error) {
      _positionError = error;
      if (error != null) _isFormValid = false;
    });
    validateField(phone, 'Please enter phone number. ', (error) {
      _phoneError = error;
      if (error != null) _isFormValid = false;
    });
    // ✅ speciality is a dropdown now → message changed to "Select"
    validateField(speciality, 'Please select speciality. ', (error) {
      _specialityError = error;
      if (error != null) _isFormValid = false;
    });
    validateField(firstName, 'Please enter first name. ', (error) {
      _firstnameError = error;
      if (error != null) _isFormValid = false;
    });
    validateField(lastName, 'Please enter last name. ', (error) {
      _lastnameError = error;
      if (error != null) _isFormValid = false;
    });
    validateField(email, 'Please enter email. ', (error) {
      _emailError = error;
      if (error != null) _isFormValid = false;
    });

    validateField(clinicalType, 'Please select clinical type. ', (error) {
      _clinicalType = error;
      if (error != null) _isFormValid = false;
    });
    validateField(zone, 'Please select zone. ', (error) {
      _zoneError = error;
      if (error != null) _isFormValid = false;
    });
    validateField(repoartingOffice, 'Please select reporting office. ', (error) {
      _reportingOfficeError = error;
      if (error != null) _isFormValid = false;
    });
    validateField(city, 'Please select county. ', (error) {
      _cityError = error;
      if (error != null) _isFormValid = false;
    });

    notifyListeners();
  }

  void clearValidationText(){
    _positionError = null;
    _phoneError = null;
    _specialityError = null;
    _firstnameError = null;
    _lastnameError = null;
    _emailError = null;
    _clinicalType = null;
    _reportingOfficeError = null;
    _zoneError = null;
    _cityError = null;
    notifyListeners();
  }
}

class HrProgressMultiStape extends ChangeNotifier{
  bool _isGneralSaved = false;
  bool _isEducationSaved = false;
  bool _isEmployeementSaved = false;
  bool _isLicenseSaved = false;
  bool _isBankingSaved = false;
  bool _isReferenceSaved = false;
  bool _isClicalLicenseSaved = false;
  bool _isHealthRecordSaved = false;
  bool _isAckRecordSaved = false;


  bool get isGneralSaved => _isGneralSaved;
  bool get isEducationSaved => _isEducationSaved;
  bool get isEmployeementSaved => _isEmployeementSaved;
  bool get isLicenseSaved => _isLicenseSaved;
  bool get isBankingSaved => _isBankingSaved;
  bool get isReferenceSaved => _isReferenceSaved;
  bool get isClicalLicenseSaved => _isClicalLicenseSaved;
  bool get isHealthRecordSaved => _isHealthRecordSaved;
  bool get isAckRecordSaved => _isAckRecordSaved;


  void isGeneralChnaged(){
    _isGneralSaved = true;
    notifyListeners();
  }

  void isEducationChnaged(){
    _isEducationSaved = true;
    notifyListeners();
  }

  void isEmployeementChnaged(){
    _isEmployeementSaved = true;
    notifyListeners();
  }

  void isLicenseChnaged(){
    _isLicenseSaved = true;
    notifyListeners();
  }

  void isReferenceChnaged(){
    _isReferenceSaved = true;
    notifyListeners();
  }

  void isBankingChnaged(){
    _isBankingSaved = true;
    notifyListeners();
  }

  void isClinicalLicenseChnaged(){
    _isClicalLicenseSaved = true;
    notifyListeners();
  }

  void isHealthRecordChnaged(){
    _isHealthRecordSaved = true;
    notifyListeners();
  }

  void isAckRecordChnaged(){
    _isAckRecordSaved = true;
    notifyListeners();
  }
}




// class SaveResult {
//   final int saved;
//   final int failed;
//   SaveResult({required this.saved, required this.failed});
// }

class HRLicenseProvider with ChangeNotifier {
  bool isLoading = false;

  Future<SaveResult> saveLicenses({
    required List<GlobalKey<licensesFormState>> licenseFormKeys,
    required int employeeId,
    required BuildContext context,
  }) async {
    isLoading = true;
    notifyListeners();

    int savedCount = 0;
    int failedCount = 0;
    String? lastErrorMessage; // NEW

    for (var key in licenseFormKeys) {
      final st = key.currentState;
      if (st == null || st.isPrefill) {
        print('⚠️ Skipping prefilled or null form.');
        continue;
      }

      final hasFile = st.finalPath != null && st.finalPath!.isNotEmpty;

      if (hasFile && st.fileAbove20Mb) {
        print('❌ Skipped: File is too large.');
        await showDialog(
          context: context,
          builder: (_) => const AddErrorPopup(message: 'File is too large!'),
        );
        failedCount++;
        lastErrorMessage = 'File is too large!'; // NEW
        continue;
      }

      final selectedDocumentType = (st.documentTypeName == 'Select') ? '--' : (st.documentTypeName ?? 'NA');
      final selectedCountry = (st.selectedCountry == 'Select') ? '--' : (st.selectedCountry ?? 'NA');

      try {
        final response = await postlicensesscreenData(
          context,
          selectedCountry,
          employeeId,
          st.controllerExpirationDate.text,
          st.controllerIssueDate.text,
          'NA',
          st.licensure.text,
          st.licensurenumber.text,
          st.org.text,
          selectedDocumentType,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('✅ License form saved.');
          savedCount++;

          if (hasFile) {
            try {
              await uploadlinceses(
                context: context,
                employeeid: employeeId,
                documentFile: st.finalPath,
                documentName: st.fileName ?? 'Document',
                licensedId: response.licenses!,
              );
              print('📎 Document uploaded for licenseId: ${response.licenses}');
            } catch (e) {
              print('❌ Document upload failed: $e');
              // NEW: treat a failed document upload as a save failure too —
              // previously this was swallowed and still counted as success
              failedCount++;
              lastErrorMessage = AppString.somethingWentWrong;
            }
          }
        } else {
          print('❌ Error saving form: ${response.message}');
          failedCount++;
          lastErrorMessage = response.message; // NEW

          if (response.fieldErrors != null && response.fieldErrors!.isNotEmpty) {
            st.applyFieldErrors(response.fieldErrors!);
          }
        }
      } catch (e) {
        print('License save error: $e');
        failedCount++;
        lastErrorMessage = AppString.somethingWentWrong; // NEW
      }
    }

    isLoading = false;
    notifyListeners();

    return SaveResult(
      saved: savedCount,
      failed: failedCount,
      lastErrorMessage: lastErrorMessage, // NEW
    );
  }
}



class HRBankingProvider with ChangeNotifier {
  bool isLoading = false;

  Future<SaveResult> saveBankingDetails({
    required List<GlobalKey<BankingFormState>> bankingFormKeys,
    required int employeeId,
    required BuildContext context,
  }) async {
    isLoading = true;
    notifyListeners();

    int savedCount = 0;
    int failedCount = 0;
    String? lastErrorMessage; // NEW

    for (var key in bankingFormKeys) {
      final st = key.currentState;

      if (st == null || st.isPrefill) {
        failedCount++;
        continue;
      }

      try {
        final isFileSelected = st.finalPath != null && st.finalPath!.isNotEmpty;

        if (isFileSelected && st.fileAbove20Mb) {
          await showDialog(
            context: context,
            builder: (_) => const AddErrorPopup(message: 'File is too large!'),
          );
          failedCount++;
          lastErrorMessage = 'File is too large!'; // NEW
          continue;
        }

        final response = await postbankingscreenData(
          context,
          employeeId,
          st.accountnumber.text,
          st.bankname.text,
          int.parse(st.requestammount.text),
          "",
          st.effectivecontroller.text,
          st.routingnumber.text,
          st.selectedtype.toString(),
          '',
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.banckingId != null && isFileSelected) {
            await uploadcheck(
              context: context,
              employeeid: employeeId,
              empBankingId: response.banckingId!,
              documentFile: st.finalPath!,
              documentName: st.fileName!,
            );
          }

          savedCount++;
        } else {
          print('Banking save failed: ${response.message}');
          failedCount++;
          lastErrorMessage = response.message; // NEW

          if (response.fieldErrors != null && response.fieldErrors!.isNotEmpty) {
            st.applyFieldErrors(response.fieldErrors!);
          }
        }
      } catch (e) {
        print('Banking save error: $e');
        failedCount++;
        lastErrorMessage = AppString.somethingWentWrong; // NEW
      }
    }

    isLoading = false;
    notifyListeners();

    return SaveResult(
      saved: savedCount,
      failed: failedCount,
      lastErrorMessage: lastErrorMessage, // NEW
    );
  }
}

class SaveResult {
  final int saved;
  final int failed;
  final String? lastErrorMessage; // NEW

  SaveResult({
    required this.saved,
    required this.failed,
    this.lastErrorMessage, // NEW
  });
}