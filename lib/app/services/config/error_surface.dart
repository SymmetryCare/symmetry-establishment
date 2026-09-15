import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Turns a white screen into a readable error.
///
/// A build-time exception in a release web build renders nothing at all, which
/// is the least diagnosable failure there is. Enable this and the failing
/// subtree shows the exception and the top of its stack instead, and every
/// framework error is also printed to the browser console.
///
/// Off by default — production keeps Flutter's stock behaviour. Turn it on for
/// a diagnostic build:
///
/// ```
/// flutter build web --dart-define=DEBUG_ERRORS=true
/// ```
class ErrorSurface {
  ErrorSurface._();

  static const bool enabled =
      bool.fromEnvironment('DEBUG_ERRORS', defaultValue: false);

  static void install() {
    if (!enabled) return;

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('FLUTTER ERROR: ${details.exceptionAsString()}');
      debugPrint('LIBRARY: ${details.library}   CONTEXT: ${details.context}');
      debugPrint('${details.stack}');
    };

    // Errors thrown from async work that never reaches the widget tree land
    // here rather than in ErrorWidget - without this they are silent.
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      debugPrint('UNCAUGHT ASYNC ERROR: $error');
      debugPrint('$stack');
      return true;
    };

    ErrorWidget.builder = (FlutterErrorDetails details) {
      final String where = details.context?.toDescription() ?? '';
      final String stack = '${details.stack}'
          .split('\n')
          .take(12)
          .join('\n');
      return Material(
        color: const Color(0xFFFFF4F4),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('This screen failed to build',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB3261E))),
              const SizedBox(height: 12),
              SelectableText(details.exceptionAsString(),
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF442726), height: 1.4)),
              if (where.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                SelectableText('while $where',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B4F4E))),
              ],
              const SizedBox(height: 14),
              SelectableText(stack,
                  style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Color(0xFF6B4F4E),
                      height: 1.35)),
            ],
          ),
        ),
      );
    };
  }
}
