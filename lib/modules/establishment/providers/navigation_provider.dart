import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/google_aotopromt_api_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/licenses_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/add_employee/clinical.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/licenses_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';


class RouteProvider with ChangeNotifier {
  String _currentRoute = '/';
  String get currentRoute => _currentRoute;

  RouteProvider() {
    _loadLastRoute();
  }

  /// Constant route management
  Future<void> _loadLastRoute() async {
    final prefs = await SharedPreferences.getInstance();
    _currentRoute = prefs.getString('lastRoute') ?? '/';
    notifyListeners();
  }
  Future<void> setRoute(String route) async {
    _currentRoute = route;
    notifyListeners();
    print("route set to $route");

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastRoute', route);
  }

  /// Navigator provider
  void navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void navigateWithData(BuildContext context, Widget Function(BuildContext) pageBuilder) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: pageBuilder),
    );
  }
}

/// HR provider
class HrManageProvider extends ChangeNotifier {

  // FIX: disposed flag — set true before stream close in dispose()
  bool _isDisposed = false;

  // FIX: safe notify — never calls notifyListeners after disposed
  void _safeNotify() {
    if (!_isDisposed) notifyListeners();
  }

  /// Profile bar
  String _trimmedAddress = '';
  String _trimmedSummery = '';
  String _trimmedZoneList = '';
  String _maskedString = '';
  String _hireDateTimeStamp = '';
  String _dateOfBirthStamp = '';
  OverlayEntry? _overlayEntryAddress;
  OverlayEntry? _overlayEntrySummery;
  OverlayEntry? _overlayEntryZoneList;
  final StreamController<Map<String, int>> _licenseStreamController =
  StreamController<Map<String, int>>.broadcast();
  Stream<Map<String, int>> get licenseStream => _licenseStreamController.stream;
  int _expiredCount = 0;
  int _upToDateCount = 0;
  int _aboutToCount = 0;

  int get expiredCount => _expiredCount;
  int get upToDateCount => _upToDateCount;
  int get aboutToCount => _aboutToCount;
  String get hireDateTimeStamp => _hireDateTimeStamp;
  String get maskedString => _maskedString;
  String get trimmedAddress => _trimmedAddress;
  String get trimmedSummery => _trimmedSummery;
  String get trimmedZone => _trimmedZoneList;
  String get dateOfBirthStamp => _dateOfBirthStamp;

  /// Tab bar private variables HR
  int _currentTab = 0;
  int _qulificationModuleTab = 0;
  int _documentsModuleTab = 0;

  int get currentTab => _currentTab;
  int get qulificationModuleTab => _qulificationModuleTab;
  int get documentsModuleTab => _documentsModuleTab;

  /// qualification employment
  String _trimmedEmployeeAddress = '';
  String _trimmedSupervisor = '';
  bool _isOverlayVisible = false;
  OverlayEntry? _overlayEntry;
  String get trimmedEmployeeAddress => _trimmedEmployeeAddress;
  String get trimmedSupervisor => _trimmedSupervisor;

  /// qualification education
  String _trimmedDegree = '';
  String _trimmedCollege = '';
  String _trimmedMajor = '';

  String get trimmedDegree => _trimmedDegree;
  String get trimmedCollege => _trimmedCollege;
  String get trimmedMajor => _trimmedMajor;

  /// qualification reference
  String _trimmedCompanyName = '';
  String _trimmedTitle = '';
  String _trimmedReference = '';

  String get trimmedCompanyName => _trimmedCompanyName;
  String get trimmedTitle => _trimmedTitle;
  String get trimmedReference => _trimmedReference;

  /// Qualification license
  String _trimmedOrg = '';

  String get trimmedOrg => _trimmedOrg;

