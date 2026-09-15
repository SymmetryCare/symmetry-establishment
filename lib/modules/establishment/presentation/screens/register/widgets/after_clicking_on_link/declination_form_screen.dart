import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/bottom_row.dart';
import 'dart:typed_data';

import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/hr_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/top_row.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_nine_screen.dart';

class DeclinationPageScreen extends StatefulWidget {
  @override
  _DeclinationPageScreenState createState() => _DeclinationPageScreenState();
}

class _DeclinationPageScreenState extends State<DeclinationPageScreen> {
  bool _isDrawing = true;
  List<Offset?> _points = [];
  Uint8List? _selectedImageBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: TopRowConstant(),
      ),
      body: SingleChildScrollView(
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
                      SizedBox(height: MediaQuery.of(context).size.height / 6),
                      Text(
                        AppString.upload_signature,
                        style:FormHeading.customTextStyle(context)
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height / 40),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F7FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Signature is needed to sign the declination form and few other forms',
                          style: TextStyle(
                            color: Color(0xFF686464),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height / 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.edit, color: Color(0xFF50B5E5), size: 24),
                                label: Text(
                                  'Draw',
                                  style: TransparentButtonTextConst.customTextStyle(context)
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isDrawing = true;
                                    _selectedImageBytes = null;
                                  });
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  alignment: Alignment.centerLeft,
                                ),
                              ),
                              Container(
                                height: 2,
                                width: 85,
                                color: _isDrawing ? const Color(0xFF50B5E5) : Colors.transparent,
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.file_upload_outlined, color: Colors.grey, size: 24),
                                label: const Text(
                                  'Upload',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onPressed: _pickFile,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  alignment: Alignment.centerLeft,
                                ),
                              ),
                              Container(
                                height: 2,
                                color: !_isDrawing ? const Color(0xFF50B5E5) : Colors.transparent,
                              ),
                            ],
                          ),
                          Expanded(child: Container()),
                        ],
                      ),
                      Divider(color: Colors.grey[300]),
                      SizedBox(height: MediaQuery.of(context).size.height / 30),
                      Center(
                        child: Text(
                          _isDrawing
                              ? 'Sign your name using mouse or touchpad'
                              : 'Uploaded signature',
                          style: const TextStyle(
                            color: Color(0xff68646480),
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height / 30),
                      Center(
                        child: Container(
                          height: 389,
                          width: 947,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ClipRect(
                            child: _selectedImageBytes != null && !_isDrawing
                                ? Image.memory(
                              _selectedImageBytes!,
                              fit: BoxFit.contain,
                            )
                                : GestureDetector(
                              onPanUpdate: (details) {
                                setState(() {
                                  RenderBox renderBox =
                                  context.findRenderObject() as RenderBox;
                                  Offset localPosition =
                                  renderBox.globalToLocal(details.localPosition);
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
                      SizedBox(height: MediaQuery.of(context).size.height / 15),
                      Padding(
                        padding: const EdgeInsets.only(left: 110.0),
                        child: Row(
                          children: [
                            ElevatedButton(
                              child: Text(
                                AppString.cancel,
                                style: BlueButtonTextConst.customTextStyle(context)
                              ),
                              onPressed: () {
                                setState(() {
                                  _isDrawing = true;
                                  _points.clear();
                                  _selectedImageBytes = null;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xff50B5E5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(color: Color(0xff50B5E5), width: 1.5)),
                              ),
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width / 5),
                            Row(
                              children: [
                                ElevatedButton(
                                  child: Text(
                                    AppString.reset,
                                    style:  BlueButtonTextConst.customTextStyle(context)
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _points.clear();
                                      _selectedImageBytes = null;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xff50B5E5),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: const BorderSide(color: Color(0xff50B5E5), width: 1.5)),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width / 80),
                            ElevatedButton(
                              child: Text(
                                AppString.save,
                                style:  BlueButtonTextConst.customTextStyle(context)
                              ),
                              onPressed: () {
                                _showSaveConfirmationDialog();
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
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 6),
            const Row(
              children: [BottomBarRow()],
            )
          ],
        ),
      ),
    );
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _selectedImageBytes = result.files.single.bytes;
        _isDrawing = false;
        _points.clear();
      });
    }
  }

  void _saveSignature() {
    if (_selectedImageBytes != null) {
      print('Uploaded image saved');
      // Here you would typically save the _selectedImageBytes
    } else if (_points.isNotEmpty) {
      print('Drawn signature saved with ${_points.length} points');
      // Here you would typically convert the points to an image and save it
    } else {
      print('No signature to save');
    }
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
                  SvgPicture.asset('images/sign_saving.svg'),
                  SizedBox(height: MediaQuery.of(context).size.height / 20),
                  const Text(
                    'Successfully saved!',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
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
                          style: BlueButtonTextConst.customTextStyle(context)
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width / 140),
                        const Icon(
                          Icons.arrow_right_alt_outlined,
                          size: 24,
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => const FormNineScreen()));
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
      ..strokeWidth = 5.0;

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
