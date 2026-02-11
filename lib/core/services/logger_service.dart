import 'dart:developer' as developer;

class LoggerService {
  static const String _tag = 'QuizApp';

  static void info(String message, [String? tag]) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 800, // Info level
    );
  }

  static void warning(String message, [String? tag]) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 900, // Warning level
    );
  }

  static void error(
    String message, [
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  ]) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 1000, // Error level
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void debug(String message, [String? tag]) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 700, // Debug level
    );
  }
}