  /// Documents ack
  bool _fileAbove20Mb = false;
  String _fileName = '';
  dynamic _filePath;
  List<DropdownMenuItem<String>> _dropDownMenuItems = [];
  bool _load = false;
  bool _isFormSubmitted = false;
  bool _editFileAbove20Mb = false;
  bool _fileIsPicked = false;
  bool _isSubmitted = false;
  String _editFileName = '';
  dynamic _editFilePath;
  dynamic _editClinicalLicenseFilePath;
  String _editClinicalLicenseFileName = '';
  bool _clinicalFileIsPicked = false;
  List<DropdownMenuItem<String>> get dropDownMenuItems => _dropDownMenuItems;
  bool get fileAbove20Mb => _fileAbove20Mb;
  bool get isFormSubmitted => _isFormSubmitted;
  bool get isSubmitted => _isSubmitted;
  bool get load => _load;
  String get fileName => _fileName;
  bool _showExpiryDateField = false;
  bool _showAddAckExpiryDateField = false;
  bool _showAddDocExpiryDateField = false;
  DateTime? _datePicked;

  // FIX: tracks whether pickDateValue()'s showDatePicker call is currently
  // open. showDatePicker pushes its own route on top of whatever popup
  // called it, and a screen-resize handler in that popup can only safely
  // pop the calendar first (then the popup) if it knows the calendar is
  // actually showing. Exposed as a getter so callers (e.g.
  // CustomDocumedEditPopup) can check it before popping.
  bool _isDatePickerOpen = false;
  bool get isDatePickerOpen => _isDatePickerOpen;

  String get editClinicalLicenseFileName => _editClinicalLicenseFileName;
  dynamic get editClinicalLicenseFilePath => _editClinicalLicenseFilePath;
  bool get clinicalFileIsPicked => _clinicalFileIsPicked;
  DateTime get datePicked => _datePicked!;
  bool get showExpiryDateField => _showExpiryDateField;
  bool get showAddAckExpiryDateField => _showAddAckExpiryDateField;
  bool get showAddDocExpiryDateField => _showAddDocExpiryDateField;
  dynamic get filePath => _filePath;
  bool get editFileAbove20Mb => _editFileAbove20Mb;
  bool get fileIsPicked => _fileIsPicked;
  String get editFileName => _editFileName;
  dynamic get editFilePath => _editFilePath;

  void listenData() {
    _safeNotify();
  }
  void isFormSubmited() {
    _isFormSubmitted = true;
    _safeNotify();
  }
  void loaderTrue() {
    _load = true;
    _safeNotify();
  }
  void loaderFalse() {
    _load = false;
    _safeNotify();
  }
  void loadDropDown(List dataList) {
    _dropDownMenuItems = dataList
        .map((doc) => DropdownMenuItem<String>(
      value: doc.documentName,
      child: Text(doc.documentName),
    ))
        .toList();
    _safeNotify();
  }

  /// Main Tab bar methods
  void setTab(int tabIndex) {
    _currentTab = tabIndex;
    _safeNotify();
  }

  /// Qualification tab bar
  void setQulificationModuleTab(int tabIndex) {
    _qulificationModuleTab = tabIndex;
    _safeNotify();
  }

  /// Document Tab bar
  void setDocumentsModuleTab(int tabIndex) {
    _documentsModuleTab = tabIndex;
    _safeNotify();
  }

  String _line1 = '';
  String _line2 = '';
  String _tooltipText = '';

  String get line1 => _line1;
  String get line2 => _line2;
  get tooltipText => _tooltipText;

  void updateAddress(String address) {
    const int line1MaxLength = 27;

    if (address.length > line1MaxLength) {
      _line1 = '${address.substring(0, line1MaxLength)}...';
      _tooltipText = address;
    } else {
      _line1 = address;
      _tooltipText = address;
    }
    _line2 = ''; // no longer rendered, kept empty/unused
    _safeNotify();
  }

  /// HR profile trim summary
  void updateSummery(String symmery) {
    const int maxLength = 15;
    if (symmery.length > maxLength) {
      _trimmedSummery = '${symmery.substring(0, maxLength)}...';
    } else {
      _trimmedSummery = symmery;
    }
    _safeNotify();
  }

  ///
  void updateZone(String zone) {
    const int maxLength = 19;
    if (zone.length > maxLength) {
      _trimmedZoneList = '${zone.substring(0, maxLength)}...';
    } else {
      _trimmedZoneList = zone;
    }
    _safeNotify();
  }

