import 'dart:ui';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/progress_form_manager/offer_letter_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/bottom_row.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/declination_form_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/offer_letter_description_screen.dart';
import 'package:signature/signature.dart';
import 'dart:typed_data';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/hr_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/top_row.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_nine_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/widgetConst/new_widget_const/forms_blue_header_const.dart';

typedef ImageCallback = void Function(Uint8List? image);


class SignaturePage extends StatefulWidget {
  final Function(Uint8List?) onSignatureSelected;
  final int employeeId;
  final int depID;
  final int templateId;
  final int employeeEnrollId;
  const SignaturePage({required this.onSignatureSelected, required this.employeeId, required this.depID, required this.templateId, required this.employeeEnrollId});

  @override
  _SignaturePageState createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  // Preload the SVG before the dialog is shown
  late SvgPicture _preloadedSvg;




  @override
  void initState() {
    super.initState();
    // Load the SVG here and store it in the _preloadedSvg variable
    _preloadedSvg = SvgPicture.asset('images/sign_saving.svg');
  }


  bool _isDrawing = true;
  List<Offset?> _points = [];
  dynamic? _selectedImageBytes;
  bool _showValidationMessage = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: TopRowConstant(),
      ),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 1200,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Signature',
                            style:FormHeading.customTextStyle(context)
                          ),
                        ),
                        const SizedBox(height:20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 110.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Upload Signature',
                                style: FormHeading.customTextStyle(context)
                              ),
                              const SizedBox(height: 20),
                              const FormsBlueHeaderConst(
                                text: 'Signature is needed to sign the declination form and few other forms.',
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // "Draw" Button with Radio
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Radio<bool>(
                                            splashRadius: 0,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            value: true,
                                            groupValue: _isDrawing,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                _isDrawing = value ?? false;
                                                _selectedImageBytes = null;
                                              });
                                            },
                                          ),
                                          InkWell(

                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            onTap: () {
                                              setState(() {
                                                _isDrawing = true;
                                                _selectedImageBytes = null;
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                Image.asset('images/pen.png',color: _isDrawing ?ColorManager.blueprime  :  ColorManager.mediumgrey,height: 25,),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Draw',
                                                  style: TextStyle(
                                                    color: _isDrawing ? ColorManager.blueprime  : ColorManager.mediumgrey,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Blue line under "Draw" when selected
                                      Container(
                                        height: 2,
                                        width: 130,
                                        color: _isDrawing ? ColorManager.blueprime  : Colors.transparent,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  // "Upload" Button with Radio
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Radio<bool>(
                                            splashRadius: 0,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            value: false,
                                            groupValue: _isDrawing,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                _isDrawing = value ?? true;
                                                _selectedImageBytes = null; // Optionally clear any previous drawing
                                              });
                                            },
                                          ),
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            onTap: () {
                                              setState(() {
                                                _isDrawing = false;
                                                _selectedImageBytes = null; // Optionally clear any previous drawing
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                Icon(Icons.file_upload_outlined, color: !_isDrawing ?ColorManager.blueprime  :  ColorManager.mediumgrey, size: 24),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Upload',
                                                  style: TextStyle(
                                                    color: !_isDrawing ? ColorManager.blueprime  : ColorManager.mediumgrey,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Blue line under "Upload" when selected
                                      Container(
                                        height: 2,
                                        width: 130,
                                        color: !_isDrawing ? ColorManager.blueprime : Colors.transparent,
                                      ),
                                    ],
                                  ),
                                  Expanded(child: Container()),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child:  _isDrawing
                              ?Container(
                            height: 30,
                                child: Text(
                                    "Sign your name using mouse or touchpad",
                                  style: TextStyle(
                                    color: ColorManager.textPrimaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                                ),
                              )
                              :Container(
                            height: 30,
                                child: ElevatedButton(onPressed:_pickFile,
                                  child: Text("Upload a signature from this device",
                                style: TextStyle(
                                color:ColorManager.blueprime,
                                  fontSize: 14,
                                fontWeight: FontWeight.w600,
                                                          ),),
                                                          style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.white,
                                                          foregroundColor: ColorManager.blueprime ,
                                                          shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: ColorManager.blueprime , width: 1)),
                                                        ),
                                                        ),
                              ),
                        ),
                        const SizedBox(height:  20),
                        Center(
                          child: Container(
                           height: 389,
                          width: 947,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRect(
                              child: _selectedImageBytes != null && !_isDrawing
                                  ? Image.memory(
                                _selectedImageBytes!,
                              )
                                  : GestureDetector(
                                onPanUpdate: (details) {
                                  setState(() {
                                    RenderBox renderBox = context.findRenderObject() as RenderBox;
                                    Offset localPosition = renderBox.globalToLocal(details.localPosition);
                                    print("Drawing at: $localPosition"); // Debugging
                                    _points.add(localPosition);
                                  });
                                },
                                onPanEnd: (details) {
                                  _points.add(null);
                                },
                                child: CustomPaint(
                                  painter: SignaturePainter(points: _points),
                                  size: Size.infinite,
                                ),
                              ),
                            ),
                          ),
                        ),
           const SizedBox(height: 20 ),

                        // Validation message conditionally displayed above the buttons
                        if (_points.isEmpty && _selectedImageBytes == null)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Center(
                              child: Text(
                                'Please draw or upload a signature before saving.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )else const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: SizedBox(height:16),
                        ),


                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 100,
                              child: OutlinedButton(
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Color(0xFF50B5E5),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isDrawing = true;
                                    _points.clear();
                                    _selectedImageBytes = null;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xff50B5E5),
                                  side: const BorderSide(color: Color(0xff50B5E5), width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width / 80),
                            Row(
                              children: [
                                Container(
                                  width: 100,
                                  child: OutlinedButton(
                                    child: const Text(
                                      'Reset',
                                      style: TextStyle(
                                        color: Color(0xFF50B5E5),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _points.clear();
                                        _selectedImageBytes = null;
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xff50B5E5),
                                      side: const BorderSide(color: Color(0xff50B5E5), width: 1.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width / 80),
                            isLoading
                                ? SizedBox(
                              height: 25,
                              width: 25,
                              child: CircularProgressIndicator(color: ColorManager.blueprime),
                            )
                                : Container(
                              width: 100,
                              child: ElevatedButton(
                                child: const Text(
                                  'Save',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                                onPressed: () async {
                                  // Check if user has drawn or uploaded a signature
                                  if (_points.isEmpty && _selectedImageBytes == null) {
                                    setState(() {
                                      _showValidationMessage = true;
                                    });
                                  }
                                  else {
                                    setState(() {
                                      isLoading = true; // Start loading
                                    });
                                    // Simulate a delay while the image loads
                                    // Proceed with saving
                                    _saveSignature();
                                    await Future.delayed(const Duration(seconds: 2));
                                    // Now show the save confirmation dialog after a 2-second delay
                                    _showSaveConfirmationDialog();
                                    await Future.delayed(const Duration(seconds: 1));
                                    setState(() {
                                      isLoading = false; // Stop loading
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff50B5E5),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 6),
              StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState) { return const BottomBarRow();  },
               )
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _pickFile() async {

    final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['svg','jpeg','jpg','png']
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _selectedImageBytes = result.files.single.bytes!;
        _isDrawing = false;
      });
    }
  }

  Future<void> _saveSignature() async {
    if (_isDrawing) {
      // Convert drawing to image bytes
      _selectedImageBytes = await convertPointsToImage();
    }
    // Perform further actions with _selectedImageBytes
    widget.onSignatureSelected(_selectedImageBytes);
  }

  Future<Uint8List?> convertPointsToImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromPoints(const Offset(0, 0), const Offset(400, 400)));
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6;

    for (int i = 0; i < _points.length - 1; i++) {
      if (_points[i] != null && _points[i + 1] != null) {
        canvas.drawLine(_points[i]!, _points[i + 1]!, paint);
      }
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(947, 389);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }



  void _showSaveConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Container(
              width: 551,
              height: 532,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _preloadedSvg,
                  SizedBox(height: MediaQuery.of(context).size.height / 20),
                  const Text(
                    'Successfully saved!',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        color: Color(0xff686464)),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 25),
                  Container(
                    width: 120,
                    height: 90,
                    child: ClipRect(
                      child: _selectedImageBytes != null
                          ? Image.memory(
                        _selectedImageBytes!,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      )
                          : CustomPaint(
                        painter: PopupSignaturePainter(
                          points: _points,
                          originalSize: const Size(947, 389),
                          targetSize: const Size(120, 90),
                        ),
                        size: const Size(120, 90),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 25),
                  ElevatedButton(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Continue',
                          style: BlueButtonTextConst.customTextStyle(context),
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width / 140),
                        const Icon(
                          Icons.arrow_right_alt_outlined,
                          size: 24,
                        ),
                      ],
                    ),
                    onPressed: () async{
                      print("Signature::: ${_selectedImageBytes!}");
                     await uploadSignature(context,widget.employeeId,_selectedImageBytes);
                     await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OfferLetterDescriptionScreen(
                            signatureBytes: _selectedImageBytes,
                            employeeId: widget.employeeId,
                            depID: widget.depID,
                            templateId: widget.templateId,
                            employeeEnrollId: widget.employeeEnrollId,
                          ),
                        ),
                      );

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff50B5E5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  SignaturePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => true;
}


class PopupSignaturePainter extends CustomPainter {
  final List<Offset?> points;
  final Size originalSize;
  final Size targetSize;

  PopupSignaturePainter({
    required this.points,
    required this.originalSize,
    required this.targetSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;

    double scaleX = targetSize.width / originalSize.width;
    double scaleY = targetSize.height / originalSize.height;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(
          Offset(points[i]!.dx * scaleX, points[i]!.dy * scaleY),
          Offset(points[i + 1]!.dx * scaleX, points[i + 1]!.dy * scaleY),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(PopupSignaturePainter oldDelegate) => true;
}