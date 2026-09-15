import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/string_manager.dart';
import 'package:symmetry_establishment/modules/establishment/providers/navigation_provider.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/licenses_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/profile_mnager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/employee_profile/search_profile_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/licenses_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/profile_bar/widget/expired_license_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/profile_bar/widget/profile_clipoval_const.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/profile_bar/widget/profil_custom_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/profile_bar/offerlatter_download_helper.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/download_doc_get_api/download_doc_get_api.dart';

typedef EditCallback = void Function();

class ProfileBar extends StatefulWidget {
  const ProfileBar({
    super.key,
    this.searchByEmployeeIdProfileData,
    required this.onEditPressed,
  });
  final SearchByEmployeeIdProfileData? searchByEmployeeIdProfileData;
  final VoidCallback onEditPressed;

  @override
  State<ProfileBar> createState() => _ProfileBarState();
}

class _ProfileBarState extends State<ProfileBar> {
  late HrManageProvider _profileState;
  int? _initializedForEmployeeId;
  bool _isDownloading = false; // add to your State class

  /// *** BLINK FIX: cache of the last real (non-empty) license counts.
  /// On reload the provider first emits cleared counts (all 0) and then
  /// the fetched counts — showing every emission directly is what caused
  /// the 0 -> 1 -> 0 -> 1 blinking. We keep the last non-empty map and
  /// only replace it when new real data arrives.
  Map<String, int> _lastCounts = <String, int>{};

  // FIX: cache these Futures once instead of calling the repository
  // functions inline inside FutureBuilder(future: ...), which re-fires the
  // underlying API call on every rebuild.
  late Future<ProfilePercentage> _percentageFuture;
  late Future<Map<String, List<LicensesData>>> _licenseStatusFuture;