  /// HR profile bar mask number
  void maskString(String input, int visibleDigits) {
    int maskLength = input.length - visibleDigits;
    if (maskLength > 0) {
      String masked = '*' * maskLength;
      _maskedString = masked + input.substring(maskLength);
    } else {
      _maskedString = input;
    }
    _safeNotify();
  }

  /// HR profile bar hire date trim
  void calculateHireDateTimeStamp(String hireDate) {
    if (hireDate.isEmpty || hireDate == '--') {
      _hireDateTimeStamp = '';
      _safeNotify();
      return;
    }
    try {
      DateTime convertedDate = DateTime.parse(hireDate);
      DateTime today = DateTime.now();
      int years = today.year - convertedDate.year;
      int months = today.month - convertedDate.month;
      int days = today.day - convertedDate.day;

      if (days < 0) {
        months--;
        int prevMonthLastDay = DateTime(today.year, today.month, 0).day;
        days += prevMonthLastDay;
      }
      if (months < 0) {
        years--;
        months += 12;
      }
      _hireDateTimeStamp = "$years yr, $months m, $days d";
      _safeNotify();
    } catch (e) {
      _hireDateTimeStamp = '';
      _safeNotify();
    }
  }

  /// HR date of birth calculate
  void calculateAge(String birthDate) {
    if (birthDate.isEmpty || birthDate == '--') {
      _dateOfBirthStamp = '';
      _safeNotify();
      return;
    }
    try {
      DateTime convertedDate = DateTime.parse(birthDate);
      DateTime today = DateTime.now();

      int years = today.year - convertedDate.year;
      int months = today.month - convertedDate.month;
      int days = today.day - convertedDate.day;

      if (days < 0) {
        months--;
        int prevMonthLastDay = DateTime(today.year, today.month, 0).day;
        days += prevMonthLastDay;
      }
      if (months < 0) {
        years--;
        months += 12;
      }
      String result = "$years yr, $months m, $days d";
      print("dobTimestamp: $_dateOfBirthStamp");
      print('Calculated Age: $result');
      _dateOfBirthStamp = result;
      _safeNotify();
    } catch (e) {
      _dateOfBirthStamp = '';
      _safeNotify();
    }
  }

