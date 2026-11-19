import 'dart:async';

import 'package:flutter/widgets.dart';

/// App-wide "server data changed" signal.
///
/// The [Api] client calls [DataRefresh.notifyChanged] after every successful
/// POST / PATCH / PUT / DELETE. List screens listen (via [AutoRefreshMixin])
/// and re-fetch once, instead of polling the API in a loop.
class DataRefresh {
  DataRefresh._();

  /// Incremented once per (debounced) batch of data changes.
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static Timer? _debounce;

  /// Several mutations in a row (e.g. upload file + save metadata) are
  /// coalesced into a single refresh.
  static void notifyChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      changes.value++;
    });
  }
}

/// Load-once / refresh-on-change behaviour for list screens.
///
/// Implement [refreshData] to fetch and push the data to the screen
/// (e.g. `controller.add(data)` or `setState`). It is called:
///  * once when the screen opens (after the first frame), and
///  * whenever data is changed anywhere in the app ([DataRefresh]).
///
/// Never call the API from inside `build` / a `builder:` callback — that
/// re-fetches on every rebuild and, with a StreamBuilder, loops forever.
mixin AutoRefreshMixin<T extends StatefulWidget> on State<T> {
  Future<void> refreshData();

  /// Set to false to skip the automatic first load (e.g. when the screen
  /// already loads in its own initState).
  bool get autoLoadOnOpen => true;

  void _onDataChanged() {
    if (mounted) refreshData();
  }

  @override
  void initState() {
    super.initState();
    DataRefresh.changes.addListener(_onDataChanged);
    if (autoLoadOnOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) refreshData();
      });
    }
  }

  @override
  void dispose() {
    DataRefresh.changes.removeListener(_onDataChanged);
    super.dispose();
  }
}
