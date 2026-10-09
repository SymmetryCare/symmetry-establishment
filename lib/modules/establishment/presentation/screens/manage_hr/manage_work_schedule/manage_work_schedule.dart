import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_establishment/app/router/route_tab_sync.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/manage_work_schedule/work_schedule/define_holidays.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/manage_work_schedule/work_schedule/define_work_weeks.dart';

class WorkScheduleProvider extends ChangeNotifier {
  /// [initialIndex] is the tab the URL opened the page on.
  WorkScheduleProvider({int initialIndex = 0})
      : _selectedIndex = initialIndex,
        _pageController = PageController(initialPage: initialIndex);

  int _selectedIndex;
  final PageController _pageController;

  int get selectedIndex => _selectedIndex;
  PageController get pageController => _pageController;

  void selectButton(int index) {
    _selectedIndex = index;
    _pageController.jumpToPage(
      index,
      //duration: const Duration(milliseconds: 500),
      //curve: Curves.ease,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class WorkSchedule extends StatelessWidget {
  const WorkSchedule({super.key, this.initialTab = 0, this.onTabChanged});

  /// The tab the URL names: Shifts & Batches or Define Holidays.
  final int initialTab;

  /// A tab was tapped; puts it in the URL.
  final ValueChanged<int>? onTabChanged;

  void _onTabTapped(WorkScheduleProvider provider, int index) {
    provider.selectButton(index);
    onTabChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final workScheduleProvider = Provider.of<WorkScheduleProvider>(context);

    return RouteTabSync(
      tab: initialTab,
      onTabChanged: (int tab) {
        if (workScheduleProvider.selectedIndex != tab) {
          workScheduleProvider.selectButton(tab);
        }
      },
      child: Consumer<WorkScheduleProvider>(
        builder: (context, providerState, child) {
          return Material(
            color: Colors.white,
            child: Column(
              children: [
                // Header Buttons
                Padding(
                  padding: const EdgeInsets.only(
                      left: AppPadding.p15, top: AppPadding.p20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: AppSize.s30,
                          width: AppSize.s315,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: ColorManager.blueprime,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // Shift & Batch Button
                              InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                onTap: () => _onTabTapped(providerState, 0),
                                child: Container(
                                  height: AppSize.s30,
                                  width: AppSize.s160,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    const BorderRadius.all(Radius.circular(20)),
                                    color: providerState.selectedIndex == 0
                                        ? Colors.white
                                        : Colors.transparent,
                                  ),
                                  child: Center(
                                    child: Text(
                                      AppStringEM.shiftbatch,
                                      style: BlueBgTabbar.customTextStyle(
                                          0, providerState.selectedIndex),
                                    ),
                                  ),
                                ),
                              ),
                              // Define Holiday Button
                              InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                onTap: () => _onTabTapped(providerState, 1),
                                child: Container(
                                  height: AppSize.s30,
                                  width: AppSize.s155,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    const BorderRadius.all(Radius.circular(20)),
                                    color: providerState.selectedIndex == 1
                                        ? Colors.white
                                        : Colors.transparent,
                                  ),
                                  child: Center(
                                    child: Text(
                                      AppStringEM.defineHoliday,
                                      style: BlueBgTabbar.customTextStyle(
                                          1, providerState.selectedIndex),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Page View Content
                Expanded(
                  flex: 10,
                  child: Stack(
                    children: [
                      providerState.selectedIndex == 1
                          ? const Offstage()
                          : Container(
                        height: MediaQuery.of(context).size.height / 3.5,
                        decoration: BoxDecoration(
                          color: Color(0xFFF2F9FC),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Inner shadow effect at the top
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height:
                                8, // Adjust the height of the shadow effect
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black
                                          .withOpacity(0.2), // Darker at top
                                      Colors.transparent, // Fades out
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal:providerState.selectedIndex == 1 ?
                          MediaQuery.of(context).size.width / 45 :
                          MediaQuery.of(context).size.width / 20,
                        ),
                        child: PageView(
                          controller: providerState.pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            DefineWorkWeek(),
                            DefineHolidays(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}
