import 'package:flutter/material.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/register_manager/main_register_manager.dart';

import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/register_manager/register_manager.dart';

class RegisterStatusToggleProvider extends ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  Future<void> toggleNotopenInactive({
    required BuildContext context,
    required int employeeId,
    required Future<void> Function() onRefresh,
  }) async {
    _setLoading(true);
    try {
      /// ✅ your existing API (already in your screen)
      await changeStatusUserPatch(context, employeeId);

      await onRefresh();
    } catch (e) {
      debugPrint('toggleNotopenInactive error: $e');
    } finally {
      _setLoading(false);
    }
  }
}
