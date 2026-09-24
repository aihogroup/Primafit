import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

/// Single logging entry point. Replaces scattered `print` calls so logs are
/// structured, stripped of noise in release builds, and ready to be forwarded
/// to a crash reporter (Sentry) in a later sprint.
abstract final class AppLogger {
  static void debug(String message, {String tag = 'app'}) =>
      _log(LogLevel.debug, message, tag: tag);

  static void info(String message, {String tag = 'app'}) => _log(LogLevel.info, message, tag: tag);

  static void warning(String message, {String tag = 'app', Object? error}) =>
      _log(LogLevel.warning, message, tag: tag, error: error);

  static void error(String message, {String tag = 'app', Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);

  static void _log(
    LogLevel level,
    String message, {
    required String tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kReleaseMode && level.index < LogLevel.warning.index) return;
    developer.log(
      message,
      name: 'primafit.$tag',
      level: _severity(level),
      error: error,
      stackTrace: stackTrace,
    );
  }

  static int _severity(LogLevel level) => switch (level) {
    LogLevel.debug => 500,
    LogLevel.info => 800,
    LogLevel.warning => 900,
    LogLevel.error => 1000,
  };
}
