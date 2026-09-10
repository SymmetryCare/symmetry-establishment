

import 'package:flutter/material.dart';

import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/bottom_row.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/termination/termination_head_tabbar.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/thank_you_screen.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/hr_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/top_row.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/certificate_screen.dart';

class CertificateOfCompletionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: TopRowConstant(),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'Declination Form',
                style:FormHeading.customTextStyle(context)
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        height: 50.0,
                        width: 404.0,
                        child: const Center(
                          child: Text(
                            'Document Signed Successfully!',
                            style:TextStyle(
                              fontSize: 12,
                              color: Color(0xFF686464),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 20),
              Stack(
                children: [
                  Container(
                    height: 1241.0,
                    width: 878.0,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 4),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              buildCertificateHeader(),
                              const SizedBox(height: 40),
                              _buildDecorativeSymbol(),
                              const SizedBox(height: 40),
                              buildCertificateBody(),
                              const SizedBox(height: 90),
                              buildSignatureSection(),
                              const SizedBox(height: 60.0),
                              buildTitleSection(),
                            ],
                          ),
                        ),
                      ),
                    ),

                  ),
                ],
              ),
              const SizedBox(height: 30),
              buildActionButtons(context),
              const SizedBox(height: 30),
              const Row(
                children: [
                  BottomBarRow()
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCertificateHeader() {
    return Center(
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 50.0),
              Expanded(child: _buildDecorativeSymbol()),
              const SizedBox(width: 80.0),
              const Text(
                'C E R T I F I C A T E  O F \n    C O M P L E T I O N',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 80),
              Expanded(child: _buildDecorativeSymbol()),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildCertificateBody() {
    return const Column(
      children: [
        Text(
          'T H I S   A W A R D   C E R T I F I E S   T H A T',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 70.0),
        Text(
          '<Enter Name of Recipient>',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
          ),
        ),
        Divider(height: 30, color: Colors.grey),
        SizedBox(height: 70.0),
        Text(
          'H A S   S U C C E S S F U L L Y   C O M P L E T E D',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 70.0),
        Text(
          '<Enter comments>',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
        Divider(height: 20, color: Colors.grey),
      ],
    );
  }

  Widget buildSignatureSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildSignatureColumn('<Enter date>', 'D A T E'),
        const SizedBox(width: 60),
        buildSignatureColumn('', 'S I G N A T U R E'),
      ],
    );
  }

  Widget buildSignatureColumn(String text1, String text2) {
    return Expanded(
      child: Column(
        children: [
          Text(
            text1,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const Divider(height: 20, color: Colors.grey),
          Text(
            text2,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildTitleSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Container()),
        const SizedBox(width: 60),
        buildSignatureColumn('Enter title', 'T I T L E'),
      ],
    );
  }

  Widget buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context , MaterialPageRoute(builder: (context) => CertificateOfCompletion()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.arrow_back,
                    color: Color((0xFF50B5E5)),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Back',
                    style:TransparentButtonTextConst.customTextStyle(context)
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const OnBoardingThankYou()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF50B5E5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Continue',
                    style:BlueButtonTextConst.customTextStyle(context)
                  ),
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        )

      ],
    );
  }

  Widget _buildDecorativeSymbol() {
    return const Text(
      '❧',
      style: TextStyle(fontSize: 90, color: Colors.black),
    );
  }
}
