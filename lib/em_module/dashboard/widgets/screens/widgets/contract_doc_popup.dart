import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/common_resources/em_dashboard_theme.dart';
import 'package:prohealth/app/resources/font_manager.dart';
import 'package:prohealth/presentation/screens/em_module/widgets/dialogue_template.dart';
import '../../../../../../../app/resources/color.dart';
import '../../../../../../../app/resources/establishment_resources/em_dashboard_string_manager.dart';
import '../../../../../../../app/resources/establishment_resources/establish_theme_manager.dart';
import '../../../../../../../app/resources/value_manager.dart';

class ContractDocAuditPopup extends StatelessWidget {
  const ContractDocAuditPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
        width: AppSize.s600,
        height: AppSize.s450, body: [
          SizedBox(height: AppSize.s10,),
          Container(
            height: AppSize.s30,
            padding: EdgeInsets.only(left: AppPadding.p15,right: AppPadding.p25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  EmDashboardStringManager.NoOfOffice,
                  textAlign: TextAlign.start,
                  style: PopupCompStyle.customTextStyle(context)
                ),
                Padding(
                  padding: const EdgeInsets.only(left: AppPadding.p60),
                  child: Text(
                      EmDashboardStringManager.status,
                    textAlign: TextAlign.start,
                    style: PopupCompStyle.customTextStyle(context)
                  ),
                ),
                Text(
                    EmDashboardStringManager.randomNum ,
                  textAlign: TextAlign.center,
                  style: PopupCompStyle.customTextStyle(context)
                ),
              ],
            ),
          ),
          SizedBox(height: AppSize.s10,),
          Container(
            height: AppSize.s260,
            padding: EdgeInsets.only(left: AppPadding.p15,),
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: 15,
              itemBuilder: (context, index) {
                //int serialNumber = index + 1 + (currentPage - 1) * itemsPerPage;
                // String formattedSerialNumber = serialNumber.toString().padLeft(2, '0');
                // EmployeeDocumentModal employeedoc = paginatedData[index];
                return Column(
                  children: [
                    SizedBox(
                      height: AppSize.s10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex:1,
                          child: Text(
                            "Audit 1",
                            textAlign: TextAlign.start,
                            style: EmDashListviewDataText.customTextStyle(context)
                          ),
                        ),

                        Expanded(
                          flex:1,
                          child: Text(
                            "Pass",
                            textAlign: TextAlign.center,
                            style: EmDashListviewDataText.customTextStyle(context)
                          ),
                        ),
                        Expanded(
                          flex:1,
                          child: Text(
                            "0.12587",
                            textAlign: TextAlign.center,
                            style: EmDashListviewDataText.customTextStyle(context)
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),)
        ],
        bottomButtons: Container(), title: EmDashboardStringManager.randompass);
  }
}

///penalty popup
class ContractDocPenaltyPopup extends StatelessWidget {
  const ContractDocPenaltyPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(width: AppSize.s600,
        height: AppSize.s450, body: [
          SizedBox(height: AppSize.s10,),
          Container(
            height: AppSize.s30,
            padding: EdgeInsets.only(left: AppPadding.p15,right: AppPadding.p25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    EmDashboardStringManager.NoOfOffice,
                  textAlign: TextAlign.start,
                  style: PopupCompStyle.customTextStyle(context)
                ),
                //Expanded(flex:1 ,child: Container()),
                Padding(
                  padding: const EdgeInsets.only(left: AppPadding.p50),
                  child: Text(
                      EmDashboardStringManager.date,
                    textAlign: TextAlign.start,
                    style: PopupCompStyle.customTextStyle(context)
                  ),
                ),
                //SizedBox(width: 30,),
                Text(
                    EmDashboardStringManager.penaltyAmt,
                  textAlign: TextAlign.center,
                  style: PopupCompStyle.customTextStyle(context)
                ),
              ],
            ),
          ),
          SizedBox(height: AppSize.s10,),
          Container(
            height: AppSize.s260,
            padding: EdgeInsets.only(left: AppPadding.p15,),
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: 15,
              itemBuilder: (context, index) {
                //int serialNumber = index + 1 + (currentPage - 1) * itemsPerPage;
                // String formattedSerialNumber = serialNumber.toString().padLeft(2, '0');
                // EmployeeDocumentModal employeedoc = paginatedData[index];
                return Column(
                  children: [
                    SizedBox(
                      height: AppSize.s10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex:1,
                          child: Text(
                            "Audit 1",
                            textAlign: TextAlign.start,
                            style: EmDashListviewDataText.customTextStyle(context)
                          ),
                        ),

                        Expanded(
                          flex:1,
                          child: Text(
                            "27-07-2025",
                            textAlign: TextAlign.center,
                            style: EmDashListviewDataText.customTextStyle(context)
                          ),
                        ),
                        Expanded(
                          flex:1,
                          child: Text(
                            r"$500",
                            textAlign: TextAlign.center,
                            style: EmDashListviewDataText.customTextStyle(context)
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),)
        ],
        bottomButtons: Container(), title: EmDashboardStringManager.AuditpenaltyAmt);
  }
}

///big popup
class FullScreenPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppPadding.p20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
              IconButton(onPressed: (){
                Navigator.pop(context);
              },
                icon: Icon(Icons.close,))
            ],),
          ),
        SizedBox(height: AppSize.s200,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: FontSize.s24,
                    fontWeight: FontWeight.w800,
                    color: ColorManager.mediumgrey,
                  ),
                  children: [
                    TextSpan(text: "You have "),
                    TextSpan(
                      text: "30 ",
                      style: TextStyle(
                        fontSize: FontSize.s30,
                        fontWeight: FontWeight.w800,
                        color: ColorManager.bluebottom,
                      ),
                    ),
                    TextSpan(text: "days remaining before your contract expires."),
                  ],
                ),
              ),
                  SizedBox(height: AppSize.s20),
                  Text(
                    "Your Auto-Renew is OFF\nYour subscription will NOT automatically renew",
                    style: TextStyle(fontSize: FontSize.s20, color: ColorManager.mediumgrey,fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSize.s30),
                  ElevatedButton(
                    onPressed: () {
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.EMbrightred,
                      shadowColor: ColorManager.mediumgrey,
                      elevation: 6,
                      padding: EdgeInsets.symmetric(horizontal: AppPadding.p40, vertical: AppPadding.p15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Adjust the radius for a more circular shape
                      ),
                    ),
                    child: Text(
                      "TURN AUTO-RENEW ON",
                      style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600,fontSize: FontSize.s12),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "go back",
                      style: EmDashViewMoreText.customTextStyle(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}