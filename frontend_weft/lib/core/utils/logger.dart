import 'dart:developer' as developer;

class Logger {
  static const String _tag = 'WEFT';

  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _tag,
      level: 500, // DEBUG level
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _tag,
      level: 800, // INFO level
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _tag,
      level: 900, // WARNING level
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _tag,
      level: 1000, // ERROR level
      error: error,
      stackTrace: stackTrace,
    );
  }
}
