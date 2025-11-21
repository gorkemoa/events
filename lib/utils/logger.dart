import 'dart:developer' as developer;

/// Centralized logging utility for the application
class Logger {
  static const String _defaultTag = 'Pixlomi';

  /// Log an info message
  static void info(String message, {String? tag}) {
    developer.log(
      'ℹ️ $message',
      name: tag ?? _defaultTag,
      level: 800,
    );
  }

  /// Log a debug message
  static void debug(String message, {String? tag}) {
    developer.log(
      '🔍 $message',
      name: tag ?? _defaultTag,
      level: 500,
    );
  }

  /// Log a warning message
  static void warning(String message, {String? tag}) {
    developer.log(
      '⚠️ $message',
      name: tag ?? _defaultTag,
      level: 900,
    );
  }

  /// Log an error message
  static void error(String message, {String? tag, StackTrace? stackTrace, Object? error}) {
    developer.log(
      '❌ $message',
      name: tag ?? _defaultTag,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log a success message
  static void success(String message, {String? tag}) {
    developer.log(
      '✅ $message',
      name: tag ?? _defaultTag,
      level: 800,
    );
  }
}
