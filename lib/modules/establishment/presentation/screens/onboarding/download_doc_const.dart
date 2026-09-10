import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_establishment/app/services/base64/download_file_base64.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';

// Future<void> downloadFile(String url) async {
//   final Uri uri = Uri.parse(url);
//   print('Url Response : ${uri.data}');
//   if (await canLaunchUrl(uri)) {
//     await launchUrl(uri);
//   } else {
//     throw 'Could not launch $url';
//   }
// }
Future<void> downloadFile({
  required BuildContext context,
  required String fileUrl,
  required String documentName,
  required String apiPath,
}) async {
  final fileName = fileUrl.split('/').last;

  final fileData = await getEmployeeDocumentByFileName(
    context: context,
    fileName: fileName,
    apiPath: "$apiPath/$fileName",
  );

  if (fileData == null) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddErrorPopup(
          message: 'Unable to open document.',
        );
      },
    );
    return;
  }

  try {
    // application/pdf makes the browser open its native PDF viewer,
    // which includes the print icon/toolbar.
    final blob = html.Blob([fileData.bytes], 'application/pdf');
    final blobUrl = html.Url.createObjectUrlFromBlob(blob);

    // Use dart:html's window.open directly for blob URLs —
    // url_launcher's canLaunchUrl/launchUrl doesn't reliably
    // support the blob: scheme on web.
    html.window.open(blobUrl, '_blank');

    // Don't revoke immediately — give the new tab time to load it.
    Future.delayed(const Duration(minutes: 1), () {
      html.Url.revokeObjectUrl(blobUrl);
    });
  } catch (e) {
    debugPrint('Error opening document: $e');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddErrorPopup(
          message: 'Unable to open document.',
        );
      },
    );
  }
}

Future<void> openImageInNewTab({
  required BuildContext context,
  required String fileUrl,
  required String documentName,
  required String apiPath,
}) async {
  final fileName = fileUrl.split('/').last;

  final fileData = await getEmployeeDocumentByFileName(
    context: context,
    fileName: fileName,
    apiPath: "$apiPath/$fileName",
  );

  if (fileData == null) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddErrorPopup(
          message: 'Unable to open document.',
        );
      },
    );
    return;
  }

  try {
    final mimeType = _getImageMimeType(fileName);

    final blob = html.Blob([fileData.bytes], mimeType);
    final blobUrl = html.Url.createObjectUrlFromBlob(blob);

    // Use dart:html's window.open directly for blob URLs —
    // url_launcher's canLaunchUrl/launchUrl doesn't reliably
    // support the blob: scheme on web.
    html.window.open(blobUrl, '_blank');

    // Don't revoke immediately — give the new tab time to load it.
    Future.delayed(const Duration(minutes: 1), () {
      html.Url.revokeObjectUrl(blobUrl);
    });
  } catch (e) {
    debugPrint('Error opening image: $e');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddErrorPopup(
          message: 'Unable to open document.',
        );
      },
    );
  }
}

String _getImageMimeType(String fileName) {
  final ext = fileName.split('.').last.toLowerCase();
  switch (ext) {
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'gif':
      return 'image/gif';
    case 'webp':
      return 'image/webp';
    case 'bmp':
      return 'image/bmp';
    case 'svg':
      return 'image/svg+xml';
    default:
      return 'image/jpeg'; // sensible fallback
  }
}


///download file const
class PdfDownloadButton extends StatelessWidget {
  final String apiUrl;
  final String documentName;
  final double? iconsize;
  final Color? iconColor;
  final String apiPath;


  const PdfDownloadButton({required this.apiUrl,
    required this.documentName,
    this.iconColor,
    this.iconsize, required this.apiPath
  });

  Future<void> _downloadPdf() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Uint8List pdfBytes = response.bodyBytes;

        final blob = html.Blob([pdfBytes], 'application/pdf');

        final url = html.Url.createObjectUrlFromBlob(blob);

        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', documentName)
          ..click();

        html.Url.revokeObjectUrl(url);
      } else {
        throw Exception('Failed to load PDF');
      }
    } catch (e) {
      print('Error downloading PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      icon: Icon(Icons.save_alt_outlined, size: iconsize ?? IconSize.I22, color: iconColor ?? Color(0xff1696C8),),
      onPressed: //_downloadPdf
          (){
        downloadDocument(
            context: context,
            fileUrl: apiUrl,
            documentName: documentName,
            apiPath: apiPath);
      }
    );
  }
}

