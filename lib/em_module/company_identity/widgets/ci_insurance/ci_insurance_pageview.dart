import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/color.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import '../../../../../../app/resources/establishment_resources/establish_theme_manager.dart';


class CiPageview extends StatelessWidget {
  final int docId;
  final PageController managePageController;
  final int selectedIndex;
  final Function(int) selectButton;
  final List<String> nameList;
  final List<Widget> screenList;
  final double mediaQueryWidth;


  CiPageview({
    Key? key,
    required this.managePageController,
    required this.selectedIndex,
    required this.selectButton,
    required this.nameList,
    required this.screenList, required this.mediaQueryWidth, required this.docId,
  }) : super(key: key);
  // CiInsurancePageview({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppPadding.p12,horizontal: AppPadding.p8),
          child: Container(
            height: AppSize.s40,
            width: MediaQuery.of(context).size.width / mediaQueryWidth,
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: nameList
                  .asMap()
                  .entries
                  .map(
                    (entry) => InkWell(
                  //splashColor: Colors.white,
                  highlightColor: Color(0xFFF2F9FC),
                  hoverColor: Color(0xFFF2F9FC),
                  child: Container(
                    height: AppSize.s40,
                    width: MediaQuery.of(context).size.width / 10,
                    child: Column(
                      children: [
                        Text(
                          entry.value,
                          textAlign: TextAlign.center,
                          style:TransparentBgTabbar.customTextStyle(selectedIndex, 0)
                        ),
                        selectedIndex == entry.key ?
                        Divider(color:ColorManager.blueprime,thickness: 2,):Offstage()
                      ],
                    ),
                  ),
                  onTap: () => selectButton(entry.key),
                ),
              )
                  .toList(),
            ),
          ),
        ),
       
        Expanded(
          flex: 10,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 60),
            child: PageView(
                controller: managePageController,
                physics: NeverScrollableScrollPhysics(),
                children: screenList),
          ),
        ),
      ],
      ),
    );
  }
}