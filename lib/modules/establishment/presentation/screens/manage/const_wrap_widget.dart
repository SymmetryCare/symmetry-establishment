import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/manage_card_grid.dart';


///onboarding tab
class WrapWidget extends StatefulWidget {
  final List<Widget> children;
  const WrapWidget({super.key, required this.children});

  @override
  State<WrapWidget> createState() => _WrapWidgetState();
}

class _WrapWidgetState extends State<WrapWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p20,
      ),
      child: Center(
        child: Container(
          width: 1180,
          alignment: Alignment.topLeft,
          child: Wrap(
            spacing: AppSize.s16,
            runSpacing: AppSize.s16,
            alignment: widget.children.length == 1
                ? WrapAlignment.start
                : WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: widget.children,
          ),
        ),
      ),
    );
  }
}





///

///manage tab

class WrapWidgetM extends StatefulWidget {
  final List<Widget> children;
  const WrapWidgetM({super.key, required this.children});

  @override
  State<WrapWidgetM> createState() => _WrapWidgetMState();
}

class _WrapWidgetMState extends State<WrapWidgetM> {
  @override
  Widget build(BuildContext context) {
    // The cards used to sit one per row at their own fixed 700px width, so a
    // wide panel showed a single column against a lot of empty space.
    // ManageCardGrid fits as many columns as the panel can hold and hands
    // each card its column's width.
    return Container(
      alignment: Alignment.topLeft,
      child: ManageCardGrid(children: widget.children),
    );
  }
}