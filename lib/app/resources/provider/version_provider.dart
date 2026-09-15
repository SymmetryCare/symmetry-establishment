import 'package:flutter/material.dart';

import 'package:symmetry_establishment/data/api_data/version/version_model_data.dart';

class VersionProviderManager extends ChangeNotifier {
  String _versionText = '';
  String _refreshVersionText = '';
  String get versionText => _versionText;
  String get refreshVersionText => _refreshVersionText;

  Future<void> getVersionManager(
      BuildContext context, VersionData versionData) async {
    print("from here");
    _versionText = versionData.versionName;
    notifyListeners();
  }

  void refreshText(String text) {
    _refreshVersionText = text;
    notifyListeners();
  }
}
