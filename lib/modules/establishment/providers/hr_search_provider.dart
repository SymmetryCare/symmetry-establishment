import 'package:flutter/material.dart';

class HrSearchProviderManager extends ChangeNotifier{
  String _officeText = 'Select';
  String _avalableStatus = 'Select';
  String _zoneValue = 'Select';
  String _expTypeValue = 'Select';

  String get officeText => _officeText;
  String get avalableStatus => _avalableStatus;
  String get zoneValue => _zoneValue;
  String get expTypeValue => _expTypeValue;

  void officeTextChange({required String changeText}){
    _officeText = changeText;
    notifyListeners();
  }
  void zoneTextChange({required String changeText}){
    _zoneValue = changeText;
    notifyListeners();
  }
  void expTypeTextChange({required String changeText}){
    _expTypeValue = changeText;
    notifyListeners();
  }
  void avalableTextChange({required String changeText}){
    _avalableStatus = changeText;
    notifyListeners();
  }
  // void clearFilter(){
  //   avalableTextChange(changeText: 'Select');
  //   expTypeTextChange(changeText: 'Select');
  //   zoneTextChange(changeText: 'Select');
  //   officeTextChange(changeText: 'Select');
  //   // _officeText = 'Select';
  //   // _avalableStatus = 'Select';
  //   // _zoneValue = 'Select';
  //   // _expTypeValue = 'Select';
  //   notifyListeners();
  // }
  void clearFilter() {
    _avalableStatus = 'Select';
    _expTypeValue = 'Select';
    _zoneValue = 'Select';
    _officeText = 'Select';
    notifyListeners(); // Ensure UI updates
  }




}