  /// Address overlay entry
  void showOverlayAddress(BuildContext context, Offset position, String finalAddress) {
    _overlayEntryAddress = OverlayEntry(
      builder: (context) => Positioned(
        left: 300,
        top: position.dy + 15,
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
              finalAddress,
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

  /// Summary overlay entry
  void showSummeryOverlay(BuildContext context, Offset position, String summery) {
    _overlayEntrySummery = OverlayEntry(
      builder: (context) => Positioned(
        right: 300,
        top: position.dy + 20,
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
              summery,
              style: ProfileBarTextBoldStyle.customEditTextStyle(),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context)?.insert(_overlayEntrySummery!);
  }
  void removeSummeryOverlay() {
    _overlayEntrySummery?.remove();
    _overlayEntrySummery = null;
  }

  /// zoneList overlay entry
  void showZoneListOverlay(BuildContext context, Offset position, String zoneList) {
    _overlayEntryZoneList = OverlayEntry(
      builder: (context) => Positioned(
        left: 300,
        top: position.dy + 15,
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
              zoneList,
              style: ProfileBarTextBoldStyle.customEditTextStyle(),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context)?.insert(_overlayEntryZoneList!);
  }
  void removeZoneListOverlay() {
    _overlayEntryZoneList?.remove();
    _overlayEntryZoneList = null;
  }

  /// Color converter
  bool isDarkColor(Color color) {
    double perceivedBrightness =
        color.red * 0.299 + color.red * 0.587 + color.blue * 0.114;
    return perceivedBrightness < 128;
  }

  /// License stream broadcast in profileBar HR

  /// FIX: generation counter — bumping it cancels any running fetch loop.
  /// Every loop remembers the generation it started with and exits as soon
  /// as a newer generation exists (new employee selected, or data cleared).
  int _licenseFetchGeneration = 0;

  void clearLicenseData() {
    _licenseFetchGeneration++; // FIX: stop any running fetch loop
    _expiredCount = 0;
    _aboutToCount = 0;
    _upToDateCount = 0;
    _safeNotify();
  }

// FIX: _isDisposed guards throughout the loop
  void fetchLicenseData(BuildContext context, int employeeId) async {
    // FIX: claim a new generation — this also kills any previous loop,
    // so calling fetchLicenseData twice can never run two loops at once.
    final int myGeneration = ++_licenseFetchGeneration;

    while (true) {
      // FIX: stop loop if disposed, stream closed, or superseded
      if (_isDisposed) break;
      if (_licenseStreamController.isClosed) break;
      if (myGeneration != _licenseFetchGeneration) break;

      try {
        Map<String, List<LicensesData>> data =
        await getLicenseStatusWise(context, employeeId);

        // FIX: check again after async gap (incl. superseded)
        if (_isDisposed) break;
        if (myGeneration != _licenseFetchGeneration) break;

        final newExpired = data['Expired']?.length ?? 0;
        final newAboutTo = data['About to Expire']?.length ?? 0;
        final newUpToDate = data['Upto date']?.length ?? 0;

        // FIX: only emit when something actually changed — no more
        // identical re-emissions every 3 seconds causing rebuilds
        final changed = newExpired != _expiredCount ||
            newAboutTo != _aboutToCount ||
            newUpToDate != _upToDateCount;

        _expiredCount = newExpired;
        _aboutToCount = newAboutTo;
        _upToDateCount = newUpToDate;

        if (changed && !_licenseStreamController.isClosed && !_isDisposed) {
          _licenseStreamController.add({
            'Expired': _expiredCount,
            'About to Expire': _aboutToCount,
            'Upto date': _upToDateCount,
          });
          _safeNotify();
        }
      } catch (error) {
        print("Error fetching license data: $error");
        // FIX: on error, DO NOT emit zeros — keep showing the last good
        // counts and just retry on the next cycle. Emitting zeros here
        // was the direct cause of the 0 -> 1 -> 0 -> 1 blinking.
      }

      // FIX: check before delay and before looping
      if (_isDisposed) break;
      if (_licenseStreamController.isClosed) break;
      if (myGeneration != _licenseFetchGeneration) break;

      await Future.delayed(const Duration(seconds: 3));
    }
  }

  // FIX: @override added, _isDisposed set BEFORE close, super.dispose() replaces notifyListeners()
  @override
  void dispose() {
    _isDisposed = true;
    _licenseStreamController.close();
    super.dispose();
  }

  /// Qualification employment
  void trimEmpAddress(String empAddress) {
    const int maxLength = 22;
    if (empAddress.length > maxLength) {
      _trimmedEmployeeAddress = '${empAddress.substring(0, maxLength)}...';
    } else {
      _trimmedEmployeeAddress = empAddress;
    }
    _safeNotify();
  }
  void trimSupervisor(String supervisor) {
    const int maxLength = 22;
    if (supervisor.length > maxLength) {
      _trimmedSupervisor = '${supervisor.substring(0, maxLength)}...';
    } else {
      _trimmedSupervisor = supervisor;
    }
    _safeNotify();
  }

  OverlayEntry _createOverlayEntry(BuildContext context, Offset position, String text) {
    return OverlayEntry(
      builder: (context) {
        return Positioned(
          left: position.dx,
          top: position.dy + 15,
          child: Material(
            color: Colors.transparent,
            elevation: 8.0,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(
                text,
                style: ThemeManagerDarkFont.customTextStyle(context),
              ),
            ),
          ),
        );
      },
    );
  }
  // Show overlay
  void showOverlay(BuildContext context, Offset position, String text) {
    if (_isOverlayVisible) return;
    _overlayEntry = _createOverlayEntry(context, position, text);
    Overlay.of(context)?.insert(_overlayEntry!);
    _isOverlayVisible = true;
  }

  // Remove overlay
  void removeOverlay() {
    if (_overlayEntry != null && _isOverlayVisible) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isOverlayVisible = false;
    }
  }

  /// qualification Education
  void trimDegreeString(String degree) {
    const int maxLength = 22;
    if (degree.length > maxLength) {
      _trimmedDegree = '${degree.substring(0, maxLength)}...';
    } else {
      _trimmedDegree = degree;
    }
    _safeNotify();
  }
  void trimCollegeString(String college) {
    const int maxLength = 22;
    if (college.length > maxLength) {
      _trimmedCollege = '${college.substring(0, maxLength)}...';
    } else {
      _trimmedCollege = college;
    }
    _safeNotify();
  }
  void trimMajorString(String major) {
    const int maxLength = 22;
    if (major.length > maxLength) {
      _trimmedMajor = '${major.substring(0, maxLength)}...';
    } else {
      _trimmedMajor = major;
    }
    _safeNotify();
  }

  /// Qualification reference
  void trimCompanyString(String company) {
    const int maxLength = 22;
    if (company.length > maxLength) {
      _trimmedCompanyName = '${company.substring(0, maxLength)}...';
    } else {
      _trimmedCompanyName = company;
    }
    _safeNotify();
  }
  void trimTitleString(String title) {
    const int maxLength = 22;
    if (title.length > maxLength) {
      _trimmedTitle = '${title.substring(0, maxLength)}...';
    } else {
      _trimmedTitle = title;
    }
    _safeNotify();
  }
  void trimReferenceString(String reference) {
    const int maxLength = 22;
    if (reference.length > maxLength) {
      _trimmedReference = '${reference.substring(0, maxLength)}...';
    } else {
      _trimmedReference = reference;
    }
    _safeNotify();
  }

  /// Qualification license
  void trimOrgString(String org) {
    const int maxLength = 22;
    if (org.length > maxLength) {
      _trimmedOrg = '${org.substring(0, maxLength)}...';
    } else {
      _trimmedOrg = org;
    }
    _safeNotify();
  }

  /// Documents ack
  void pickAckFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    final fileSize = result?.files.first.size;
    final isAbove20MB = fileSize! > (20 * 1024 * 1024);
    if (result != null) {
      _filePath = result.files.first.bytes;
      _fileName = result.files.first.name;
      _fileAbove20Mb = !isAbove20MB;
      _safeNotify();
    }
  }
  // Document constant edit
  void pickEditFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['pdf']);
    final fileSize = result?.files.first.size;
    final isAbove20MB = fileSize! > (20 * 1024 * 1024);
    if (result != null) {
      _fileIsPicked = true;
      _editFilePath = result.files.first.bytes;
      _editFileName = result.files.first.name;
      _editFileAbove20Mb = !isAbove20MB;
      _safeNotify();
    }
  }
  void assignedValue(String fileName) {
    _editFileName = fileName;
    _safeNotify();
  }
  void showExpDateFieldAck() {
    _showAddAckExpiryDateField = true;
    _safeNotify();
  }
  void showExpDateFieldAckFalse() {
    _showAddAckExpiryDateField = false;
    _safeNotify();
  }
  void showExpDateFieldDoc() {
    _showAddDocExpiryDateField = true;
    _safeNotify();
  }
  void showExpDateFieldDocFalse() {
    _showAddDocExpiryDateField = false;
    _safeNotify();
  }
  void clearAddedValue() {
    _showAddDocExpiryDateField = false;
    _showAddAckExpiryDateField = false;
    _editFileAbove20Mb = false;
    _isFormSubmitted = false;
    _fileAbove20Mb = false;
    _fileIsPicked = false;
    _clinicalFileIsPicked = false;
    _showExpiryDateField = false;
    _editClinicalLicenseFilePath;
    _editClinicalLicenseFileName = '';
    _editFilePath = null;
    _editFileName = '';
    _filePath = null;
    _fileName = '';
    _safeNotify();
  }

