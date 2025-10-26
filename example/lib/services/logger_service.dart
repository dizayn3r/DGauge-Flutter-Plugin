// lib/services/logger_service.dart
import 'package:logger/logger.dart';

/// Centralized logger service for the application
/// Uses the logger package for enhanced logging with colors, timestamps, and formatting
class LoggerService {
  static Logger? _logger;

  /// Get the logger instance (singleton pattern)
  static Logger get instance {
    _logger ??= Logger(
      printer: PrettyPrinter(
        methodCount: 2, // Number of method calls to be displayed
        errorMethodCount: 8, // Number of method calls if stacktrace is provided
        lineLength: 120, // Width of the output
        colors: true, // Colorful log messages
        printEmojis: true, // Print an emoji for each log message
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // Should each log print contain a timestamp
      ),
      level: Level.debug, // Set minimum log level (trace, debug, info, warning, error, fatal)
    );
    return _logger!;
  }

  /// Get a custom logger with specific configuration
  static Logger getCustomLogger({
    int methodCount = 2,
    int errorMethodCount = 8,
    int lineLength = 120,
    bool colors = true,
    bool printEmojis = true,
    bool printTime = true,
    Level level = Level.debug,
  }) {
    return Logger(
      printer: PrettyPrinter(
        methodCount: methodCount,
        errorMethodCount: errorMethodCount,
        lineLength: lineLength,
        colors: colors,
        printEmojis: printEmojis,
        printTime: printTime,
      ),
      level: level,
    );
  }

  /// Get a simple logger (no pretty printing, just messages)
  static Logger get simpleLogger {
    return Logger(
      printer: SimplePrinter(
        colors: true,
        printTime: true,
      ),
      level: Level.debug,
    );
  }

  /// Get a production logger (minimal output, no colors)
  static Logger get productionLogger {
    return Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 120,
        colors: false,
        printEmojis: false,
        printTime: true,
      ),
      level: Level.warning, // Only log warnings and above in production
    );
  }

  // ==========================================
  // Convenience methods for common logging
  // ==========================================

  /// Log a trace message (lowest level)
  static void trace(
      String message, {
        String? tag,
        dynamic error,
        StackTrace? stackTrace,
      }) {
    final msg = tag != null ? '[$tag] $message' : message;
    instance.t(msg, error: error, stackTrace: stackTrace);
  }

  /// Log a debug message
  static void debug(
      String message, {
        String? tag,
        dynamic error,
        StackTrace? stackTrace,
      }) {
    final msg = tag != null ? '[$tag] $message' : message;
    instance.d(msg, error: error, stackTrace: stackTrace);
  }

  /// Log an info message
  static void info(
      String message, {
        String? tag,
        dynamic error,
        StackTrace? stackTrace,
      }) {
    final msg = tag != null ? '[$tag] $message' : message;
    instance.i(msg, error: error, stackTrace: stackTrace);
  }

  /// Log a warning message
  static void warning(
      String message, {
        String? tag,
        dynamic error,
        StackTrace? stackTrace,
      }) {
    final msg = tag != null ? '[$tag] $message' : message;
    instance.w(msg, error: error, stackTrace: stackTrace);
  }

  /// Log an error message
  static void error(
      String message, {
        String? tag,
        dynamic error,
        StackTrace? stackTrace,
      }) {
    final msg = tag != null ? '[$tag] $message' : message;
    instance.e(msg, error: error, stackTrace: stackTrace);
  }

  /// Log a fatal message (highest level)
  static void fatal(
      String message, {
        String? tag,
        dynamic error,
        StackTrace? stackTrace,
      }) {
    final msg = tag != null ? '[$tag] $message' : message;
    instance.f(msg, error: error, stackTrace: stackTrace);
  }

  // ==========================================
  // Tagged logger for specific modules
  // ==========================================

  /// Create a tagged logger for specific file/class
  static TaggedLogger tagged(String tag) {
    return TaggedLogger(tag);
  }
}

/// Tagged logger for specific modules/files
class TaggedLogger {
  final String tag;
  final Logger _logger;

  TaggedLogger(this.tag) : _logger = LoggerService.instance;

  void trace(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.t('[$tag] $message', error: error, stackTrace: stackTrace);
  }

  void debug(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.d('[$tag] $message', error: error, stackTrace: stackTrace);
  }

  void info(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.i('[$tag] $message', error: error, stackTrace: stackTrace);
  }

  void warning(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.w('[$tag] $message', error: error, stackTrace: stackTrace);
  }

  void error(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e('[$tag] $message', error: error, stackTrace: stackTrace);
  }

  void fatal(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.f('[$tag] $message', error: error, stackTrace: stackTrace);
  }
}

// ==========================================
// Extension methods for easier usage
// ==========================================

extension LoggerExtension on Object {
  /// Get a logger tagged with the runtime type name
  TaggedLogger get logger => LoggerService.tagged(runtimeType.toString());
}