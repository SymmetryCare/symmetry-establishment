import 'package:flutter/material.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/qualification_const_bar/qualificatin_emloyment_tab.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/qualification_const_bar/qualification_clinical_license_tab.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/qualification_const_bar/qualification_license_tab.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/qualification_const_bar/qualification_referance_tab.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/qualification_const_bar/widgets/onboarding_qualification.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/qualification_const_bar/qualification_education_tab.dart';

class OnBoardingQualificationEmployment extends StatelessWidget {
  final int employeeId;
  const OnBoardingQualificationEmployment({super.key, required this.employeeId});

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
                QualificationEmployment(employeeId: employeeId,),
                const SizedBox(
                  height: AppSize.s8,
                )
              ],
            );
          }),
    );
  }
}


class OnBoardingQualificationEducation extends StatelessWidget {
  final int employeeId;
  const OnBoardingQualificationEducation({Key? key, required this.employeeId}) : super(key: key);

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
                QualificationEducation(employeeId: employeeId,),
                const SizedBox(
                  height: AppSize.s8,
                )
              ],
            );
          }),
    );
  }
}
class OnBoardingQualificationReference extends StatelessWidget {
  final int employeeId;
  const OnBoardingQualificationReference({super.key, required this.employeeId});

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
                QualificationReferance(employeeId: employeeId,),
                const SizedBox(
                  height: AppSize.s8,
                )
              ],
            );
          }),
    );
  }
}

class OnBoardingQualificationLicense extends StatelessWidget {
  final int employeeId;
  const OnBoardingQualificationLicense({super.key, required this.employeeId});

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
                QualificationLicense(employeeId: employeeId,),
                const SizedBox(
                  height: AppSize.s8,
                )
              ],
            );
          }),
    );
  }
}

class OnBoardingQualificationGeneralLicenses extends StatelessWidget {
  final int employeeId;
  const OnBoardingQualificationGeneralLicenses({super.key, required this.employeeId});

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
                QualificationGeneralLicenses(employeeId: employeeId,),
                const SizedBox(
                  height: AppSize.s8,
                )
              ],
            );
          }),
    );
  }
}