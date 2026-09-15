import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_establishment/modules/establishment/providers/hr_onboarding_provider.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/widgets/banking_tab.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/widgets/form_status.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/widgets/genaral_tab.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/widgets/qualification_tab.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/bottom_row.dart';


class NewOnboardScreen extends StatefulWidget {
  final VoidCallback onBackPressed;
  const NewOnboardScreen({super.key, required this.onBackPressed, });

  @override
  State<NewOnboardScreen> createState() => _NewOnboardScreenState();
}

class _NewOnboardScreenState extends State<NewOnboardScreen> {
  final PageController _onboardPageController = PageController();
  int _selectedIndex = 0;
  int employeeIdCheck = 0;
  String employeeName = '';
  String imageUrl = '';
  int departmentId = 0;

  void _selectButton(int index, int employeeId, String name, String url, int deptId) {
    setState(() {
      _selectedIndex = index;
      employeeIdCheck = employeeId;
      employeeName = name;
      imageUrl = url;
      departmentId = deptId;
    });
    _onboardPageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  void _handleBackButton(bool value) {
    if (value) {
      setState(() {
        _selectedIndex = 0;
      });
      _onboardPageController.jumpToPage(0);
      // The list tab is kept alive by the PageView, so coming back to it
      // rebuilds nothing on its own — refetch here so a clinician whose
      // onboarding progressed on one of the detail tabs shows their new
      // status straight away.
      Provider.of<HrOnboardingProvider>(context, listen: false)
          .getStreamData(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingTabManage(
      managePageController: _onboardPageController,
      selectedIndex: _selectedIndex,
      selectButton: _selectButton,
      employeeId: employeeIdCheck,
      employeeName: employeeName,
      imageUrl: imageUrl,
      backButtonCallBack: _handleBackButton, onBackPressed: widget.onBackPressed, departmentId: departmentId,
    );
  }
}


///
typedef BackButtonCallBack = void Function(bool val);

class OnboardingTabManage extends StatefulWidget {
  final int departmentId;
  final PageController managePageController;
  final int selectedIndex;
  final int employeeId;
  final String employeeName;
  final String imageUrl;
  final BackButtonCallBack backButtonCallBack;
  final VoidCallback onBackPressed;
  final void Function(int,int, String, String, int) selectButton;
  const OnboardingTabManage({super.key, required this.managePageController, required this.selectedIndex, required this.selectButton,
    required this.employeeId, required this.employeeName,required this.backButtonCallBack, required this.onBackPressed, required this.imageUrl, required this.departmentId,
  });

  @override
  State<OnboardingTabManage> createState() => _OnboardingTabManageState();
}

class _OnboardingTabManageState extends State<OnboardingTabManage> {
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> _categories = [
      // AppString.general,
      AppString.qualification,
      AppString.banking,
      AppString.healthRecord,
      AppString.acknowledgement,
      AppString.formStatus
    ];
    return LayoutBuilder(
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
            child: SizedBox(
              width: contentWidth,
              // ── height removed: was constraints.maxHeight (Infinity) which crashed layout ──
              // ── Expanded children work here because the parent TabBarView provides bounded height ──
              child: Material(
                color: Colors.white ,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.selectedIndex != 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20, ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 2.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      if (widget.selectedIndex != 0)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: AppPadding.p10,left: 1),
                                          child: Row(
                                            children: [
                                              ///back
                                              Padding(
                                                padding: const EdgeInsets.only(right: 20),
                                                child: InkWell(
                                                    onTap: (){
                                                      widget.backButtonCallBack(true);
                                                    },
                                                    child:Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(
                                                          Icons.arrow_back,
                                                          size: 20,
                                                          color: ColorManager.mediumgrey,

                                                        ),
                                                      ],
                                                    )
                                                ),
                                              ),


                                              CircleAvatar(
                                                  radius: 25,
                                                  backgroundColor: Colors.white,
                                                  child:
                                                  ClipOval(

                                                    child: widget.imageUrl == 'imgurl' ||
                                                        widget.imageUrl.isEmpty
                                                        ? CircleAvatar(
                                                      radius: 25,
                                                      backgroundColor: ColorManager.faintGrey,
                                                      child: Image.asset("images/profilepic.png",width: double.infinity,
                                                        height: double.infinity,),
                                                    )
                                                        : Image.network(
                                                      widget.imageUrl,
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      loadingBuilder: (context, child, loadingProgress) {
                                                        if (loadingProgress == null) {
                                                          return child;
                                                        } else {
                                                          return Center(
                                                            child: CircularProgressIndicator(
                                                                value: loadingProgress.expectedTotalBytes != null
                                                                    ? loadingProgress.cumulativeBytesLoaded /
                                                                    (loadingProgress.expectedTotalBytes ?? 1)
                                                                    : null),
                                                          );
                                                        }
                                                      },
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return CircleAvatar(child: Image.asset("images/profilepic.png"));
                                                      },
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                              ),
                                              const SizedBox(width: AppSize.s20,),
                                              Text(
                                                widget.employeeName,
                                                style: CompanyIdentityManageHeadings.customTextStyle(context),
                                              ),
                                            ],
                                          ),
                                        ),

                                    ],
                                  ),
                                  const SizedBox(height: 5,),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Material(
                                        elevation: 4,  // Set elevation to 0 to remove shadow
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          height: AppSize.s30,
                                          decoration: BoxDecoration(

                                            borderRadius: BorderRadius.circular(20),
                                            color: ColorManager.blueprime,
                                          ),
                                          child: Row(
                                            // mainAxisSize: MainAxisSize.min,
                                            children: _categories
                                                .asMap()
                                                .entries
                                                .map(
                                                  (entry) => InkWell(
                                                splashColor: Colors.transparent,
                                                highlightColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                child: Container(
                                                  height: AppSize.s31,
                                                  padding: const EdgeInsets.symmetric(horizontal: 75, vertical: 7),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(20),
                                                    color: widget.selectedIndex - 1 == entry.key
                                                        ? Colors.white
                                                        : ColorManager.blueprime,
                                                  ),
                                                  child: Text(
                                                    entry.value,
                                                    textAlign: TextAlign.center,
                                                    softWrap: false,
                                                    style: TextStyle(
                                                      fontSize: FontSize.s14,
                                                      fontWeight: FontWeight.w600,
                                                      color: widget.selectedIndex - 1 == entry.key
                                                          ? ColorManager.mediumgrey
                                                          : ColorManager.white,
                                                    ),
                                                  ),
                                                ),
                                                onTap: () => widget.selectButton(
                                                  entry.key + 1,
                                                  widget.employeeId,
                                                  widget.employeeName,
                                                  widget.imageUrl,
                                                  widget.departmentId,
                                                ),
                                              ),
                                            )
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (widget.selectedIndex != 0)
                              const SizedBox(
                              )
                          ],
                        ),
                      ),
                    Expanded(
                      flex: 10,
                      child: PageView(
                        controller: widget.managePageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          OnboardingGeneral(selectButton: widget.selectButton, goBackButtion: widget.onBackPressed),
                          OnboardingQualification(employeeId: widget.employeeId, departmentId: widget.departmentId,),
                          Banking(employeeId: widget.employeeId,),
                          HealthRecord(employeeId: widget.employeeId,),
                          Acknowledgement(employeeId: widget.employeeId,),
                          FormStatusScreen(employeeId: widget.employeeId,),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}