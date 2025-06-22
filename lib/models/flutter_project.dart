import 'dart:io';
import 'package:path/path.dart' as p;

class CleanableItem {
  final String name;
  final String path;
  bool selected;
  int size; // Size in bytes

  CleanableItem({
    required this.name,
    required this.path,
    this.selected = true,
    this.size = 0,
  });
}

class FlutterProject {
  final String name;
  final String path;
  final List<CleanableItem> cleanableItems;
  bool selected;
  int totalSize; // Total size of all cleanable items

  FlutterProject({
    required this.name,
    required this.path,
    required this.cleanableItems,
    this.selected = true,
    this.totalSize = 0,
  });

  /// Creates a Flutter project from a directory path
  static Future<FlutterProject?> fromDirectory(String directoryPath) async {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) return null;

    // Check if this is a Flutter project by looking for pubspec.yaml
    final pubspecFile = File(p.join(directoryPath, 'pubspec.yaml'));
    if (!await pubspecFile.exists()) return null;

    final projectName = p.basename(directoryPath);

    // Define cleanable directories
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

    // Define cleanable files
    final cleanableFiles = [
      '.packages',
      '.flutter-plugins',
      '.flutter-plugins-dependencies',
    ];

    List<CleanableItem> cleanableItems = [];

    // Add directories
    for (final dir in cleanableDirs) {
      final dirPath = p.join(directoryPath, dir);
      final dirExists = await Directory(dirPath).exists();
      if (dirExists) {
        final size = await _calculateDirectorySize(dirPath);
        cleanableItems.add(CleanableItem(name: dir, path: dirPath, size: size));
      }
    }

    // Add files
    for (final file in cleanableFiles) {
      final filePath = p.join(directoryPath, file);
      final fileExists = await File(filePath).exists();
      if (fileExists) {
        final size = await File(filePath).length();
        cleanableItems.add(
          CleanableItem(name: file, path: filePath, size: size),
        );
      }
    }

    // Calculate total size
    int totalSize = cleanableItems.fold(0, (sum, item) => sum + item.size);

    return FlutterProject(
      name: projectName,
      path: directoryPath,
      cleanableItems: cleanableItems,
      totalSize: totalSize,
    );
  }

  /// Calculate the size of a directory recursively
  static Future<int> _calculateDirectorySize(String dirPath) async {
    int totalSize = 0;
    try {
      final dir = Directory(dirPath);
      if (await dir.exists()) {
        await for (final entity in dir.list(
          recursive: true,
          followLinks: false,
        )) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }
    } catch (e) {
      // Handle permission errors or other issues
      print('Error calculating size for $dirPath: $e');
    }
    return totalSize;
  }
}