class PdfHtmlDownloadButton extends StatelessWidget {
  final String apiUrl;
  final String documentName;
  final double? iconsize;
  final Color? iconColor;
  final String apiPath;


  const PdfHtmlDownloadButton({required this.apiUrl,
    required this.documentName,
    this.iconColor,
    this.iconsize, required this.apiPath
  });


  @override
  Widget build(BuildContext context) {
    return IconButton(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        icon: Icon(Icons.save_alt_outlined, size: iconsize ?? IconSize.I22, color: iconColor ?? Color(0xff1696C8),),
        onPressed: //_downloadPdf
            (){
              downloadHtmlDocument(
              context: context,
              fileUrl: apiUrl,
              fileName: documentName,
              apiPath: apiPath);
        }
    );
  }
}




///download with get api

// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:prohealth/app/resources/value_manager.dart';
// import 'dart:html' as html;
//
// import '../../../../app/resources/color.dart';
// import '../../../../app/services/api/managers/download_doc_get_api/download_doc_get_api.dart';
//
// class PdfDownloadButton extends StatelessWidget {
//   final String fileName;
//   final String documentName;
//   final double? iconsize;
//   final Color? iconColor;
//
//   const PdfDownloadButton({
//     super.key,
//     required this.fileName,
//     required this.documentName,
//     this.iconColor,
//     this.iconsize,
//   });
//
//   Future<void> _downloadPdf(BuildContext context) async {
//     try {
//       final fileData = await getEmployeeDocumentByFileName(context, fileName);
//
//       if (fileData != null) {
//         final Uint8List pdfBytes = Uint8List.fromList(fileData.bytes);
//
//         final blob = html.Blob([pdfBytes], 'application/pdf');
//         final url = html.Url.createObjectUrlFromBlob(blob);
//
//         final anchor = html.AnchorElement(href: url)
//           ..setAttribute('download', documentName)
//           ..click();
//
//         html.Url.revokeObjectUrl(url);
//       } else {
//         print('Failed to load PDF');
//       }
//     } catch (e) {
//       print('Error downloading PDF: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return IconButton(
//       splashColor: Colors.transparent,
//       highlightColor: Colors.transparent,
//       hoverColor: Colors.transparent,
//       icon: Icon(
//         Icons.save_alt_outlined,
//         size: iconsize ?? IconSize.I22,
//         color: iconColor ?? const Color(0xff1696C8),
//       ),
//       onPressed: () => _downloadPdf(context),
//     );
//   }
// }
//
//
// Future<void> downloadFile(BuildContext context, String fileName) async {
//   try {
//     final fileData = await getEmployeeDocumentByFileName(context, fileName);
//     if (fileData == null) {
//       print('Download failed: could not fetch file $fileName');
//       return;
//     }
//
//     final Uint8List pdfBytes = Uint8List.fromList(fileData.bytes);
//     final blob = html.Blob([pdfBytes], 'application/pdf');
//     final url = html.Url.createObjectUrlFromBlob(blob);
//
//     final anchor = html.AnchorElement(href: url)
//       ..setAttribute('download', fileName)
//       ..click();
//
//     html.Url.revokeObjectUrl(url);
//   } catch (e) {
//     print('Error downloading file: $e');
//   }
// }
//
//
// ///
// Future<void> printFile(BuildContext context, String fileName) async {
//   try {
//     final fileData = await getEmployeeDocumentByFileName(context, fileName);
//     if (fileData == null) {
//       print('Print failed: could not fetch file $fileName');
//       return;
//     }
//
//     final blob = html.Blob([Uint8List.fromList(fileData.bytes)], 'application/pdf');
//     final blobUrl = html.Url.createObjectUrlFromBlob(blob);
//
//     final iframe = html.IFrameElement()
//       ..src = blobUrl
//       ..style.border = 'none'
//       ..style.width = '0'
//       ..style.height = '0';
//
//     html.document.body!.append(iframe);
//
//     iframe.onLoad.listen((_) {
//       html.window.print();
//       iframe.remove();
//       html.Url.revokeObjectUrl(blobUrl);
//     });
//   } catch (e) {
//     print('Error printing file: $e');
//   }
// }