// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:prohealth/app/app.dart';
// import 'package:prohealth/app/resources/color.dart';
//
// import '../../../../app/resources/font_manager.dart';
// import '../../../../app/resources/value_manager.dart';
// import 'widgets/chart.dart';
//
// class SMDashboardScreen extends StatefulWidget {
//   const SMDashboardScreen({super.key});
//
//   @override
//   State<SMDashboardScreen> createState() => _DashboardScreenState();
// }
//
// class _DashboardScreenState extends State<SMDashboardScreen> {
//   String selectedValueToday = 'TODAY';
//   List<String> dropdownItemsToday = ['TODAY', 'YESTERDAY', 'LAST WEEK'];
//
//   String selectedValueThisMonthA = 'This Month';
//   final List<String> dropdownItemsThisMonthA = ['This Month', 'Last Month', 'This Year'];
//
//   String selectedValueThisMonthB = 'This Month';
//   final List<String> dropdownItemsThisMonthB = ['This Month', 'Last Month', 'This Year'];
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.vertical,
//       child: Padding(
//         padding:  EdgeInsets.symmetric(horizontal: 20),
//         child: Container(
//           child: Column(
//             children: [
//               Container(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     CustomContainer(
//                       imagePath: 'images/PatientOnBed.png',
//                       numberText: '250',
//                       descriptionText: 'Partially admitted',
//                     ),
//                     SizedBox(width: MediaQuery.of(context).size.width / 40),
//                     CustomContainer(
//                       imagePath: 'images/TableWithLamp.png',
//                       numberText: '89',
//                       descriptionText: 'Partially Scheduled',
//                     ),
//                     SizedBox(width: MediaQuery.of(context).size.width / 40),
//                     CustomContainer(
//                       imagePath: 'images/HospitalBuilding.png',
//                       numberText: '300',
//                       descriptionText: 'Not admitted',
//                     ),
//                     SizedBox(width: MediaQuery.of(context).size.width / 40),
//                     CustomContainer(
//                       imagePath: 'images/PatientOnBed.png',
//                       numberText: '52',
//                       descriptionText: 'Not admitted',
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: MediaQuery.of(context).size.height / 80),
//               Padding(
//                 padding: EdgeInsets.only(left: 32.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Container(
//                               height: AppSize.s98,
//                               width: MediaQuery.of(context).size.width/2.5,
//                               decoration: BoxDecoration(
//                                 color: ColorManager.white,
//                                 borderRadius: BorderRadius.circular(36.0),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: ColorManager.black.withOpacity(0.5),
//                                     offset: Offset(0, 4),
//                                     blurRadius: 4,
//                                     spreadRadius: 0,
//                                   ),
//                                 ],
//                               ),
//                               child: Row(
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.spaceEvenly,
//                                 children: [
//                                   Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: [
//                                       Padding(
//                                         padding: const EdgeInsets.only(left: 38.0), //28
//                                         child: Text(
//                                           'Number of \n Patients',
//                                           style: GoogleFonts.kanit(
//                                             decoration: TextDecoration.none,
//                                             fontSize: MediaQuery.of(context).size.width * 0.01,  //16
//                                             fontWeight: FontWeightManager.semiBold,
//                                             color: ColorManager.darkblue,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   SizedBox(
//                                       width: MediaQuery.of(context).size.width /
//                                           35),
//                                   Padding(
//                                     padding: const EdgeInsets.only(top: 18.0),
//                                     child: Column(
//                                       mainAxisAlignment:
//                                       MainAxisAlignment.start,
//                                       crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           'SCHEDULED TODAY',
//                                           style: GoogleFonts.firaSans(
//                                             decoration: TextDecoration.none,
//                                             fontSize: MediaQuery.of(context).size.width * 0.008, //12
//                                             fontWeight: FontWeightManager.medium,
//                                             color: ColorManager.black,
//                                           ),
//                                         ),
//                                         SizedBox(height: AppSize.s6),
//                                         Container(
//                                           height: AppSize.s2,
//                                           color: ColorManager.black,
//                                           width: AppSize.s60,
//                                         ),
//                                         SizedBox(height: AppSize.s6),
//                                         Text(
//                                           '25',
//                                           style: GoogleFonts.firaSans(
//                                             decoration: TextDecoration.none,
//                                             fontSize: FontSize.s30,
//                                             fontWeight: FontWeightManager.medium,
//                                             color: Color(0xffBBBBBB),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   SizedBox(width: AppSize.s35),
//                                   Padding(
//                                     padding: const EdgeInsets.only(top: 18.0),
//                                     child: Column(
//                                       mainAxisAlignment:
//                                       MainAxisAlignment.start,
//                                       crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           'TO BE SCHEDULED TODAY',
//                                           style: GoogleFonts.firaSans(
//                                             decoration: TextDecoration.none,
//                                             fontSize: MediaQuery.of(context).size.width * 0.008, //12
//                                             fontWeight: FontWeightManager.medium,
//                                             color: ColorManager.black,
//                                           ),
//                                         ),
//                                         SizedBox(height: AppSize.s6),
//                                         Container(
//                                           height: 2,
//                                           color: ColorManager.black,
//                                           width: AppSize.s60,
//                                         ),
//                                         SizedBox(height: AppSize.s6),
//                                         Text(
//                                           '12',
//                                           style: GoogleFonts.firaSans(
//                                             decoration: TextDecoration.none,
//                                             fontSize: FontSize.s30,
//                                             fontWeight: FontWeightManager.medium,
//                                             color: Color(0xffBBBBBB),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   SizedBox(
//                                       width: MediaQuery.of(context).size.width / 60),
//                                   Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     crossAxisAlignment: CrossAxisAlignment.center,
//                                     children: [
//                                       DropdownButton<String>(
//                                         value: selectedValueToday,
//                                         icon: Icon(Icons.keyboard_arrow_down,
//                                             color: Color(0xff686464), size: 18),
//                                         underline: Container(
//                                           height: 0,
//                                           color: Colors.transparent,
//                                         ),
//                                         items: dropdownItemsToday
//                                             .map<DropdownMenuItem<String>>(
//                                                 (String value) {
//                                               return DropdownMenuItem<String>(
//                                                 value: value,
//                                                 child: Text(
//                                                   value,
//                                                   style: GoogleFonts.firaSans(
//                                                     decoration: TextDecoration.none,
//                                                     fontSize: 12, //12
//                                                     fontWeight: FontWeightManager.medium,
//                                                     color: ColorManager.granitegray,
//                                                   ),
//                                                 ),
//                                               );
//                                             }).toList(),
//                                         onChanged: (String? newValue) {
//                                           setState(() {
//                                             selectedValueToday = newValue!;
//                                           });
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(
//                             height: MediaQuery.of(context).size.height / 65),
//                         Container(
//                             height: 307,
//                             width: MediaQuery.of(context).size.width/2.5,
//                             decoration: BoxDecoration(
//                                 color: Colors.grey,
//                                 borderRadius: BorderRadius.circular(47.0)),
//                             child: VisitsForCliniciansGraph()
//                         ),
//                       ],
//                     ),
//
//                     /////////
//                     //1st container
//
//                     SizedBox(width: MediaQuery.of(context).size.width / 40),
//                     Column(
//                       children: [
//                         Row(
//                           children: [
//                             Container(
//                               height: 199.0,
//                               width: MediaQuery.of(context).size.width/5.5, //276
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(20.0),
//                                 color: Colors.white,
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.25),
//                                     spreadRadius: 2,
//                                     blurRadius: 10,
//                                     offset: Offset(0, 4),
//                                   ),
//                                 ],
//                               ),
//                               child: Column(
//                                 children: [
//                                   Container(
//                                     height: AppSize.s37,
//                                     decoration: BoxDecoration(
//                                       color: ColorManager.blueprime,
//                                       borderRadius: BorderRadius.only(
//                                         topLeft: Radius.circular(20.0),
//                                         topRight: Radius.circular(20.0),
//                                       ),
//                                     ),
//                                     child: Column(
//                                       children: [
//                                         Padding(
//                                           padding:
//                                           const EdgeInsets.only(top: 10.0),
//                                           child: Row(
//                                             mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                             children: [
//                                               Text(
//                                                 'Clinicians With Less Than 15 Patients',
//                                                 style: GoogleFonts.firaSans(
//                                                   decoration:
//                                                   TextDecoration.none,
//                                                   fontWeight: FontWeightManager.medium,
//                                                   fontSize: AppSize.s12,
//                                                   color: ColorManager.white,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   SizedBox(height: AppSize.s15),
//                                   Padding(
//                                     padding: const EdgeInsets.only(left: 20.0),
//                                     child: Column(
//                                       mainAxisAlignment:
//                                       MainAxisAlignment.start,
//                                       children: [
//                                         Row(
//                                           children: [
//                                             CircleAvatar(
//                                               child:
//                                               Image.asset('images/1.png'),
//                                             ),
//                                             SizedBox(width: AppSize.s7),
//                                             Text(
//                                               'James Smith',
//                                               style: GoogleFonts.firaSans(
//                                                 decoration: TextDecoration.none,
//                                                 fontWeight: FontWeightManager.medium,
//                                                 fontSize: AppSize.s12,
//                                                 color: ColorManager.darkblue,
//                                               ),
//                                             ),
//                                             // SizedBox(width: MediaQuery.of(context).size.width/20),
//                                             Spacer(),
//                                             Padding(
//                                               padding: const EdgeInsets.only(
//                                                   right: 20.0),
//                                               child: Text(
//                                                 '14',
//                                                 style: GoogleFonts.firaSans(
//                                                   decoration:
//                                                   TextDecoration.none,
//                                                   fontWeight: FontWeightManager.medium,
//                                                   fontSize: AppSize.s12,
//                                                   color: ColorManager.blueprime,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         SizedBox(height: AppSize.s8),
//                                         Row(
//                                           children: [
//                                             CircleAvatar(
//                                               child:
//                                               Image.asset('images/2.png'),
//                                             ),
//                                             SizedBox(width: AppSize.s7),
//                                             Text(
//                                               'Michael Jackson',
//                                               style: GoogleFonts.firaSans(
//                                                 decoration: TextDecoration.none,
//                                                 fontWeight: FontWeightManager.medium,
//                                                 fontSize: AppSize.s12,
//                                                 color: ColorManager.darkblue,
//                                               ),
//                                             ),
//                                             // SizedBox(width: MediaQuery.of(context).size.width/20),
//                                             Spacer(),
//                                             Padding(
//                                               padding: const EdgeInsets.only(
//                                                   right: 20.0),
//                                               child: Text(
//                                                 '22',
//                                                 style: GoogleFonts.firaSans(
//                                                   decoration:
//                                                   TextDecoration.none,
//                                                   fontWeight: FontWeightManager.medium,
//                                                   fontSize: AppSize.s12,
//                                                   color: ColorManager.blueprime,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         SizedBox(height: AppSize.s8),
//                                         Row(
//                                           children: [
//                                             CircleAvatar(
//                                               child:
//                                               Image.asset('images/3.png'),
//                                             ),
//                                             SizedBox(width: AppSize.s7),
//                                             Text(
//                                               'Ross Geller',
//                                               style: GoogleFonts.firaSans(
//                                                 decoration: TextDecoration.none,
//                                                 fontWeight: FontWeightManager.medium,
//                                                 fontSize: AppSize.s12,
//                                                 color: ColorManager.darkblue,
//                                               ),
//                                             ),
//                                             SizedBox(
//                                                 width: MediaQuery.of(context).size.width / 20),
//                                             Spacer(),
//                                             Padding(
//                                               padding: const EdgeInsets.only(
//                                                   right: 20.0),
//                                               child: Text(
//                                                 '09',
//                                                 style: GoogleFonts.firaSans(
//                                                   decoration:
//                                                   TextDecoration.none,
//                                                   fontWeight: FontWeightManager.medium,
//                                                   fontSize: AppSize.s12,
//                                                   color: ColorManager.blueprime,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             ),
//
//                             ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//                             //2nd container
//
//                             SizedBox(
//                                 width: MediaQuery.of(context).size.width / 40),
//                             Container(
//                               height: 199.0,
//                               width: MediaQuery.of(context).size.width/5.5, //276
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(20.0),
//                                 color: ColorManager.white,
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: ColorManager.black.withOpacity(0.25),
//                                     spreadRadius: 2,
//                                     blurRadius: 10,
//                                     offset: Offset(0, 4),
//                                   ),
//                                 ],
//                               ),
//                               child: Column(
//                                 children: [
//                                   Container(
//                                     height: AppSize.s37,
//                                     decoration: BoxDecoration(
//                                       color: ColorManager.blueprime,
//                                       borderRadius: BorderRadius.only(
//                                         topLeft: Radius.circular(20.0),
//                                         topRight: Radius.circular(20.0),
//                                       ),
//                                     ),
//                                     child: Column(
//                                       children: [
//                                         Padding(
//                                           padding:
//                                           const EdgeInsets.only(top: 10.0),
//                                           child: Row(
//                                             mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                             children: [
//                                               Text(
//                                                 'Clinicians With Most Missed Visits',
//                                                 style: GoogleFonts.firaSans(
//                                                   decoration:
//                                                   TextDecoration.none,
//                                                   fontWeight: FontWeightManager.medium,
//                                                   fontSize: AppSize.s12,
//                                                   color: ColorManager.white,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   SizedBox(height: AppSize.s15),
//                                   Padding(
//                                     padding: const EdgeInsets.only(left: 20.0),
//                                     child: Column(
//                                       mainAxisAlignment:
//                                       MainAxisAlignment.start,
//                                       children: [
//                                         Row(
//                                           children: [
//                                             CircleAvatar(
//                                               child:
//                                               Image.asset('images/1.png'),
//                                             ),
//                                             SizedBox(width: AppSize.s7),
//                                             Text(
//                                               'James Smith',
//                                               style: GoogleFonts.firaSans(
//                                                 decoration: TextDecoration.none,
//                                                 fontWeight: FontWeightManager.medium,
//                                                 fontSize: AppSize.s12,
//                                                 color: ColorManager.darkblue,
//                                               ),
//                                             ),
//                                             // SizedBox(width: MediaQuery.of(context).size.width/20),
//                                             Spacer(),
//                                             Padding(
//                                               padding: const EdgeInsets.only(
//                                                   right: 20.0),
//                                               child: Text(
//                                                 '14',
//                                                 style: GoogleFonts.firaSans(
//                                                   decoration:
//                                                   TextDecoration.none,
//                                                   fontWeight: FontWeightManager.medium,
//                                                   fontSize: AppSize.s12,
//                                                   color: ColorManager.blueprime,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         SizedBox(height: AppSize.s8),
//                                         Row(
//                                           children: [
//                                             CircleAvatar(
//                                               child:
//                                               Image.asset('images/2.png'),
//                                             ),
//                                             SizedBox(width: AppSize.s7),
//                                             Text(
//                                               'John Scott',
//                                               style: GoogleFonts.firaSans(
//                                                 decoration: TextDecoration.none,
//                                                 fontWeight: FontWeightManager.medium,
//                                                 fontSize: AppSize.s12,
//                                                 color: ColorManager.darkblue,
//                                               ),
//                                             ),
//                                             // SizedBox(width: MediaQuery.of(context).size.width/20),
//                                             Spacer(),
//                                             Padding(
//                                               padding: const EdgeInsets.only(
//                                                   right: 20.0),
//                                               child: Text(
//                                                 '22',
//                                                 style: GoogleFonts.firaSans(
//                                                   decoration:
//                                                   TextDecoration.none,
//                                                   fontWeight: FontWeightManager.medium,
//                                                   fontSize: AppSize.s12,
//                                                   color: ColorManager.blueprime,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         SizedBox(height: 8),
//                                         Row(
//                                           children: [
//                                             CircleAvatar(
//                                               child:
//                                               Image.asset('images/3.png'),
//                                             ),
//                                             SizedBox(width: 7),
//                                             Text(
//                                               'Ross Geller',
//                                               style: GoogleFonts.firaSans(
//                                                 decoration: TextDecoration.none,
//                                                 fontWeight: FontWeightManager.medium,
//                                                 fontSize: AppSize.s12,
//                                                 color: ColorManager.darkblue,
//                                               ),
//                                             ),
//                                             SizedBox(
//                                                 width: MediaQuery.of(context).size.width / 20),
//                                             Spacer(),
//                                             Padding(
//                                               padding: const EdgeInsets.only(
//                                                   right: 20.0),
//                                               child: Text(
//                                                 '09',
//                                                 style: GoogleFonts.firaSans(
//                                                   decoration:
//                                                   TextDecoration.none,
//                                                   fontWeight: FontWeight.w500,
//                                                   fontSize: AppSize.s12,
//                                                   color: ColorManager.blueprime,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//
//
//
//
// //////////////////////////////////////////////////////////
//                         //3rd container
//                         SizedBox(
//                             height: MediaQuery.of(context).size.height / 80), //50
//                         Row(
//                           children: [
//                             Container(
//                               height: AppSize.s221, //210
//                               width: MediaQuery.of(context).size.width/5.5, //276
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(20.0),
//                                 color: ColorManager.white,
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.25),
//                                     spreadRadius: 2,
//                                     blurRadius: 10,
//                                     offset: Offset(0, 4),
//                                   ),
//                                 ],
//                               ),
//                               child: SingleChildScrollView(
//                                 child: Column(
//                                   children: [
//                                     Container(
//                                       height: AppSize.s37,
//                                       decoration: BoxDecoration(
//                                         color: ColorManager.blueprime,
//                                         borderRadius: BorderRadius.only(
//                                           topLeft: Radius.circular(20.0),
//                                           topRight: Radius.circular(20.0),
//                                         ),
//                                       ),
//                                       child: Column(
//                                         children: [
//                                           Padding(
//                                             padding: const EdgeInsets.only(top: 10.0),
//                                             child: Row(
//                                               mainAxisAlignment: MainAxisAlignment.center,
//                                               children: [
//                                                 Text(
//                                                   'Clinicians With Highest Case Load',
//                                                   style: GoogleFonts.firaSans(
//                                                     decoration: TextDecoration.none,
//                                                     fontWeight: FontWeightManager.medium,
//                                                     fontSize: AppSize.s12,
//                                                     color: ColorManager.white,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.only(left: 20.0),
//                                       child: Column(
//                                         mainAxisAlignment: MainAxisAlignment.start,
//                                         children: [
//                                           Row(
//                                             mainAxisAlignment: MainAxisAlignment.end,
//                                             children: [
//                                               DropdownButton<String>(
//                                                 value: selectedValueThisMonthA,
//                                                 icon: Icon(Icons.keyboard_arrow_down, color: ColorManager.granitegray),
//                                                 underline: Container(
//                                                   height: 0,
//                                                   color: Colors.transparent,
//                                                 ),
//                                                 items: dropdownItemsThisMonthA.map<DropdownMenuItem<String>>((String value) {
//                                                   return DropdownMenuItem<String>(
//                                                     value: value,
//                                                     child: Text(
//                                                       value,
//                                                       style: GoogleFonts.firaSans(
//                                                         decoration: TextDecoration.none,
//                                                         fontSize: AppSize.s10,
//                                                         fontWeight: FontWeightManager.medium,
//                                                         color: ColorManager.granitegray,
//                                                       ),
//                                                     ),
//                                                   );
//                                                 }).toList(),
//                                                 onChanged: (String? newValue) {
//                                                   setState(() {
//                                                     selectedValueThisMonthA = newValue!;
//                                                   });
//                                                 },
//                                               ),
//                                             ],
//                                           ),
//                                           Row(
//                                             children: [
//                                               CircleAvatar(
//                                                 child: Image.asset('images/1.png'),
//                                               ),
//                                               SizedBox(width: AppSize.s7),
//                                               Column(
//                                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                                 children: [
//                                                   Text(
//                                                     'James Smith',
//                                                     style: GoogleFonts.firaSans(
//                                                       decoration: TextDecoration.none,
//                                                       fontWeight: FontWeightManager.medium,
//                                                       fontSize: AppSize.s12,
//                                                       color: ColorManager.darkblue,
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: AppSize.s4),
//                                                   Container(
//                                                     width: AppSize.s58,
//                                                     child: ClipRRect(
//                                                       borderRadius: BorderRadius.circular(4.0),
//                                                       child: LinearProgressIndicator(
//                                                         value: 0.55,
//                                                         backgroundColor: ColorManager.cream,
//                                                         valueColor: AlwaysStoppedAnimation<Color>(Color(0xff7B9DF4)),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               Spacer(),
//                                               Padding(
//                                                 padding: const EdgeInsets.only(right: 20.0),
//                                                 child: Text(
//                                                   '55%',
//                                                   style: GoogleFonts.firaSans(
//                                                     decoration: TextDecoration.none,
//                                                     fontWeight: FontWeightManager.medium,
//                                                     fontSize: 12.0, // Use a fixed size instead of AppSize.s12
//                                                     color: ColorManager.calandercolour,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           SizedBox(height: AppSize.s8),
//                                           Row(
//                                             children: [
//                                               CircleAvatar(
//                                                 child: Image.asset('images/5.png'),
//                                               ),
//                                               SizedBox(width: AppSize.s7),
//                                               Column(
//                                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                                 children: [
//                                                   Text(
//                                                     'John Scott',
//                                                     style: GoogleFonts.firaSans(
//                                                       decoration: TextDecoration.none,
//                                                       fontWeight: FontWeightManager.medium,
//                                                       fontSize: AppSize.s12,
//                                                       color: ColorManager.darkblue,
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: AppSize.s4),
//                                                   Container(
//                                                     width: AppSize.s58,
//                                                     child: ClipRRect(
//                                                       borderRadius: BorderRadius.circular(4.0),
//                                                       child: LinearProgressIndicator(
//                                                         value: 0.55,
//                                                         backgroundColor: ColorManager.cream,
//                                                         valueColor: AlwaysStoppedAnimation<Color>(Color(0xff7B9DF4)),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               Spacer(),
//                                               Padding(
//                                                 padding: const EdgeInsets.only(right: 20.0),
//                                                 child: Text(
//                                                   '55%',
//                                                   style: GoogleFonts.firaSans(
//                                                     decoration: TextDecoration.none,
//                                                     fontWeight: FontWeightManager.medium,
//                                                     fontSize: AppSize.s12,
//                                                     color: ColorManager.calandercolour,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           SizedBox(height: AppSize.s8),
//                                           Row(
//                                             children: [
//                                               CircleAvatar(
//                                                 child: Image.asset('images/6.png'),
//                                               ),
//                                               SizedBox(width: AppSize.s7),
//                                               Column(
//                                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                                 children: [
//                                                   Text(
//                                                     'Mary Irish',
//                                                     style: GoogleFonts.firaSans(
//                                                       decoration: TextDecoration.none,
//                                                       fontWeight: FontWeightManager.medium,
//                                                       fontSize: AppSize.s12,
//                                                       color: ColorManager.darkblue,
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 4),
//                                                   Container(
//                                                     width: AppSize.s70,
//                                                     child: ClipRRect(
//                                                       borderRadius: BorderRadius.circular(4.0),
//                                                       child: LinearProgressIndicator(
//                                                         value: 0.55,
//                                                         backgroundColor: ColorManager.cream,
//                                                         valueColor: AlwaysStoppedAnimation<Color>(Color(0xff7B9DF4)),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               Spacer(),
//                                               Padding(
//                                                 padding: const EdgeInsets.only(right: 20.0),
//                                                 child: Text(
//                                                   '55%',
//                                                   style: GoogleFonts.firaSans(
//                                                     decoration: TextDecoration.none,
//                                                     fontWeight: FontWeightManager.medium,
//                                                     fontSize: AppSize.s12,
//                                                     color: ColorManager.blueprime,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//
//                             //////////
//                             //4th container
//                             SizedBox(
//                                 width: MediaQuery.of(context).size.width / 40),
//                             Container(
//                               height: AppSize.s221, //210
//                               width: MediaQuery.of(context).size.width/5.5, //276
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(20.0),
//                                 color: ColorManager.white,
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: ColorManager.black.withOpacity(0.25),
//                                     spreadRadius: 2,
//                                     blurRadius: 10,
//                                     offset: Offset(0, 4),
//                                   ),
//                                 ],
//                               ),
//                               child: SingleChildScrollView(
//                                 child: Column(
//                                   children: [
//                                     Container(
//                                       height: AppSize.s37,
//                                       decoration: BoxDecoration(
//                                         color: ColorManager.blueprime,
//                                         borderRadius: BorderRadius.only(
//                                           topLeft: Radius.circular(20.0),
//                                           topRight: Radius.circular(20.0),
//                                         ),
//                                       ),
//                                       child: Column(
//                                         children: [
//                                           Padding(
//                                             padding:
//                                             const EdgeInsets.only(top: 10.0),
//                                             child: Row(
//                                               mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                               children: [
//                                                 Text(
//                                                   'Clinicians With Highest Visit Load',
//                                                   style: GoogleFonts.firaSans(
//                                                     decoration:
//                                                     TextDecoration.none,
//                                                     fontWeight: FontWeightManager.medium,
//                                                     fontSize: AppSize.s12,
//                                                     color: ColorManager.white,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.only(left: 20.0),
//                                       child: Column(
//                                         mainAxisAlignment:
//                                         MainAxisAlignment.start,
//                                         children: [
//                                           Row(
//                                             mainAxisAlignment:
//                                             MainAxisAlignment.end,
//                                             children: [
//                                               DropdownButton<String>(
//                                                 value: selectedValueThisMonthB,
//                                                 icon: Icon(Icons.keyboard_arrow_down,
//                                                     color: ColorManager.granitegray),
//                                                 underline: Container(
//                                                   height: AppSize.s0,
//                                                   color: Colors.transparent,
//                                                 ),
//                                                 items: dropdownItemsThisMonthB.map<DropdownMenuItem<String>>((String value) {
//                                                   return DropdownMenuItem<String>(
//                                                     value: value,
//                                                     child: Text(
//                                                       value,
//                                                       style: GoogleFonts.firaSans(
//                                                         decoration: TextDecoration.none,
//                                                         fontSize: AppSize.s10,
//                                                         fontWeight: FontWeightManager.medium,
//                                                         color: ColorManager.granitegray,
//                                                       ),
//                                                     ),
//                                                   );
//                                                 }).toList(),
//                                                 onChanged: (String? newValue) {
//                                                   setState(() {
//                                                     selectedValueThisMonthB = newValue!;
//                                                   });
//                                                 },
//                                               ),
//                                             ],
//                                           ),
//                                           Row(
//                                             children: [
//                                               CircleAvatar(
//                                                 child:
//                                                 Image.asset('images/1.png'),
//                                               ),
//                                               SizedBox(width: AppSize.s7),
//                                               Column(
//                                                 children: [
//                                                   FittedBox(
//                                                     fit: BoxFit.scaleDown,
//                                                     child: Text(
//                                                       'James Smith',
//                                                       style: GoogleFonts.firaSans(
//                                                         decoration:
//                                                         TextDecoration.none,
//                                                         fontWeight: FontWeightManager.medium,
//                                                         fontSize: AppSize.s12,
//                                                         color: ColorManager.darkblue,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: AppSize.s4),
//                                                   Container(
//                                                     width: AppSize.s58,
//                                                     child: ClipRRect(
//                                                       borderRadius:
//                                                       BorderRadius.circular(
//                                                           4.0),
//                                                       child:
//                                                       LinearProgressIndicator(
//                                                         value: 0.55,
//                                                         backgroundColor:
//                                                         ColorManager.cream,
//                                                         valueColor:
//                                                         AlwaysStoppedAnimation<
//                                                             Color>(
//                                                             Color(
//                                                                 0xff7B9DF4)),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               // SizedBox(width: MediaQuery.of(context).size.width/20),
//                                               Spacer(),
//                                               Padding(
//                                                 padding: const EdgeInsets.only(
//                                                     right: 20.0),
//                                                 child: Text(
//                                                   '55%',
//                                                   style: GoogleFonts.firaSans(
//                                                     decoration:
//                                                     TextDecoration.none,
//                                                     fontWeight: FontWeightManager.medium,
//                                                     fontSize: AppSize.s12,
//                                                     color: ColorManager.blueprime,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           SizedBox(height: AppSize.s8),
//                                           Row(
//                                             children: [
//                                               CircleAvatar(
//                                                 child:
//                                                 Image.asset('images/5.png'),
//                                               ),
//                                               SizedBox(width: AppSize.s7),
//                                               Column(
//                                                 children: [
//                                                   Text(
//                                                     'John Scott',
//                                                     style: GoogleFonts.firaSans(
//                                                       decoration:
//                                                       TextDecoration.none,
//                                                       fontWeight: FontWeightManager.medium,
//                                                       fontSize: AppSize.s12,
//                                                       color: ColorManager.darkblue,
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: AppSize.s4),
//                                                   Container(
//                                                     width: AppSize.s58,
//                                                     child: ClipRRect(
//                                                       borderRadius:
//                                                       BorderRadius.circular(
//                                                           4.0),
//                                                       child:
//                                                       LinearProgressIndicator(
//                                                         value: 0.55,
//                                                         backgroundColor:
//                                                         ColorManager.cream,
//                                                         valueColor:
//                                                         AlwaysStoppedAnimation<
//                                                             Color>(Color(0xff7B9DF4)),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//
//                                               // SizedBox(width: MediaQuery.of(context).size.width/20),
//                                               Spacer(),
//                                               Padding(
//                                                 padding: const EdgeInsets.only(
//                                                     right: 20.0),
//                                                 child: Text(
//                                                   '55%',
//                                                   style: GoogleFonts.firaSans(
//                                                     decoration:
//                                                     TextDecoration.none,
//                                                     fontWeight: FontWeightManager.medium,
//                                                     fontSize: AppSize.s12,
//                                                     color: ColorManager.blueprime,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           SizedBox(height: AppSize.s8),
//                                           Row(
//                                             children: [
//                                               CircleAvatar(
//                                                 child:
//                                                 Image.asset('images/6.png'),
//                                               ),
//                                               SizedBox(width: AppSize.s7),
//                                               Column(
//                                                 children: [
//                                                   Text(
//                                                     'Mary Irish',
//                                                     style: GoogleFonts.firaSans(
//                                                       decoration:
//                                                       TextDecoration.none,
//                                                       fontWeight: FontWeightManager.medium,
//                                                       fontSize: AppSize.s12,
//                                                       color: ColorManager.darkblue,
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 4),
//                                                   Container(
//                                                     width: AppSize.s70,
//                                                     child: ClipRRect(
//                                                       borderRadius:
//                                                       BorderRadius.circular(
//                                                           4.0),
//                                                       child:
//                                                       LinearProgressIndicator(
//                                                         value: 0.55,
//                                                         backgroundColor:
//                                                         ColorManager.cream,
//                                                         valueColor:
//                                                         AlwaysStoppedAnimation<
//                                                             Color>(Color(0xff7B9DF4)),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               SizedBox(
//                                                   width: MediaQuery.of(context).size.width / 20),
//                                               Spacer(),
//                                               Padding(
//                                                 padding: const EdgeInsets.only(
//                                                     right: 20.0),
//                                                 child: Text(
//                                                   '55%',
//                                                   style: GoogleFonts.firaSans(
//                                                     decoration:
//                                                     TextDecoration.none,
//                                                     fontWeight: FontWeightManager.medium,
//                                                     fontSize: AppSize.s12,
//                                                     color: ColorManager.blueprime,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// //////////////////////////////////////////////container constant //////////////////////////////////////
// class CustomContainer extends StatelessWidget {
//   final String imagePath;
//   final String numberText;
//   final String descriptionText;
//
//   const CustomContainer({
//     required this.imagePath,
//     required this.numberText,
//     required this.descriptionText,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         height: AppSize.s95,
//         // width: 280,
//         decoration: BoxDecoration(
//           color: ColorManager.blueprime.withOpacity(0.17),
//           borderRadius: BorderRadius.circular(47.0),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Image.asset(
//               imagePath,
//               height: 52,
//               width: 41,
//             ),
//             SizedBox(width: MediaQuery.of(context).size.width / 100),
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   numberText,
//                   style: GoogleFonts.firaSans(
//                     decoration: TextDecoration.none,
//                     color: ColorManager.granitegray,
//                     fontSize: FontSize.s16,
//                     fontWeight: FontWeightManager.semiBold,
//                   ),
//                 ),
//                 Text(
//                   descriptionText,
//                   style: GoogleFonts.firaSans(
//                     decoration: TextDecoration.none,
//                     color: ColorManager.granitegray,
//                     fontSize: FontSize.s16,
//                     fontWeight: FontWeightManager.semiBold,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
// ////