class AppConstants {
  // App info
  static const String appName = 'Flutter Space Saver';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'A GUI-based, cross-platform desktop app to scan, analyze, and clean Flutter projects';

  // Cleanable directories and files
  final cleanableDirs = [
    'build',
    '.dart_tool',
    '.idea',
    '.vscode',
    '.gradle',
    'ios/Pods',
    'ios/.symlinks',
    'android/.gradle',
    'ephemeral',
    '.flutter-plugins',
    '.flutter-plugins-dependencies',
    '.flutter-versions',
    '.metadata',
    '.packages',
  ];

  static const List<String> cleanableFiles = [
    '.packages',
    '.flutter-plugins',
    '.flutter-plugins-dependencies',
  ];

  // UI constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Window size
  static const double defaultWindowWidth = 900.0;
  static const double defaultWindowHeight = 700.0;
  static const double minWindowWidth = 800.0;
  static const double minWindowHeight = 600.0;
}