  TextEditingController _expiryDateController = TextEditingController();
  TextEditingController get expiryDateController => _expiryDateController;

  void editDocumentValue(String selectedExpiryType, String? expiryDate,
      TextEditingController controller) {
    if (selectedExpiryType == FrontendConfigStore.data?.config.issuer) {
      print('Expiry date on provider ${expiryDate}');
      DateTime dateTime =
      DateTime.parse(expiryDate ?? DateTime.now().toString());
      _showExpiryDateField = true;
      _datePicked = dateTime;
      _expiryDateController = TextEditingController(
          text: DateFormat('yyyy-MM-dd').format(dateTime));
      _safeNotify();
    } else {
      _showExpiryDateField = false;
    }
  }

  void pickDateValue(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // FIX: mark the calendar as open so callers (e.g.
    // CustomDocumedEditPopup's resize-close handler) know to pop it first
    // before popping their own route.
    _isDatePickerOpen = true;
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(3101),
    );
    _isDatePickerOpen = false;
    if (pickedDate != null) {
      newDatePicked(pickedDate);
      _expiryDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
    _safeNotify();
  }

  void newDatePicked(DateTime value) {
    _datePicked = value;
    _safeNotify();
  }

  /// Clinical License and P license
  void pickClinicalEditFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['pdf']);
    final fileSize = result?.files.first.size;
    final isAbove20MB = fileSize! > (20 * 1024 * 1024);
    if (result != null) {
      _clinicalFileIsPicked = true;
      _editClinicalLicenseFilePath = result.files.first.bytes;
      _editClinicalLicenseFileName = result.files.first.name;
      _editFileAbove20Mb = !isAbove20MB;
      _safeNotify();
    }
  }
  void isSumitted() {
    _isSubmitted = true;
    _safeNotify();
  }
  void getFileName(String fileName) {
    _editClinicalLicenseFileName = fileName;
    _safeNotify();
  }
}

