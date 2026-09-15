import 'dart:async';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/work_schedule_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/work_schedule/work_week_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/manage_work_schedule/work_schedule/widgets/add_batch_popup_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/delete_success_popup.dart';

class ViewBatchesPopup extends StatefulWidget {
  final String shiftName;
  final String weekName;

   ViewBatchesPopup({super.key, required this.shiftName, required this.weekName});

  @override
  State<ViewBatchesPopup> createState() => _ViewBatchesPopupState();
}

class _ViewBatchesPopupState extends State<ViewBatchesPopup> {
  int currentPage = 1;
  int itemsPerPage = 10;
  final StreamController<List<ShiftBachesData>>
  workWeekShiftBatchesController =
  StreamController<List<ShiftBachesData>>();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    shiftBatchesGet(context,widget.shiftName,widget.weekName).then((data) {
      workWeekShiftBatchesController.add(data);
    }).catchError((error) {
      // Handle error
    });
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: AppSize.s850,
        height: AppSize.s620,
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: ColorManager.bluebottom,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    height: AppSize.s40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppPadding.p8,horizontal: AppPadding.p25),
                          child: Text("Batches",style: TextStyle(
                            fontSize: FontSize.s16,
                            fontWeight: FontWeight.w700,
                            color: ColorManager.white,
                            decoration: TextDecoration.none,
                          ),),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon:  Icon(Icons.close,color: ColorManager.white,),
                          ),
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder<List<ShiftBachesData>>(
                      stream: workWeekShiftBatchesController.stream,
                      builder: (context, snapshot) {
                        shiftBatchesGet(context,widget.shiftName,widget.weekName).then((data) {
                          workWeekShiftBatchesController.add(data);
                        }).catchError((error) {
                          // Handle error
                        });
                        if(snapshot.connectionState == ConnectionState.waiting){
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 150),
                            child: Center(child:CircularProgressIndicator(color: ColorManager.blueprime,)),
                          );
                        }
                        if (snapshot.data!.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppPadding.p100),
                            child: Center(
                              child: Text(
                                "No available batches!",
                                style: DocumentTypeDataStyle.customTextStyle(context)
                              ),
                            ),
                          );
                        }

                        if(snapshot.hasData){
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppPadding.p10,
                              horizontal: AppPadding.p20,
                            ),
                            child: ScrollConfiguration(
                              behavior: ScrollBehavior().copyWith(scrollbars: false),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      height: AppSize.s30,
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: AppPadding.p15, right: AppPadding.p20),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  AppStringEM.srno,
                                                  style: TableHeading.customTextStyle(context)
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: Text(AddPopupString.startTime,         //AppStringEM.startTime,
                                                    textAlign: TextAlign.start,
                                                    style: TableHeading.customTextStyle(context)),
                                              ),
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: Text( AddPopupString.endTime,       //AppStringEM.endTime,
                                                    textAlign: TextAlign.start,
                                                    style: TableHeading.customTextStyle(context)),
                                              ),
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: Text( AppStringEM.actions,
                                                    textAlign: TextAlign.start,
                                                    style: TableHeading.customTextStyle(context)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: AppSize.s10,
                                    ),
                                    Container(
                                      height: MediaQuery.of(context).size.height/1.55,
                                      child:
                                      ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          itemCount: snapshot.data!.length,
                                          itemBuilder: (context, index) {
                                            int serialNumber =
                                                index + 1 + (currentPage - 1) * itemsPerPage;
                                            String formattedSerialNumber =
                                            serialNumber.toString().padLeft(2, '0');
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // SizedBox(height: 5),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 3),
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(4),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: const Color(0xff000000).withOpacity(0.25),
                                                            spreadRadius: 0,
                                                            blurRadius: 4,
                                                            offset: const Offset(0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      height: AppSize.s50,
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: AppPadding.p15),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.spaceAround,
                                                          children: [
                                                            Expanded(
                                                              child: Center(
                                                                child: Text(
                                                                  formattedSerialNumber,
                                                                  // formattedSerialNumber,
                                                                  style: AllHRTableData.customTextStyle(context),
                                                                ),
                                                              ),
                                                            ),
                                                            // Text(''),
                                                            Expanded(
                                                              child: Center(
                                                                child: Text(
                                                                  snapshot.data![index].officeStartTime,textAlign:TextAlign.center,
                                                                  style: AllHRTableData.customTextStyle(context),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Center(
                                                                child: Text(
                                                                  snapshot.data![index].officeEndTime,textAlign:TextAlign.center,
                                                                  style: AllHRTableData.customTextStyle(context),
                                                                ),
                                                              ),
                                                            ),
                                                            //  Text(''),
                                                            Expanded(
                                                              child: Center(
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    IconButton(onPressed: (){
                                                                      showDialog(
                                                                          context: context,
                                                                          builder: (BuildContext context) {
                                                                            return FutureBuilder<ShiftBachesData>(
                                                                              future: shiftPrefillBatchesGet(context, snapshot.data![index].shiftBatchScheduleId),
                                                                              builder: (context,snapshotPrefill) {
                                                                                if(snapshotPrefill.connectionState == ConnectionState.waiting){
                                                                                  return Center(child:CircularProgressIndicator(color: ColorManager.blueprime,));
                                                                                }
                                                                                var startTime = snapshotPrefill.data?.officeStartTime.toString();
                                                                                var endTime = snapshotPrefill.data?.officeEndTime.toString();
                                                                                startTimeController = TextEditingController(text: snapshotPrefill.data?.officeStartTime.toString());
                                                                                endTimeController = TextEditingController(text: snapshotPrefill.data?.officeEndTime.toString());
                                                                                return AddBatchPopup(
                                                                                  controller1: startTimeController,
                                                                                  controller2: endTimeController,
                                                                                  onPressed: () async{
                                                                                   var response =  await updateShiftBatch(context,
                                                                                        widget.shiftName,widget.weekName,
                                                                                        startTime == startTimeController.text ? startTime.toString() : startTimeController.text,
                                                                                        endTime == endTimeController.text ? endTime.toString() : endTimeController.text,
                                                                                        snapshot.data![index].shiftBatchScheduleId);
                                                                                    shiftBatchesGet(context,widget.shiftName,widget.weekName).then((data) {
                                                                                      workWeekShiftBatchesController.add(data);
                                                                                    }).catchError((error) {
                                                                                      // Handle error
                                                                                    });
                                                                                    startTimeController.clear();
                                                                                    endTimeController.clear();

                                                                                   if(response.statusCode == 200 || response.statusCode == 201){
                                                                                     Navigator.pop(context);
                                                                                     showDialog(
                                                                                       context: context,
                                                                                       builder: (BuildContext context) {
                                                                                         return AddSuccessPopup(
                                                                                           message: 'Batch Edited Successfully',
                                                                                         );
                                                                                       },
                                                                                     );
                                                                                   }else if(response.statusCode == 400 || response.statusCode == 404){
                                                                                     Navigator.pop(context);
                                                                                     showDialog(
                                                                                       context: context,
                                                                                       builder: (BuildContext context) => const FourNotFourPopup(),
                                                                                     );
                                                                                   }
                                                                                   else {
                                                                                     Navigator.pop(context);
                                                                                     showDialog(
                                                                                       context: context,
                                                                                       builder: (BuildContext context) => FailedPopup(text: response.message),
                                                                                     );
                                                                                   }
                                                                                  }, title: 'Edit Batch',
                                                                                );
                                                                              }
                                                                            );
                                                                          });
                                                                    }, icon: Icon(Icons.edit_outlined,size:18,color: ColorManager.blueprime,)),
                                                                    IconButton(onPressed: (){
                                                                      showDialog(
                                                                        context: context,
                                                                        builder: (context) =>
                                                                            StatefulBuilder(
                                                                              builder: (BuildContext context, void Function(void Function()) setState) {
                                                                                return DeletePopup(
                                                                                    title: "Delete Batch",
                                                                                    loadingDuration: _isLoading,
                                                                                    onCancel: () {
                                                                                      Navigator.pop(
                                                                                          context);
                                                                                    }, onDelete:
                                                                                    () async {
                                                                                  setState(() {
                                                                                    _isLoading = true;
                                                                                  });
                                                                                  try {
                                                                                    await deleteShiftBatch(context, snapshot.data![index].shiftBatchScheduleId);
                                                                                    Navigator.pop(context);
                                                                                    showDialog(context: context, builder: (context) => DeleteSuccessPopup());

                                                                                  } finally {
                                                                                    setState(() {
                                                                                      _isLoading = false;
                                                                                    });
                                                                                  }
                                                                                });
                                                                              },
                                                                            ),
                                                                      );
                                                                      // showDialog(
                                                                      //     context: context,
                                                                      //     builder: (context) =>
                                                                      //         DeletePopup(
                                                                      //             title: 'Delete Batch',
                                                                      //             onCancel: () {
                                                                      //               Navigator.pop(
                                                                      //                   context);
                                                                      //             }, onDelete:
                                                                      //             () async {
                                                                      //
                                                                      //               //
                                                                      //               Navigator.pop(context);
                                                                      //         }));
                                                                    }, icon: Icon(Icons.delete_outline,size:18,color: ColorManager.red,)),
                                                                  ],
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      )),
                                                ),
                                              ],
                                            );
                                          }),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        else{
                          return const SizedBox();
                        }
                    }
                  ),
                ],
              ),
      ),
    );
  }
}
