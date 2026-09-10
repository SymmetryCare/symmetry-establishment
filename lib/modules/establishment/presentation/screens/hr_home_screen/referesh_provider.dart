import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageIndexProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  PageIndexProvider() {
    _loadIndex();
  }

  Future<void> _loadIndex() async {
    final prefs = await SharedPreferences.getInstance();
    _currentIndex = prefs.getInt('currentIndex') ?? 0;
    notifyListeners();
  }

  Future<void> setIndex(int index) async {
    _currentIndex = index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentIndex', index);
    notifyListeners();
  }
}
