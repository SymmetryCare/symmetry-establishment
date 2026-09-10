import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/onboarding_manager/onboarding_ack_health_manager.dart';
import 'package:symmetry_establishment/app/services/base64/download_file_base64.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/onboarding_data/onboarding_ack_health_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/approve_reject_dialog_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/download_doc_const.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';

///saloni
class AcknowledgementTab extends StatefulWidget {
  final int employeeId;
  const AcknowledgementTab({Key? key, required this.employeeId}) : super(key: key);

  @override
  State<AcknowledgementTab> createState() => _AcknowledgementTabState();
}

class _AcknowledgementTabState extends State<AcknowledgementTab> {
  final StreamController<List<OnboardingAckHealthData>> _controller =
  StreamController<List<OnboardingAckHealthData>>();
  List<OnboardingAckHealthData> _fetchedData = [];
  List<bool> _checked = [];
  List<int> _selectedDocumentIds = [];

  // Caches the in-flight/resolved Future itself (not just the bytes) per
  // employeeDocumentId. Reusing the SAME Future instance across rebuilds is
  // what stops FutureBuilder from flashing back to its "waiting" state every
  // time a checkbox toggle triggers setState — a brand new Future built on
  // every build (even one that resolves instantly from a byte cache) still
  // makes FutureBuilder briefly show the loading state, causing a blink.
  static final Map<int, Future<Uint8List>> _pdfThumbnailFutureCache = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      var data = await getAckHealthRecord(context, FrontendConfigStore.data!.config.acknowledgementDocId,widget.employeeId, 'no');
      data.sort((a, b) {
        if (a.approved == true && b.approved != true) {
          return -1;
        } else if (a.approved != true && b.approved == true) {
          return 1;
        } else {
          return 0;
        }
      });