  @override
  void initState() {
    super.initState();
    _percentageFuture = getPercentage(
        context, widget.searchByEmployeeIdProfileData!.employeeId!);
    _licenseStatusFuture = getLicenseStatusWise(
        context, widget.searchByEmployeeIdProfileData!.employeeId!);
    _profileState = Provider.of<HrManageProvider>(context, listen: false);
    // FIX: was calling _initForEmployee() synchronously here. ProfileBar
    // mounts inside a SliverList (see _SelectionKeepAlive in the crash
    // trace), which means initState() can run *while the framework is
    // still in an active layout/build pass*. _initForEmployee() calls
    // provider setters (clearLicenseData, updateAddress, updateSummery,
    // updateZone, etc.) that call notifyListeners() synchronously — and
    // notifying listeners mid-build throws "setState() or markNeedsBuild()
    // called during build" on the shared HrManageProvider's
    // _InheritedProviderScope. Deferring with addPostFrameCallback runs it
    // after the current frame finishes, once it's safe to notify.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initForEmployee();
      }
    });
  }

  @override
  void didUpdateWidget(ProfileBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // FIX: only re-run one-time setup when the employee actually changes —
    // previously this whole block ran inside build() via
    // addPostFrameCallback, so it fired on every single rebuild.
    if (oldWidget.searchByEmployeeIdProfileData?.employeeId !=
        widget.searchByEmployeeIdProfileData?.employeeId) {
      /// BLINK FIX: new employee -> old cached counts are not valid,
      /// clear the cache so we don't show the previous employee's counts.
      _lastCounts = <String, int>{};
      // FIX: also defer here for the same reason as initState — this can
      // run while a parent is still mid-build (e.g. when the employee
      // changes as part of the same rebuild that swaps this widget in).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _initForEmployee();
        }
      });
    }
  }

  @override
  void dispose() {
    // FIX: HrManageProvider is a singleton registered at the app root
    // (main.dart), so it never gets disposed when this screen closes —
    // fetchLicenseData()'s while(true) polling loop would otherwise keep
    // hitting the license API every 3 seconds for the last-viewed employee
    // forever. Bumping the generation counter here stops that loop as soon
    // as ProfileBar unmounts.
    _profileState.clearLicenseData();
    super.dispose();
  }

  void _initForEmployee() {
    final employeeId = widget.searchByEmployeeIdProfileData?.employeeId;
    if (employeeId == null || _initializedForEmployeeId == employeeId) return;
    _initializedForEmployeeId = employeeId;

    // FIX: removed `profileState.dispose();` that used to sit here.
    // ProfileBar does not own this provider — it's the same shared
    // HrManageProvider instance used by ManageScreen, LicensesChildTabbar,
    // and ReferencesChildTabbar (all obtained via
    // Provider.of<HrManageProvider>(context, listen: false)). Calling
    // .dispose() on it here killed the shared ChangeNotifier on every
    // rebuild of this widget, and the very next rebuild's dispose() call
    // threw "A HrManageProvider was used after being disposed" — which is
    // also what was corrupting the layer tree and causing the
    // _debugPreviousLeaders crash. The provider's lifecycle belongs to
    // whichever ancestor created it via ChangeNotifierProvider; Provider
    // disposes it automatically when that ancestor unmounts.
    _profileState.clearLicenseData();
    _profileState.fetchLicenseData(context, employeeId);
    _profileState
        .updateAddress(widget.searchByEmployeeIdProfileData!.finalAddress);
    _profileState.updateSummery(widget.searchByEmployeeIdProfileData!.summary);
    _profileState.updateZone(widget.searchByEmployeeIdProfileData!.zone);
    _profileState.maskString(widget.searchByEmployeeIdProfileData!.SSNNbr, 4);
    if (widget.searchByEmployeeIdProfileData?.dateofHire != null) {
      _profileState.calculateHireDateTimeStamp(
          widget.searchByEmployeeIdProfileData!.dateofHire);
    }
    if (widget.searchByEmployeeIdProfileData?.dateOfBirth != null) {
      _profileState
          .calculateAge(widget.searchByEmployeeIdProfileData!.dateOfBirth);
    }
  }

  static const Color _figmaBlue = Color(0xFF008ABD);
  static const Color _figmaGreen = Color(0xFF1AB595);
  static const Color _figmaSlate = Color(0xFF64748B);
  // Figma: info-row value text and the underlined e-mail links.
  static const Color _figmaInk = Color(0xFF171717);
  /// Half of Plus Jakarta Sans' descent at 11px — see _licenseBadge.
  static const double _countBaselineNudge = 1.4;
  static const Color _figmaLink = Color(0xFF0284C7);

  String _phone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    return value.isEmpty ? '------------' : value;
  }

  Future<void> _openEmail(String email) async {
    if (email.isEmpty) return;
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _downloadOfferLetter() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    final offerData = await downloadEmployeeOfferLatter(
      context: context,
      employeeId: widget.searchByEmployeeIdProfileData!.employeeId!,
    );
    if (offerData != null && offerData.pdfUrl.isNotEmpty && mounted) {
      await downloadPdfFile(
        context: context,
        pdfUrl: offerData.pdfUrl,
        fileName: '${offerData.templateName}_${offerData.employeeId}',
        apiPath: DownloadDocumentRepository
            .getFormHtmlTemplatesStatusDocumentByFileName(),
      );
    } else if (offerData != null && mounted) {
      showDialog(
        context: context,
        builder: (_) => const FailedPopup(
          text: 'No PDF available for this offer letter.',
        ),
      );
    }
    if (mounted) setState(() => _isDownloading = false);
  }

  void _showLicenseList(String title, String key) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680, maxHeight: 560),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'FiraSans',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: FutureBuilder<Map<String, List<LicensesData>>>(
                    future: _licenseStatusFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: _figmaBlue),
                        );
                      }
                      final licenses =
                          snapshot.data?[key] ?? const <LicensesData>[];
                      if (licenses.isEmpty) {
                        return const Center(
                            child: Text('No licenses available.'));
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: licenses.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, index) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: _figmaBlue.withValues(alpha: .10),
                            child: Text('${index + 1}'),
                          ),
                          title: Text(licenses[index].licenseure),
                          trailing: Text(licenses[index].expDate),
                        ),
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
  }

  Widget _profileImage() {
    final data = widget.searchByEmployeeIdProfileData!;
    Widget fallback() => Image.asset(
          'images/profilepic.png',
          fit: BoxFit.cover,
          width: 112,
          height: 112,
        );
    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        border: Border.all(color: _figmaGreen, width: 5),
        borderRadius: BorderRadius.circular(23),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: data.imgurl.isEmpty || data.imgurl == 'imgurl'
            ? fallback()
            : Image.network(
                data.imgurl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback(),
              ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {VoidCallback? onTap}) {
    final valueWidget = Text(
      value.isEmpty ? '-' : value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 17 / 14,
        color: onTap == null ? _figmaInk : _figmaLink,
        decoration: onTap == null ? null : TextDecoration.underline,
        decorationColor: _figmaLink,
      ),
    );
    return SizedBox(
      // Figma has these rows on a 34px pitch; tightened slightly from that.
      height: 31,
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 17 / 14,
                color: _figmaSlate,
              ),
            ),
          ),
          Expanded(
            child: onTap == null
                ? valueWidget
                : InkWell(onTap: onTap, child: valueWidget),
          ),
        ],
      ),
    );
  }

  Widget _licenseBadge({
    required String label,
    required int count,
    required Color color,
    required double width,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        width: width,
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .13),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: manageJakarta(
                fontSize: 12,
                height: 15 / 12,
                color: Colors.black,
              ),
            ),
            Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              // Centring a Text inside the circle centres its *line box*,
              // not the digit. A line box reserves room for descenders
              // (the tail of a 'g'), and digits have none — so that empty
              // strip sits below the glyph and leaves it riding high.
              // textHeightBehavior drops the leading so the box is just
              // ascent+descent, and the translate pushes the glyph down by
              // half the remaining descent to land it optically centred.
              child: Transform.translate(
                offset: const Offset(0, _countBaselineNudge),
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false,
                  ),
                  style: manageJakarta(
                    fontSize: 11,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRedesignedProfileBar(BuildContext context) {
    final data = widget.searchByEmployeeIdProfileData!;
    final canEdit = data.employeeStatus != 'Terminated' &&
        data.employeeStatus != 'Inactive';
    final status = data.employeeStatus.isEmpty
        ? (data.active ? 'Active' : 'Terminated')
        : data.employeeStatus;

    return Consumer<HrManageProvider>(
      builder: (context, providerState, _) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFDEDEDE)),
          borderRadius: BorderRadius.circular(19),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _profileImage(),
                  const SizedBox(width: 22),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '${data.firstName.capitalizeFirst} ${data.lastName.capitalizeFirst}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    height: 24 / 20,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                // Figma: 54 x 20 pill.
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: status == 'Active'
                                      ? _figmaGreen
                                      : const Color(0xFFE05D5F),
                                  borderRadius: BorderRadius.circular(13.5),
                                ),
                                child: Text(
                                  status,
                                  style: manageJakarta(
                                    fontSize: 13,
                                    height: 16 / 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            data.employeeType,
                            style: manageJakarta(
                              fontSize: 12,
                              height: 15 / 12,
                              fontWeight: FontWeight.w500,
                              color: _figmaBlue,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Employment Type : ${data.employment}',
                            style: manageJakarta(
                              fontSize: 12,
                              height: 15 / 12,
                              color: _figmaSlate,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Annual Skills ${data.anualSkill.toStringAsFixed(0)}%',
                            style: manageJakarta(
                              fontSize: 12,
                              height: 15 / 12,
                              color: _figmaSlate,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (canEdit)
                    InkWell(
                      onTap: widget.onEditPressed,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB1B1B1).withValues(alpha: .12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          size: 19,
                          color: Color(0xFF424242),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                height: 69,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9).withValues(alpha: .20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Address :',
                      style: manageJakarta(
                        fontSize: 13,
                        height: 16 / 13,
                        color: const Color(0xFF7C7C7C),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      data.finalAddress.isEmpty ? '-' : data.finalAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: manageJakarta(
                        fontSize: 13,
                        height: 16 / 13,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Divider(height: 1, color: Color(0xFFDEDEDE)),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _infoRow('Age',
                          '${data.dateOfBirth} ( ${providerState.dateOfBirthStamp ?? 'N/A'} )'),
                      _infoRow('Gender', data.gender),
                      _infoRow(
                          'Social Security No', providerState.maskedString),
                      _infoRow('Phone No', _phone(data.primaryPhoneNbr)),
                      _infoRow('Personal No', _phone(data.secondryPhoneNbr)),
                      _infoRow('Work No', _phone(data.workPhoneNbr)),
                      _infoRow(
                        'Personal Email',
                        data.personalEmail,
                        onTap: () => _openEmail(data.personalEmail),
                      ),
                      _infoRow(
                        'Work Email',
                        data.workEmail,
                        onTap: () => _openEmail(data.workEmail),
                      ),
                      _infoRow('Specialty', data.expertise),
                      _infoRow('Service', data.service),
                      _infoRow('Reporting Office', data.regOfficId),
                      _infoRow('Summary', data.summary),
                      _infoRow('Hire Date',
                          '${data.dateofHire} ( ${providerState.hireDateTimeStamp ?? ''} )'),
                      _infoRow('PTA', '1.2'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              StreamBuilder<Map<String, int>>(
                stream: providerState.licenseStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final incoming = snapshot.data!;
                    final allZero =
                        incoming.values.every((value) => value == 0);
                    final hasCachedData =
                        _lastCounts.values.any((value) => value > 0);
                    if (!allZero || !hasCachedData) _lastCounts = incoming;
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _licenseBadge(
                        label: 'Expired License',
                        count: _lastCounts['Expired'] ?? 0,
                        color: const Color(0xFFEF4444),
                        width: 153,
                        onTap: () =>
                            _showLicenseList('Expired License', 'Expired'),
                      ),
                      const SizedBox(height: 6),
                      _licenseBadge(
                        label: 'About To Expired License',
                        count: _lastCounts['About to Expire'] ?? 0,
                        color: const Color(0xFFECBF75),
                        width: 219,
                        onTap: () => _showLicenseList(
                          'About To Expired License',
                          'About to Expire',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _licenseBadge(
                            label: 'Up To Date License',
                            count: _lastCounts['Upto date'] ?? 0,
                            color: _figmaGreen,
                            width: 181,
                            onTap: () => _showLicenseList(
                              'Up To Date License',
                              'Upto date',
                            ),
                          ),
                          SizedBox(
                            width: 153,
                            height: 44,
                            child: ElevatedButton.icon(
                              onPressed:
                                  _isDownloading ? null : _downloadOfferLetter,
                              icon: _isDownloading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : SvgPicture.asset(
                                      'images/offer_letter_icon.svg',
                                      width: 14,
                                      height: 15,
                                    ),
                              label: const Text('Offer Letter'),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: _figmaBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 17 / 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildRedesignedProfileBar(context);
  }

  // Kept temporarily as a reference for the existing popup implementations.
  // ignore: unused_element
  Widget _buildLegacyProfileBar(BuildContext context) {
    var hexColor;

    final profileState = _profileState;
    hexColor = widget.searchByEmployeeIdProfileData?.color.replaceAll("#", "");

    int currentPage = 1;
    int itemsPerPage = 30;
    return Container(
      color: ColorManager.whitebluecolor,
      width: MediaQuery.of(context).size.width / 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ///profile%
          Material(
              elevation: 4,
              child: FutureBuilder<ProfilePercentage>(
                  future: _percentageFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(width: AppSize.s70);
                    }
                    if (snapshot.hasData) {
                      double percentage =
                          double.parse(snapshot.data!.percentage);
                      double maxHeight =
                          200; // Maximum height in pixels for 100%
                      double containerHeight = (percentage / 100) * maxHeight;
                      Color containerColor;
                      if (percentage <= 30) {
                        containerColor = Colors.red;
                      } else if (percentage <= 60) {
                        containerColor = const Color(0xffFEBD4D);
                      } else {
                        containerColor = ColorManager.greenF;
                      }
                      return Container(
                        height: containerHeight,
                        width: AppSize.s70,
                        decoration: BoxDecoration(
                          color: containerColor,
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Profile ${snapshot.data!.percentage}%",
                                style:
                                    ThemeManagerWhite.customTextStyle(context)
                                        .copyWith(
                                  fontSize: (int.tryParse(
                                                  snapshot.data!.percentage) ??
                                              0) <=
                                          10
                                      ? 7
                                      : null,
                                ),
                              ),
                            ]),
                      );
                    } else {
                      return const SizedBox();
                    }
                  })),
          Consumer<HrManageProvider>(builder: (context, providerState, child) {
            return Flexible(
              child: Material(
                elevation: 4,
                child: Container(
                  height: 213,
                  decoration: BoxDecoration(
                    color: ColorManager.whitebluecolor,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSize.s50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ///image
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 70,
                                    width: 70,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Outer grey circle
                                        Container(
                                          height: 70,
                                          width: 70,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: ColorManager.greenF,
                                                width: 2), // Grey border
                                          ),
                                        ),
                                        ClipOval(
                                          child: widget.searchByEmployeeIdProfileData!
                                                          .imgurl ==
                                                      'imgurl' ||
                                                  widget.searchByEmployeeIdProfileData!
                                                          .imgurl ==
                                                      null
                                              ? CircleAvatar(
                                                  radius: 32,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  child: Image.asset(
                                                      "images/profilepic.png"),
                                                )
                                              : Image.network(
                                                  widget
                                                      .searchByEmployeeIdProfileData!
                                                      .imgurl!,
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress ==
                                                        null) {
                                                      return child;
                                                    } else {
                                                      return Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          value: loadingProgress
                                                                      .expectedTotalBytes !=
                                                                  null
                                                              ? loadingProgress
                                                                      .cumulativeBytesLoaded /
                                                                  (loadingProgress
                                                                          .expectedTotalBytes ??
                                                                      1)
                                                              : null,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return CircleAvatar(
                                                      radius: 32,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      child: Image.asset(
                                                          "images/profilepic.png"),
                                                    );
                                                  },
                                                  fit: BoxFit.cover,
                                                  height: 67,
                                                  width: 67,
                                                ),
                                        ),
                                        SizedBox(
                                          height: 70,
                                          width: 70,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    ColorManager.greenF),
                                            strokeWidth: 3,
                                            value: widget
                                                .searchByEmployeeIdProfileData!
                                                .profileScorePercentage,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  widget.searchByEmployeeIdProfileData!.active
                                      ? widget.searchByEmployeeIdProfileData!
                                                  .employeeStatus ==
                                              "Inactive"
                                          ? Text(
                                              "Inactive",
                                              style: ThemeManagerBlack
                                                  .customTextStyle(context),
                                            )
                                          : Text(
                                              "Active",
                                              style: ThemeManagerBlack
                                                  .customTextStyle(context),
                                            )
                                      : widget.searchByEmployeeIdProfileData!
                                                  .employeeStatus ==
                                              "Terminated"
                                          ? Text(
                                              "Terminated",
                                              style: ThemeManagerBlack
                                                  .customTerminatedTextStyle(
                                                      context),
                                            )
                                          : Text(
                                              "Terminated",
                                              style: ThemeManagerBlack
                                                  .customTerminatedTextStyle(
                                                      context),
                                            ),
                                  // SizedBox(height: 15,),
                                  FutureBuilder<ProfilePercentage>(
                                      future: _percentageFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 43.0),
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Annual Skills 0%",
                                                    style: ProfileBarTextBoldStyle
                                                        .customEditTextStyle(),
                                                  ),
                                                ]),
                                          );
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 43.0),
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Annual Skills 0%",
                                                  style: ProfileBarTextBoldStyle
                                                      .customEditTextStyle(),
                                                ),
                                              ]),
                                        );
                                      })
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 50,
                            ),

                            ///edit button column
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 18.0, bottom: 8),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ///text john scott
                                  Row(
                                    children: [
                                      Text(
                                        "${widget.searchByEmployeeIdProfileData!.firstName.capitalizeFirst}"
                                        " ${widget.searchByEmployeeIdProfileData!.lastName.capitalizeFirst}",
                                        style:
                                            ThemeManagerBlack.customTextStyle(
                                                context),
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      widget.searchByEmployeeIdProfileData!
                                                      .employeeStatus ==
                                                  "Terminated" ||
                                              widget.searchByEmployeeIdProfileData!
                                                      .employeeStatus ==
                                                  "Inactive"
                                          ? const Offstage()
                                          : InkWell(
                                              onTap: widget.onEditPressed,
                                              splashColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              child: Icon(
                                                Icons.edit_outlined,
                                                size: 14,
                                                color:
                                                    IconColorManager.blueprime,
                                              )),
                                    ],
                                  ),

                                  Container(
                                    height: 28,
                                    constraints: BoxConstraints(
                                      // never smaller than 70, never wider than needed on big screens
                                      minWidth: 70,
                                      maxWidth: math.max(
                                          MediaQuery.of(context).size.width / 9,
                                          70),
                                    ),
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xff000000)
                                              .withValues(alpha: 0.2),
                                          spreadRadius: 0,
                                          blurRadius: 4,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                      color: Color(int.parse("0xFF$hexColor")),
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 3),
                                        child: FittedBox(
                                          fit: BoxFit
                                              .scaleDown, // shrinks text ONLY if it doesn't fit
                                          child: Text(
                                            widget
                                                .searchByEmployeeIdProfileData!
                                                .employeeType
                                                .capitalizeFirst!,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: providerState.isDarkColor(
                                                      Color(int.parse(
                                                          '0xFF$hexColor')))
                                                  ? ColorManager.white
                                                  : ColorManager.black,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  Row(
                                    children: [
                                      Text(
                                        'Employment Type :',
                                        style: ThemeManagerDark.customTextStyle(
                                            context),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        widget.searchByEmployeeIdProfileData!
                                                .employment[0]
                                                .toUpperCase() +
                                            widget
                                                .searchByEmployeeIdProfileData!
                                                .employment
                                                .substring(1),
                                        style: ProfileBarTextBoldStyle
                                            .customEditTextStyle(),
                                      ),
                                    ],
                                  ),

                                  MouseRegion(
                                    onEnter: (event) =>
                                        profileState.showZoneListOverlay(
                                            context,
                                            event.position,
                                            widget
                                                .searchByEmployeeIdProfileData!
                                                .zone),
                                    onExit: (_) =>
                                        profileState.removeZoneListOverlay(),
                                    child: Text(
                                      // widget.searchByEmployeeIdProfileData!.zone,
                                      providerState.trimmedZone,
                                      style: ProfileBarTextBoldStyle
                                          .customEditTextStyle(),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      AppString.address,
                                      style: ThemeManagerDark.customTextStyle(
                                          context),
                                    ),
                                  ),

                                  MouseRegion(
                                    onEnter: (event) =>
                                        profileState.showOverlayAddress(
                                            context,
                                            event.position,
                                            widget
                                                .searchByEmployeeIdProfileData!
                                                .finalAddress),
                                    onExit: (_) =>
                                        profileState.removeOverlayAddress(),
                                    child: Container(
                                      height: 30,
                                      // width: double.infinity, // <-- ensures a bounded width to measure against
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            providerState.line1,
                                            textAlign: TextAlign.start,
                                            style: ThemeManagerAddressPB
                                                .customTextStyle(context),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        ///age phone msg
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 10.0, top: 11),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children:
                                    MyConstants.personalInfoTexts(context),
                              ),
                            ),
                            // SizedBox(width: 20),
                            ///age phone message
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 10.0, left: 8, top: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    "${widget.searchByEmployeeIdProfileData!.dateOfBirth} ( ${providerState.dateOfBirthStamp ?? 'N/A'} )",
                                    style: ProfileBarTextBoldStyle
                                        .customEditTextStyle(),
                                  ),
                                  Text(
                                    widget
                                        .searchByEmployeeIdProfileData!.gender,
                                    style: ProfileBarTextBoldStyle
                                        .customEditTextStyle(),
                                  ),
                                  Text(
                                    providerState.maskedString,
                                    style: ProfileBarTextBoldStyle
                                        .customEditTextStyle(),
                                  ),

                                  ///phone, comment
                                  ProfileBarPhoneCmtConst(
                                    phoneNo: widget
                                        .searchByEmployeeIdProfileData!
                                        .primaryPhoneNbr,
                                  ),

                                  ProfileBarPhoneCmtConst(
                                    phoneNo: widget
                                        .searchByEmployeeIdProfileData!
                                        .secondryPhoneNbr,
                                  ),

                                  ProfileBarPhoneCmtConst(
                                    phoneNo: widget
                                        .searchByEmployeeIdProfileData!
                                        .workPhoneNbr,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        //  SizedBox(width: MediaQuery.of(context).size.width/50),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 10.0, top: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: MyConstantsColumn.personalInfoTexts(
                                    context),
                              ),
                            ),
                            //SizedBox(width: 20),
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 10.0, left: 8, top: 10),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    child: Text(
                                      widget.searchByEmployeeIdProfileData!
                                              .personalEmail ??
                                          'No email provided',
                                      style: ProfileBarConst.profileTextStyle(
                                          context),
                                    ),
                                    onTap: () async {
                                      String? email = widget
                                          .searchByEmployeeIdProfileData!
                                          .personalEmail;
                                      if (email != null && email.isNotEmpty) {
                                        // Create a mailto Uri with the email address
                                        final Uri emailUri = Uri(
                                          scheme: 'mailto',
                                          path: email,
                                          queryParameters: {
                                            'subject': 'Hello!',
                                            'body':
                                                'I would like to reach out to you.',
                                          },
                                        );

                                        // Launch the email client
                                        if (await canLaunchUrl(emailUri)) {
                                          await launchUrl(emailUri);
                                        } else {
                                          print('Could not launch $emailUri');
                                        }
                                      }
                                    },
                                  ),
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      String? email = widget
                                          .searchByEmployeeIdProfileData!
                                          .workEmail;
                                      if (email != null && email.isNotEmpty) {
                                        final Uri emailUri = Uri(
                                          scheme: 'mailto',
                                          path: email,
                                          queryParameters: {
                                            'subject': 'Hello!',
                                            'body':
                                                'I would like to reach out to you.',
                                          },
                                        );
                                        if (await canLaunchUrl(emailUri)) {
                                          await launchUrl(emailUri);
                                        } else {
                                          print('Could not launch $emailUri');
                                        }
                                      }
                                    },
                                    child: Text(
                                        widget.searchByEmployeeIdProfileData!
                                            .workEmail,
                                        style: ProfileBarConst.profileTextStyle(
                                            context)),
                                  ),
                                  Text(
                                    widget.searchByEmployeeIdProfileData!
                                        .expertise,
                                    style: ProfileBarTextBoldStyle
                                        .customEditTextStyle(),
                                  ),
                                  Text(
                                    widget
                                        .searchByEmployeeIdProfileData!.service,
                                    style: ProfileBarTextBoldStyle
                                        .customEditTextStyle(),
                                  ),
                                  Text(
                                    widget.searchByEmployeeIdProfileData!
                                        .regOfficId,
                                    style: ProfileBarTextBoldStyle
                                        .customEditTextStyle(),
                                  ),
                                  MouseRegion(
                                    onEnter: (event) =>
                                        profileState.showSummeryOverlay(
                                            context,
                                            event.position,
                                            widget
                                                .searchByEmployeeIdProfileData!
                                                .summary),
                                    onExit: (_) =>
                                        profileState.removeSummeryOverlay(),
                                    child: Text(
                                      providerState.trimmedSummery,
                                      style: ProfileBarTextBoldStyle
                                          .customEditTextStyle(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // SizedBox(width: MediaQuery.of(context).size.width/50,),
                        ///hire date pta column
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ///hire date pta
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: IntrinsicWidth(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(AppString.hideDate,
                                                  style: ThemeManagerDark
                                                      .customTextStyle(
                                                          context)),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              Text('PTA :',
                                                  style: ThemeManagerDark
                                                      .customTextStyle(
                                                          context)),
                                            ],
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 8),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${widget.searchByEmployeeIdProfileData!.dateofHire} ( ${providerState.hireDateTimeStamp ?? ''} )",
                                                  style: ProfileBarTextBoldStyle
                                                      .customEditTextStyle(),
                                                ),
                                                const SizedBox(
                                                  height: 15,
                                                ),
                                                Text(
                                                  '1.2',
                                                  style: ProfileBarTextBoldStyle
                                                      .customEditTextStyle(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]),
                                    const SizedBox(height: 12),
                                    StatefulBuilder(builder:
                                        (BuildContext context,
                                            void Function(void Function())
                                                setState) {
                                      return BorderIconProfileButton(
                                        buttonWidth: double.infinity,
                                        iconData: Icons.save_alt_outlined,
                                        buttonText: 'Offer Letter',
                                        onPressed: () async {
                                          if (_isDownloading) return;
                                          setState(() => _isDownloading = true);

                                          final offerData =
                                              await downloadEmployeeOfferLatter(
                                            context: context,
                                            employeeId: widget
                                                .searchByEmployeeIdProfileData!
                                                .employeeId!,
                                          );

                                          if (offerData != null &&
                                              offerData.pdfUrl.isNotEmpty) {
                                            await downloadPdfFile(
                                              context: context,
                                              pdfUrl: offerData.pdfUrl,
                                              fileName:
                                                  '${offerData.templateName}_${offerData.employeeId}',
                                              apiPath: DownloadDocumentRepository
                                                  .getFormHtmlTemplatesStatusDocumentByFileName(),
                                            );
                                          } else if (mounted &&
                                              offerData != null) {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  const FailedPopup(
                                                      text:
                                                          "No PDF available for this offer letter."),
                                            );
                                          }

                                          if (mounted)
                                            setState(
                                                () => _isDownloading = false);
                                        },
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                            // SizedBox(height: 30,),
                            // licenses
                            Flexible(
                              child: Column(
                                children: [
                                  StatefulBuilder(
                                    builder: (BuildContext context,
                                        void Function(void Function())
                                            setState) {
                                      return StreamBuilder<Map<String, int>>(
                                        stream: profileState.licenseStream,
                                        builder:
                                            (BuildContext context, snapshot) {
                                          /// DEBUG: remove after confirming — check console for
                                          /// the actual keys and values your stream emits
                                          print(
                                              'licenseStream emitted: ${snapshot.data}');

                                          /// *** BLINK FIX v2: on reload the provider first emits
                                          /// cleared counts (all zeros) and then the real fetched
                                          /// counts, which made the ovals blink 0 -> 1 -> 0 -> 1.
                                          /// Accept new counts only if they are NOT an all-zero
                                          /// "cleared" emission arriving after we already have
                                          /// real data. Once loaded, the value never drops back
                                          /// to 0 until a real fetch replaces it.
                                          if (snapshot.hasData &&
                                              snapshot.data!.isNotEmpty) {
                                            final incoming = snapshot.data!;
                                            final incomingAllZero = incoming
                                                .values
                                                .every((v) => v == 0);
                                            final haveRealData = _lastCounts
                                                .values
                                                .any((v) => v > 0);
                                            if (!incomingAllZero ||
                                                !haveRealData) {
                                              _lastCounts = incoming;
                                            }
                                          }

                                          final counts = _lastCounts;
                                          final expiredCount =
                                              counts['Expired'] ?? 0;
                                          final aboutToCount =
                                              counts['About to Expire'] ?? 0;
                                          final upToDateCount =
                                              counts['Upto date'] ?? 0;

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                top: 11.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                ///"Expired License"
                                                ProfileBarClipConst(
                                                  onTap: () {
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return ExpiredLicensePopup(
                                                              title:
                                                                  'Expired License',
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  vertical:
                                                                      AppPadding
                                                                          .p3,
                                                                  horizontal:
                                                                      AppPadding
                                                                          .p20,
                                                                ),
                                                                child:
                                                                    SingleChildScrollView(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    children: [
                                                                      Container(
                                                                        height:
                                                                            30,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Colors.grey,
                                                                          borderRadius:
                                                                              BorderRadius.circular(12),
                                                                        ),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal: 18),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceAround,
                                                                            children: [
                                                                              Expanded(
                                                                                child: Center(
                                                                                  child: Text('Sr No.', style: ProfileBarNameLicenseStyle.customEditTextStyle()),
                                                                                ),
                                                                              ),
                                                                              //SizedBox(width: MediaQuery.of(context).size.width/7.5,),
                                                                              Expanded(
                                                                                child: Center(
                                                                                  child: Text('Name Of License', textAlign: TextAlign.start, style: ProfileBarNameLicenseStyle.customEditTextStyle()),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Center(
                                                                                  child: Text('Date', textAlign: TextAlign.start, style: ProfileBarNameLicenseStyle.customEditTextStyle()),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            15,
                                                                      ),
                                                                      FutureBuilder<
                                                                              Map<String, List<LicensesData>>>(
                                                                          future: _licenseStatusFuture,
                                                                          builder: (context, snapshot) {
                                                                            if (snapshot.connectionState ==
                                                                                ConnectionState.waiting) {
                                                                              return Center(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 150),
                                                                                  child: CircularProgressIndicator(
                                                                                    color: ColorManager.blueprime,
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            }

                                                                            /// FIX: guard against error/null before using data!
                                                                            if (snapshot.hasError ||
                                                                                !snapshot.hasData ||
                                                                                snapshot.data!['Expired'] == null ||
                                                                                snapshot.data!['Expired']!.isEmpty) {
                                                                              return Center(
                                                                                  child: Padding(
                                                                                padding: const EdgeInsets.symmetric(vertical: 150),
                                                                                child: Text(
                                                                                  NoDataMessage.noexpiredlicense,
                                                                                  style: AllNoDataAvailable.customTextStyle(context),
                                                                                ),
                                                                              ));
                                                                            }
                                                                            if (snapshot.hasData) {
                                                                              final expiredLicenses = snapshot.data!['Expired']!;
                                                                              //final inactiveLicenses = snapshot.data!['Inactive']!;
                                                                              return Container(
                                                                                height: MediaQuery.of(context).size.height / 2,
                                                                                child: ScrollConfiguration(
                                                                                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                                                                                  child: ListView.builder(
                                                                                      scrollDirection: Axis.vertical,
                                                                                      itemCount: expiredLicenses.length,
                                                                                      itemBuilder: (context, index) {
                                                                                        //profileState.expiredCount = expiredLicenses.length;
                                                                                        print("Expired count :: ${profileState.expiredCount}");
                                                                                        int serialNumber = index + 1 + (currentPage - 1) * itemsPerPage;
                                                                                        String formattedSerialNumber = serialNumber.toString().padLeft(2, '0');
                                                                                        return Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          children: [
                                                                                            // SizedBox(height: 5),
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 3),
                                                                                              child: Container(
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
                                                                                                  height: 50,
                                                                                                  child: Padding(
                                                                                                    padding: const EdgeInsets.only(left: 20, right: 20),
                                                                                                    child: Row(
                                                                                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                                      children: [
                                                                                                        Expanded(
                                                                                                          child: Center(
                                                                                                            child: Text(formattedSerialNumber,
                                                                                                                // formattedSerialNumber,
                                                                                                                style: AboutExpiredLStyle.customEditTextStyle()),
                                                                                                          ),
                                                                                                        ),
                                                                                                        // Text(''),
                                                                                                        Expanded(
                                                                                                          child: Center(
                                                                                                            child: Text(expiredLicenses[index].licenseure, style: AboutExpiredLStyle.customEditTextStyle()),
                                                                                                          ),
                                                                                                        ),
                                                                                                        Expanded(
                                                                                                          child: Center(
                                                                                                            child: Text(expiredLicenses[index].expDate, style: AboutExpiredLStyle.customEditTextStyle()),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                  )),
                                                                                            ),
                                                                                          ],
                                                                                        );
                                                                                      }),
                                                                                ),
                                                                              );
                                                                            }
                                                                            return const Offstage();
                                                                          }),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ));
                                                        });
                                                  },
                                                  text:
                                                      AppString.expiredlicense,
                                                  // containerColor: Colors.deepOrangeAccent,
                                                  containerColor:
                                                      const Color(0xffD16D6A),

                                                  /// BLINK FIX: read from cached counts
                                                  textOval:
                                                      expiredCount.toString(),
                                                ),
                                                const SizedBox(height: 10),

                                                ///"About To Expired License"
                                                ProfileBarClipConst(
                                                    onTap: () {
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return ExpiredLicensePopup(
                                                                title:
                                                                    'About To Expired License',
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .symmetric(
                                                                    vertical:
                                                                        AppPadding
                                                                            .p3,
                                                                    horizontal:
                                                                        AppPadding
                                                                            .p20,
                                                                  ),
                                                                  child:
                                                                      SingleChildScrollView(
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceEvenly,
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              30,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Colors.grey,
                                                                            borderRadius:
                                                                                BorderRadius.circular(12),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 18),
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                              children: [
                                                                                Expanded(
                                                                                  child: Center(
                                                                                    child: Text('Sr No.', style: ProfileBarNameLicenseStyle.customEditTextStyle()),
                                                                                  ),
                                                                                ),
                                                                                //SizedBox(width: MediaQuery.of(context).size.width/7.5,),
                                                                                Expanded(
                                                                                  child: Center(
                                                                                    child: Text('Name Of License', textAlign: TextAlign.start, style: ProfileBarNameLicenseStyle.customEditTextStyle()),
                                                                                  ),
                                                                                ),
                                                                                Expanded(
                                                                                  child: Center(
                                                                                    child: Text('Date', textAlign: TextAlign.start, style: ProfileBarNameLicenseStyle.customEditTextStyle()),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              15,
                                                                        ),
                                                                        FutureBuilder<Map<String, List<LicensesData>>>(
                                                                            future: _licenseStatusFuture,
                                                                            builder: (context, snapshot) {
                                                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                                                return Center(
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.symmetric(vertical: 150),
                                                                                    child: CircularProgressIndicator(
                                                                                      color: ColorManager.blueprime,
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              }

                                                                              /// FIX: guard against error/null before using data!
                                                                              if (snapshot.hasError || !snapshot.hasData || snapshot.data!['About to Expire'] == null || snapshot.data!['About to Expire']!.isEmpty) {
                                                                                return Center(
                                                                                    child: Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 150),
                                                                                  child: Text(
                                                                                    NoDataMessage.noabouttoexpired,
                                                                                    style: AllNoDataAvailable.customTextStyle(context),
                                                                                  ),
                                                                                ));
                                                                              }
                                                                              if (snapshot.hasData) {
                                                                                final aboutToExpiredLicenses = snapshot.data!['About to Expire']!;
                                                                                //final inactiveLicenses = snapshot.data!['Inactive']!;
                                                                                return Container(
                                                                                  height: MediaQuery.of(context).size.height / 2,
                                                                                  child: ScrollConfiguration(
                                                                                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                                                                                    child: ListView.builder(
                                                                                        scrollDirection: Axis.vertical,
                                                                                        itemCount: aboutToExpiredLicenses.length,
                                                                                        itemBuilder: (context, index) {
                                                                                          int serialNumber = index + 1 + (currentPage - 1) * itemsPerPage;
                                                                                          String formattedSerialNumber = serialNumber.toString().padLeft(2, '0');
                                                                                          return Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              // SizedBox(height: 5),
                                                                                              Padding(
                                                                                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 3),
                                                                                                child: Container(
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
                                                                                                    height: 50,
                                                                                                    child: Padding(
                                                                                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                                                                                      child: Row(
                                                                                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                                        children: [
                                                                                                          Expanded(
                                                                                                            child: Center(
                                                                                                              child: Text(formattedSerialNumber,
                                                                                                                  // formattedSerialNumber,
                                                                                                                  style: AboutExpiredLStyle.customEditTextStyle()),
                                                                                                            ),
                                                                                                          ),
                                                                                                          // Text(''),
                                                                                                          Expanded(
                                                                                                            child: Center(
                                                                                                              child: Text(aboutToExpiredLicenses[index].licenseure, style: AboutExpiredLStyle.customEditTextStyle()),
                                                                                                            ),
                                                                                                          ),
                                                                                                          Expanded(
                                                                                                            child: Center(
                                                                                                              child: Text(aboutToExpiredLicenses[index].expDate, style: AboutExpiredLStyle.customEditTextStyle()),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    )),
                                                                                              ),
                                                                                            ],
                                                                                          );
                                                                                        }),
                                                                                  ),
                                                                                );
                                                                              }
                                                                              return const Offstage();
                                                                            }),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ));
                                                          });
                                                    },
                                                    text:
                                                        AppString.abouttoexpire,
                                                    // containerColor: Colors.orange,
                                                    containerColor:
                                                        const Color(0xffFEBD4D),

                                                    /// BLINK FIX: read from cached counts
                                                    textOval: aboutToCount
                                                        .toString()),
                                                const SizedBox(height: 10),

                                                ///"Up To Date License"
                                                ProfileBarClipConst(
                                                    onTap: () {
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return ExpiredLicensePopup(
                                                                title:
                                                                    'Up To Date License',
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .symmetric(
                                                                    vertical:
                                                                        AppPadding
                                                                            .p3,
                                                                    horizontal:
                                                                        AppPadding
                                                                            .p20,
                                                                  ),
                                                                  child:
                                                                      SingleChildScrollView(
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceEvenly,
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              30,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Colors.grey,
                                                                            borderRadius:
                                                                                BorderRadius.circular(12),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 18),
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                              children: [
                                                                                Expanded(
                                                                                  child: Center(
                                                                                    child: Text('Sr No.', style: ProfileBarNameLicenseStyle.customEditTextStyle()),
                                                                                  ),
                                                                                ),
                                                                                //SizedBox(width: MediaQuery.of(context).size.width/7.5,),
                                                                                Expanded(
                                                                                  child: Center(
                                                                                    child: Text('Name Of License', textAlign: TextAlign.start, style: ProfileBarNameLicenseStyle.customEditTextStyle()),
                                                                                  ),
                                                                                ),
                                                                                Expanded(
                                                                                  child: Center(
                                                                                    child: Text('Date', textAlign: TextAlign.start, style: ProfileBarNameLicenseStyle.customEditTextStyle()),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              15,
                                                                        ),
                                                                        FutureBuilder<Map<String, List<LicensesData>>>(
                                                                            future: _licenseStatusFuture,
                                                                            builder: (context, snapshot) {
                                                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                                                return Center(
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.symmetric(vertical: 150),
                                                                                    child: CircularProgressIndicator(
                                                                                      color: ColorManager.blueprime,
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              }

                                                                              /// FIX: guard against error/null before using data!
                                                                              if (snapshot.hasError || !snapshot.hasData || snapshot.data!['Upto date'] == null || snapshot.data!['Upto date']!.isEmpty) {
                                                                                return Center(
                                                                                    child: Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 150),
                                                                                  child: Text(
                                                                                    NoDataMessage.nouptodate,
                                                                                    style: AllNoDataAvailable.customTextStyle(context),
                                                                                  ),
                                                                                ));
                                                                              }
                                                                              if (snapshot.hasData) {
                                                                                final upToDateLicenses = snapshot.data!['Upto date']!;
                                                                                //final inactiveLicenses = snapshot.data!['Inactive']!;
                                                                                return Container(
                                                                                  height: MediaQuery.of(context).size.height / 2,
                                                                                  child: ScrollConfiguration(
                                                                                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                                                                                    child: ListView.builder(
                                                                                        scrollDirection: Axis.vertical,
                                                                                        itemCount: upToDateLicenses.length,
                                                                                        itemBuilder: (context, index) {
                                                                                          int serialNumber = index + 1 + (currentPage - 1) * itemsPerPage;
                                                                                          String formattedSerialNumber = serialNumber.toString().padLeft(2, '0');
                                                                                          return Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              // SizedBox(height: 5),
                                                                                              Padding(
                                                                                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 3),
                                                                                                child: Container(
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
                                                                                                    height: 50,
                                                                                                    child: Padding(
                                                                                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                                                                                      child: Row(
                                                                                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                                        children: [
                                                                                                          Expanded(
                                                                                                            child: Center(
                                                                                                              child: Text(formattedSerialNumber,
                                                                                                                  // formattedSerialNumber,
                                                                                                                  style: AboutExpiredLStyle.customEditTextStyle()),
                                                                                                            ),
                                                                                                          ),
                                                                                                          // Text(''),
                                                                                                          Expanded(
                                                                                                            child: Center(
                                                                                                              child: Text(upToDateLicenses[index].licenseure, style: AboutExpiredLStyle.customEditTextStyle()),
                                                                                                            ),
                                                                                                          ),
                                                                                                          Expanded(
                                                                                                            child: Center(
                                                                                                              child: Text(upToDateLicenses[index].expDate, style: AboutExpiredLStyle.customEditTextStyle()),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    )),
                                                                                              ),
                                                                                            ],
                                                                                          );
                                                                                        }),
                                                                                  ),
                                                                                );
                                                                              }
                                                                              return const Offstage();
                                                                            }),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ));
                                                          });
                                                    },
                                                    text: AppString.uptodate,
                                                    // containerColor: Colors.lightGreen,
                                                    containerColor:
                                                        const Color(0xffB4DB4C),

                                                    /// BLINK FIX: read from cached counts
                                                    textOval: upToDateCount
                                                        .toString()),
                                                const SizedBox(height: 10),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class ProfileBarTextBoldStyle {
  static TextStyle customEditTextStyle() {
    return TextStyle(
      fontSize: FontSize.s12,
      fontWeight: FontWeight.w600,
      color: ColorManager.textPrimaryColor,

      // decoration: TextDecoration.none,
    );
  }
}

class ProfileBarZoneStyle {
  static TextStyle customEditTextStyle() {
    return const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Color(0xff686464),
      decoration: TextDecoration.none,
    );
  }
}

class ProfileBarNameLicenseStyle {
  static TextStyle customEditTextStyle() {
    return const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      decoration: TextDecoration.none,
    );
  }
}

class AboutExpiredLStyle {
  static TextStyle customEditTextStyle() {
    return const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Color(0xff686464),
      decoration: TextDecoration.none,
    );
  }
}