class AddressProvider with ChangeNotifier {
  final TextEditingController controller;
  final Function(String)? onChange;
  final Function(double, double)? onLatLngFetched;
  List<String> _suggestions = [];
  OverlayEntry? _overlayEntry;
  AddressProvider(
      {required this.controller,
        required this.onChange,
        this.onLatLngFetched}) {
    controller.addListener(_onAddressChanged);
  }
  // Latitude and longitude variables
  double? latitudeL;
  double? longitudeL;

  List<String> get suggestions => _suggestions;

  void disposeProvider() {
    controller.removeListener(_onAddressChanged);
    removeOverlay();
  }

  Future<void> _onAddressChanged() async {
    final query = controller.text;

    if (onChange != null) onChange!(query);

    if (query.isEmpty) {
      _suggestions = [];
      removeOverlay();
      notifyListeners();
      return;
    }

    final suggestions = await fetchSuggestions(query);
    if (suggestions.isNotEmpty && suggestions[0] != query) {
      _suggestions = suggestions;
      notifyListeners();
    } else {
      _suggestions = [];
      removeOverlay();
    }
    notifyListeners();
  }

  // Getters for latitude and longitude
  double? get latitude => latitudeL;
  double? get longitude => longitudeL;

  /// Method to fetch latitude and longitude from the selected address
  Future<void> getLatLngFromAddress(String address) async {
    final String apiKey = AppConfig.googleApiKey;
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          latitudeL = location['lat'];
          longitudeL = location['lng'];
          notifyListeners();
          if (onLatLngFetched != null) {
            onLatLngFetched!(latitudeL!, longitudeL!);
          }
          notifyListeners();
          print("Latitude: $latitude, Longitude: $longitude");
          print('Get location lat: $latitudeL and long: $longitudeL');
        } else {
          print("No coordinates found for this address.");
        }
      } else {
        print("Failed to fetch coordinates: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching lat/lng: $e");
    }
  }

  void showOverlay(BuildContext context) {
    removeOverlay();

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: removeOverlay,
            child: Container(
              color: Colors.transparent,
            ),
          ),
          Positioned(
            left: position.dx,
            top: position.dy + renderBox.size.height,
            width: renderBox.size.width,
            child: Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_suggestions[index]),
                      onTap: () {
                        controller.text = _suggestions[index];
                        removeOverlay();
                        notifyListeners();
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }
}