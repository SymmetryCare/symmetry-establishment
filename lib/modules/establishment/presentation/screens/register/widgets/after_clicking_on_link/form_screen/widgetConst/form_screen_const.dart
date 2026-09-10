import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui_web' as ui_web;
import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/modules/establishment/resources/hr_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/legal_documents/legal_document_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/top_row.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';

class SignatureFormScreen extends StatefulWidget {
  final String documentName;
  final VoidCallback onPressed;
  final String htmlFormData;
  final int employeeId;
  final int htmlFormTemplateId;
  final bool isDisable;
  const SignatureFormScreen({
    super.key,
    required this.documentName,
    required this.onPressed,
    required this.htmlFormData,
    required this.employeeId,
    required this.htmlFormTemplateId,
    required this.isDisable,
  });

  @override
  State<SignatureFormScreen> createState() => _SignatureFormScreenState();
}

class _SignatureFormScreenState extends State<SignatureFormScreen> {
  final ScrollController _horizontalScrollController = ScrollController();

  String? pdfBase64Url;
  bool isLoading = false;
  String? pdfFile;
  late PDFViewController pdfViewController;

  int currentPage = 0;
  int totalPages = 0;
  bool isReady = false;
  String errorMessage = '';
  static const String viewType = 'html-viewer';
  String _uniqueKey = UniqueKey().toString(); // Unique key for re-rendering

  @override
  void didUpdateWidget(SignatureFormScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If HTML content changes, update the unique key to force re-render
    if (widget.htmlFormData != oldWidget.htmlFormData) {
      setState(() {
        _uniqueKey = UniqueKey().toString();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Register the view factory
    base64Converter();
    ui_web.platformViewRegistry.registerViewFactory(
      'html-viewer-$_uniqueKey', // Use unique key in viewType
          (int viewId) {
        final element = html.IFrameElement()
          ..srcdoc = widget.htmlFormData
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '600px';
        return element;
      },
    );
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  void toggleBack() {
    Navigator.pop(context);
  }

  void base64Converter() async {
    pdfFile = await PdfGenerator.htmlToBase64Pdf(widget.htmlFormData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: TopRowConstant(),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
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
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                  splashColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(Icons.arrow_back)),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: AppPadding.p150),
                                child: Text(
                                  widget.documentName,
                                  style:
                                  FormHeading.customTextStyle(context),
                                ),
                              ),
                              widget.isDisable
                                  ? const SizedBox(width: 140)
                                  : Row(
                                children: [
                                  widget.isDisable
                                      ? const SizedBox(width: 140)
                                      : Container(
                                    height: 30,
                                    width: 140,
                                    child:
                                    CustomeFormCancelButton(
                                      text: 'Cancel',
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Container(
                                    height: 30,
                                    width: 140,
                                    child: CustomIconButton(
                                      text: 'Confirm',
                                      onPressed: () async {
                                        print(
                                            "Pdf byte ${pdfFile}");
                                        setState(() {
                                          isLoading = true;
                                        });
                                        try {
                                          await htmlFormTemplateSignature(
                                            context: context,
                                            formHtmlTempId: widget
                                                .htmlFormTemplateId,
                                            htmlName:
                                            widget.documentName,
                                            documentFile: pdfFile!,
                                            employeeId:
                                            widget.employeeId,
                                            signed: true,
                                          );
                                          widget.onPressed();
                                        } finally {
                                          setState(() {
                                            isLoading = false;
                                            Navigator.pop(context);
                                          });
                                        }
                                      }, isNotPopUpButton: true,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 50),
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 100),
                          child: Container(
                            color: Colors.white,
                            height: MediaQuery.of(context).size.height,
                            child: HtmlElementView(
                                viewType: 'html-viewer-$_uniqueKey'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

///code by sir
class PdfGenerator {
  static Future<String> htmlToBase64Pdf(String htmlContent) async {
    try {
      final completer = Completer<String>();

      // Wrap the HTML content with styles that support multi-page rendering
      final formattedHtmlContent = '''
      <html>
        <head>
          <style>
            @page {
              size: A4; /* Define A4 page size */
              margin: 20mm; /* Set page margins */
            }

            body {
              margin: 0;
              padding: 0;
              font-family: 'Times New Roman', serif;
              -webkit-print-color-adjust: exact; /* Ensure colors render correctly */
            }

            .pdf-content {
              width: 860;
              margin: 0;
              padding: 5mm;
              font-family: 'Times New Roman', serif;
              word-wrap: break-word; /* Prevent text overflow */
            }

            /* Ensure content flows correctly across pages */
            .page-break {
              page-break-before: always;
              break-before: page;
            }
          </style>
        </head>
        <body>
          <div class="pdf-content">
            $htmlContent
          </div>
        </body>
      </html>
      ''';

      // JavaScript function to convert HTML to PDF and return Base64
      js.context.callMethod('htmlToPdf', [
        formattedHtmlContent,
        ((String base64Pdf) {
          completer.complete(base64Pdf);
        }).toJS
      ]);

      final base64Pdf = await completer.future;
      print(base64Pdf);
      return base64Pdf;
    } catch (e) {
      print("Error generating PDF: $e");
      return "";
    }
  }
}
