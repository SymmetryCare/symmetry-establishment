import 'package:flutter/material.dart';

/// Which Establishment section the module screen is showing.
///
/// Reconstructed from the call sites in `em_desktop_screen.dart` — the original
/// lived in the `prohealth` monolith and did not come across with the extracted
/// screens. The screen calls [selectModuleScreen] with the page index and
/// [selectModuleNameScreen] with the label to show in the header, and reads the
/// current label back through [pageNmaeValue] (spelling as upstream).
class EmMainProvider extends ChangeNotifier {
  int _pageIndex = 0;
  String _pageName = '';

  /// Index of the section currently shown.
  int get pageIndexValue => _pageIndex;

  /// Label of the section currently shown.
  String get pageNmaeValue => _pageName;

  /// Show the section at [pageIndex].
  void selectModuleScreen(int pageIndex) {
    _pageIndex = pageIndex;
    notifyListeners();
  }

  /// Set the header label for the section currently shown.
  void selectModuleNameScreen(String pageName) {
    _pageName = pageName;
    notifyListeners();
  }
}
