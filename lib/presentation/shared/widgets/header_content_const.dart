import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';

class HeaderContentConst extends StatefulWidget {
  final String heading;
  final Widget content;
  final bool isAsterisk;
  final bool isDoc;
  final TextStyle? styleHeading;
  final double? marginVertical;
  final FocusNode? focusNode;

  const HeaderContentConst({
    super.key,
    required this.heading,
    required this.content,
    this.styleHeading,
    this.isAsterisk = false,
    this.isDoc = false,
    this.marginVertical = 6,
    this.focusNode,
  });

  @override
  State<HeaderContentConst> createState() => _HeaderContentConstState();
}

class _HeaderContentConstState extends State<HeaderContentConst> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: widget.marginVertical!),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: widget.heading,
              style: widget.styleHeading ?? AllPopupHeadings.customTextStyle(context),
              children: [
                if (widget.isAsterisk)
                  TextSpan(
                    text: ' *',
                    style: AllPopupHeadings.customTextStyle(context)
                        ?.copyWith(color: Colors.red),
                  ),
                if (widget.isDoc)
                  TextSpan(
                    text: ' Upload document upto 20MB only',
                    style: CommonErrorMsg.customTextStyle(context),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSize.s5),

          /// Content widget (e.g., upload doc)
          widget.content,
        ],
      ),
    );
  }
}