      _fetchedData = data;
      _controller.add(data);
      _checked = List.generate(data.length, (_) => false);
    } catch (error) {
      _controller.addError(error);
    }
  }

  void _handleCheckboxChanged(bool? value, int index, int employeeDocumentId) {
    setState(() {
      _checked[index] = value!;
      if (value) {
        _selectedDocumentIds.add(employeeDocumentId);
      } else {
        _selectedDocumentIds.remove(employeeDocumentId);
      }
    });
  }

  void _handleRejectSelected() {
    if (_selectedDocumentIds.isEmpty) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RejectConfirmPopup(onCancel: () {
          Navigator.pop(context);
        }, onReject: () {
          _rejectSelectedDocuments();
          Navigator.pop(context);
        });
      },
    );
  }

  Future<void> _rejectSelectedDocuments() async {
    var result =
    await batchRejectOnboardAckHealthPatch(context, _selectedDocumentIds);
    if (result.success) {
      await _fetchData();
      setState(() {
        _selectedDocumentIds.clear();
      });
    } else {
      // Handle error
      print(result.message);
    }
  }

  void _handleApproveSelected() {
    if (_selectedDocumentIds.isEmpty) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ApproveConfirmPopup(onCancel: () {
          Navigator.pop(context);
        }, onApprove: () {
          _approveSelectedDocuments();
          Navigator.of(context).pop();
        });
      },
    );
  }

  Future<void> _approveSelectedDocuments() async {
    var result =
    await batchApproveOnboardAckHealthPatch(context, _selectedDocumentIds);
    if (result.success) {
      await _fetchData();
      setState(() {
        for (var id in _selectedDocumentIds) {
          int index =
          _fetchedData.indexWhere((data) => data.employeeDocumentId == id);
          if (index != -1) {
            _checked[index] = false;
          }
        }
        _selectedDocumentIds.clear();
      });
    } else {
      print(result.message);
    }
  }

  // Fetches the PDF bytes over http and rasterizes page 1 to a bitmap via
  // pdfx (pdfium under the hood, works on Flutter Web too). The returned
  // Future is cached per employeeDocumentId (see _pdfThumbnailFutureCache)
  // so re-builds reuse the exact same Future instance instead of kicking
  // off a fresh fetch/render every time.
  Future<Uint8List> _fetchAndRenderPdfFirstPage(String fileUrl, int employeeDocumentId) async {
    final response = await http.get(Uri.parse(fileUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch PDF (status ${response.statusCode})');
    }

    final document = await PdfDocument.openData(response.bodyBytes);
    final page = await document.getPage(1);
    final pageImage = await page.render(
      width: page.width * 2,
      height: page.height * 2,
      format: PdfPageImageFormat.png,
    );
    await page.close();
    await document.close();

    if (pageImage == null) {
      throw Exception('Failed to render PDF page 1');
    }

    return pageImage.bytes;
  }

  Future<Uint8List> _loadPdfFirstPageThumbnail(String fileUrl, int employeeDocumentId) {
    return _pdfThumbnailFutureCache[employeeDocumentId] ??=
        _fetchAndRenderPdfFirstPage(fileUrl, employeeDocumentId);
  }

  // Renders the actual uploaded document:
  // - images load directly via Image.network
  // - PDFs are fetched + rasterized to a bitmap of page 1 via pdfx — no
  //   iframe, no native browser PDF-viewer chrome
  // - anything else (doc/docx, unknown) falls back to the generic icon
  Widget _buildPreviewWidget(String fileUrl, String fileExtension, int employeeDocumentId) {
    if (fileExtension == 'jpg' || fileExtension == 'jpeg' || fileExtension == 'png' || fileExtension == 'gif') {
      return Image.network(
        fileUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset('images/Vector.png'),
      );
    }

    if (fileExtension == 'pdf') {
      return FutureBuilder<Uint8List>(
        future: _loadPdfFirstPageThumbnail(fileUrl, employeeDocumentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: ColorManager.blueprime),
              ),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            print('PDF thumbnail error: ${snapshot.error}');
            return Image.asset('images/Vector.png');
          }
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Image.asset('images/Vector.png'),
          );
        },
      );
    }

    return Image.asset('images/Vector.png');
  }

  // ── Helpers for the card layout ──────────────────────────────────────────
  String _fileExtensionOf(String fileUrl) {
    final segment = fileUrl.split('/').last;
    if (!segment.contains('.')) return '';
    return segment.split('.').last.toLowerCase();
  }

  Color _fileTypeColor(String ext) {
    if (ext == 'pdf') return const Color(0xffE94141);
    if (ext == 'doc' || ext == 'docx') return const Color(0xff1696C8);
    if (ext == 'jpg' || ext == 'jpeg' || ext == 'png' || ext == 'gif') return const Color(0xff2FA84F);
    return ColorManager.mediumgrey;
  }

  Widget _buildDocumentCard(BuildContext context, OnboardingAckHealthData data, int index) {
    final fileUrl = data.DocumentUrl;
    final fileExtension = _fileExtensionOf(fileUrl);

    final Widget fileWidget = _buildPreviewWidget(fileUrl, fileExtension, data.employeeDocumentId);

    return Container(
      width: 500,
      // ✅ Widened the gap between cards: right margin bumped 16 -> 48,
      // and bottom margin bumped 16 -> 24 to match.
      margin: const EdgeInsets.only(right: 48, bottom: 24),
      padding: const EdgeInsets.all(AppSize.s12),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorManager.faintGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: checkbox / approved icon, file icon, name ───────────────
          Row(
            children: [
              data.approved == true
                  ? const SizedBox(
                width: AppSize.s31,
                height: AppSize.s31,
                child: Center(
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.check, color: Colors.white, size: 16),
                  ),
                ),
              )
                  : SizedBox(
                width: AppSize.s31,
                height: AppSize.s31,
                child: Checkbox(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  splashRadius: 0,
                  value: _checked[index],
                  onChanged: data.approved == null
                      ? (value) {
                    _handleCheckboxChanged(value, index, data.employeeDocumentId);
                  }
                      : null,
                ),
              ),
              SizedBox(
                width: FontSize.s18,
                child: Icon(
                  fileExtension == 'pdf' ? Icons.picture_as_pdf : Icons.insert_drive_file,
                  color: _fileTypeColor(fileExtension),
                  size: FontSize.s18,
                ),
              ),
              const SizedBox(width: AppSize.s8),
              Flexible(
                fit: FlexFit.loose,
                child: Text(
                  data.documentFileName,
                  softWrap: false,
                  style: AknowledgementStyleConst.customTextStyle(context),
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: AppSize.s12),

          // ── Preview panel ──────────────────────────────────────────────────
          Container(
            width: double.infinity,
            height: 180,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: ColorManager.grey.withOpacity(0.15),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: ColorManager.faintGrey),
            ),
            child: fileWidget,
          ),

          const SizedBox(height: AppSize.s12),

          // ── Footer: view/download icons ──────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: ColorManager.faintGrey),
                ),
                child: IconButton(
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.remove_red_eye_outlined, color: ColorManager.mediumgrey, size: 18),
                  onPressed: () {
                    print("FileExtension:${fileExtension}");
                    downloadFile(context: context,
                        fileUrl: fileUrl,
                        documentName:data.documentFileName,
                        apiPath: DownloadDocumentRepository.getDocumentByFileName());
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OnboardingAckHealthData>>(
      stream: _controller.stream,
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
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: ColorManager.red),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 150),
                child: Text(
                    AppStringHRNoData.noOnboardAck,
                    style: AllNoDataAvailable.customTextStyle(context)
                ),
              ));
        }

        // Reject/Approve are only meaningful once at least one document is
        // checked — greyed out and non-interactive otherwise.
        final bool hasSelection = _selectedDocumentIds.isNotEmpty;

        // Build cards once so the wrap below reuses the same list instead
        // of calling List.generate twice.
        final List<Widget> cards = List.generate(
          snapshot.data!.length,
              (index) => _buildDocumentCard(context, snapshot.data![index], index),
        );

        // ✅ Always start-aligned regardless of count — keeps card #1's
        // position identical whether there's 1 card or many, instead of
        // jumping between centerLeft (single) and default Wrap start (multiple).
        final Widget cardWrap = Wrap(
          alignment: WrapAlignment.start,
          spacing: AppSize.s16,
          runSpacing: AppSize.s16,
          children: cards,
        );

        return Container(
          width: 1160,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              // ✅ start instead of center — keeps card #1 in the same spot
              // whether there's 1 card or many.
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row: title/subtitle left, Reject/Approve right ───────
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0,left: 1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ── Left side: title + subtitle stacked ─────────────────
                      Flexible(
                        fit: FlexFit.loose,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Acknowledgement Documents',
                              softWrap: false,
                              style: CustomTextStylesCommon.commonStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: FontSize.s14,
                                color: ColorManager.mediumgrey,
                              ),
                            ),
                            const SizedBox(height: AppSize.s4),
                            Text(
                              'Review candidate acknowledgement documents. Click on any document to preview, zoom or download.',
                              softWrap: false,
                              style: CustomTextStylesCommon.commonStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: FontSize.s12,
                                color: ColorManager.mediumgrey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Right side: Reject/Approve buttons ───────────────────
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: hasSelection ? _handleRejectSelected : null,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: hasSelection ? ColorManager.blueprime : ColorManager.mediumgrey,
                              side: BorderSide(color: hasSelection ? ColorManager.blueprime : ColorManager.faintGrey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(AppString.reject,
                                style: TransparentButtonTextConst.customTextStyle(context)
                            ),
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width / 75),
                          ElevatedButton(
                            onPressed: hasSelection ? _handleApproveSelected : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: hasSelection ? ColorManager.blueprime : ColorManager.faintGrey,
                              foregroundColor: hasSelection ? ColorManager.white : ColorManager.mediumgrey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Approve',
                              style: BlueButtonTextConst.customTextStyle(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // ✅ Same Wrap, same alignment, always — no branching, so
                // card #1 never jumps position based on count.
                cardWrap,
              ],
            ),
          ),
        );
      },
    );
  }
  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}