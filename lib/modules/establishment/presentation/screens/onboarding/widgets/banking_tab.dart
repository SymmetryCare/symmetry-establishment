import 'package:flutter/material.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/widgets/acknowledgement.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/widgets/health_record_tab.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/widgets/widgets/banking_tab_constant.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';

///prachi
class Banking extends StatelessWidget {
  final int employeeId;
  const Banking({Key? key, required this.employeeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: 1,
          itemBuilder: (context, index) {
            return Column(
              children: [
                BankingTabContainerConstant(employeeId: employeeId,),
                const SizedBox(
                  height: AppSize.s8,
                )
              ],
            );
          }),
    );
  }
}


class HealthRecord extends StatelessWidget {
  final int employeeId;
  const HealthRecord({Key? key, required this.employeeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: 1,
          itemBuilder: (context, index) {
            return Column(
              children: [
                HealthRecordConstant(employeeId: employeeId,),
                const SizedBox(
                  height: AppSize.s8,
                )
              ],
            );
          }),
    );
  }
}

class Acknowledgement extends StatelessWidget {
  final int employeeId;
  const Acknowledgement({Key? key, required this.employeeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: 1,
          itemBuilder: (context, index) {
            return Column(
              children: [
                AcknowledgementTab(employeeId: employeeId,),
                const SizedBox(
                  height: AppSize.s8,
                )
              ],
            );
          }),
    );
  }
}