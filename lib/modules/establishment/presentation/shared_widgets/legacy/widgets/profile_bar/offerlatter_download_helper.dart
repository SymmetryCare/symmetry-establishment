import 'dart:io' show Directory, File, Platform;
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';

// Notifier that drives the progress animation in the dialog
final ValueNotifier<double> _downloadProgress = ValueNotifier<double>(0);
final ValueNotifier<bool> _downloadDone = ValueNotifier<bool>(false);

Future<void> downloadPdfFile({
  required BuildContext context,
  required String pdfUrl,
  required String fileName,
  required String apiPath,
}) async {
  _downloadProgress.value = 0;
  _downloadDone.value = false;
  // ---------------------------------------------------------------
  // Show the animated downloading dialog
  // ---------------------------------------------------------------
  if (context.mounted) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _DownloadProgressDialog(),
    );
  }

  void closeDialog() {
    if (context.mounted && Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  try {
    // -----------------------------------------------------------
    // 1. Download the file through the app's authenticated API
    //    layer (same mechanism as downloadDocument) instead of
    //    hitting pdfUrl directly.
    // -----------------------------------------------------------
    final fileNameUrl = pdfUrl.split('/').last;
    final fileData = await getEmployeeDocumentByFileName(
      context: context,
      fileName: fileName,
      apiPath: "$apiPath/$fileNameUrl",
    );

    if (fileData == null) {
      closeDialog();
      if (context.mounted) {
        _showDownloadError(context, 'Download failed.');
      }
      return;
    }

    final Uint8List bytes = Uint8List.fromList(fileData.bytes);
    _downloadProgress.value = 1.0;

    final String baseName = fileName.toLowerCase().endsWith('.pdf')
        ? fileName.substring(0, fileName.length - 4)
        : fileName;

    String? savedPath;

    if (kIsWeb) {
      // ---------------------------------------------------------
      // 2a. WEB → browser's native "Save file" download
      // ---------------------------------------------------------
      await FileSaver.instance.saveFile(
        name: baseName,
        bytes: bytes,
        fileExtension: 'pdf',
        mimeType: MimeType.pdf,
      );
    } else {
      // ---------------------------------------------------------
      // 2b. ANDROID / iOS → save to app folder
      // ---------------------------------------------------------
      final Directory dir = Platform.isAndroid
          ? (await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory())
          : await getApplicationDocumentsDirectory();

      savedPath = '${dir.path}/$fileName';
      await File(savedPath).writeAsBytes(bytes);
    }

    // -----------------------------------------------------------
    // 3. Morph the dialog into the success checkmark animation,
    //    hold it briefly, then close.
    // -----------------------------------------------------------
    _downloadDone.value = true;
    await Future.delayed(const Duration(milliseconds: 1400));
    closeDialog();

    // Open the PDF on mobile after the dialog closes
    if (!kIsWeb && savedPath != null) {
      await OpenFilex.open(savedPath);
    }
  } catch (e) {
    debugPrint('PDF download error: $e');
    closeDialog();
    if (context.mounted) {
      _showDownloadError(context, 'Unexpected error while downloading.');
    }
  }
}

void _showDownloadError(BuildContext context, String message) {
  if (context.mounted) {
    showDialog(
      context: context,
      builder: (BuildContext context) => FailedPopup(text: message),
    );
  }
}

Future<void> downloadDocument({
  required BuildContext context,
  required String fileUrl,
  required String documentName,
  required String apiPath}) async {
  final fileName = fileUrl.split('/').last;
  final fileData = await getEmployeeDocumentByFileName(context: context,
      fileName: fileName,apiPath: "$apiPath/$fileName");
  if (fileData == null) {
    // if (mounted) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddErrorPopup(
          message: 'Unable to download document.',
        );
      },
    );

    return;
  }
  final blob = html.Blob([fileData.bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', documentName)
    ..click();
  html.Url.revokeObjectUrl(url);
}

// =====================================================================
// Animated dialog: progress ring with % → animated green checkmark
// =====================================================================
class _DownloadProgressDialog extends StatelessWidget {
  const _DownloadProgressDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: ValueListenableBuilder<bool>(
          valueListenable: _downloadDone,
          builder: (context, done, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: CurvedAnimation(
                      parent: animation,
                      curve: Curves.elasticOut,
                    ),
                    child: child,
                  ),
                  child: done
                      ? const _SuccessCheck(key: ValueKey('check'))
                      : const _ProgressRing(key: ValueKey('progress')),
                ),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    done ? 'Downloaded!' : 'Downloading offer letter...',
                    key: ValueKey(done),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Circular progress ring with live percentage in the middle
class _ProgressRing extends StatelessWidget {
  const _ProgressRing({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: _downloadProgress,
      builder: (context, progress, _) {
        final bool indeterminate = progress <= 0;
        return SizedBox(
          width: 90,
          height: 90,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 250),
                  builder: (context, value, _) => CircularProgressIndicator(
                    value: indeterminate ? null : value,
                    strokeWidth: 7,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
              ),
              if (!indeterminate)
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                const Icon(Icons.download_rounded, size: 28),
            ],
          ),
        );
      },
    );
  }
}

// Green circle with an animated drawn checkmark
class _SuccessCheck extends StatelessWidget {
  const _SuccessCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: const BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) => CustomPaint(
          painter: _CheckPainter(progress: value),
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  final double progress;
  _CheckPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.28, size.height * 0.53)
      ..lineTo(size.width * 0.44, size.height * 0.68)
      ..lineTo(size.width * 0.72, size.height * 0.36);

    // Draw only part of the path based on animation progress
    final metrics = path.computeMetrics().first;
    final partial = metrics.extractPath(0, metrics.length * progress);
    canvas.drawPath(partial, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.progress != progress;
}