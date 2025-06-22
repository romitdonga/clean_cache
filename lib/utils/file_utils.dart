import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:filesize/filesize.dart';

class FileUtils {
  /// Formats a file size in bytes to a human-readable string
  static String formatSize(int bytes) {
    return filesize(bytes);
  }

  /// Gets the relative path from a base directory
  static String getRelativePath(String path, String from) {
    return p.relative(path, from: from);
  }

  /// Gets the file name from a path
  static String getFileName(String path) {
    return p.basename(path);
  }

  /// Gets the directory name from a path
  static String getDirName(String path) {
    return p.dirname(path);
  }

  /// Checks if a path exists
  static Future<bool> exists(String path) async {
    return await FileSystemEntity.isDirectory(path) ||
        await FileSystemEntity.isFile(path);
  }

  /// Gets the type of a file system entity
  static Future<FileSystemEntityType> getType(String path) async {
    return await FileSystemEntity.type(path);
  }
}
