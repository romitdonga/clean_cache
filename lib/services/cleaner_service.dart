import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import '../models/flutter_project.dart';

class CleanerService {
  /// Performs a dry run of the cleaning process
  /// Returns a map of projects and their cleanable items
  Future<Map<FlutterProject, List<CleanableItem>>> dryRun(
    List<FlutterProject> projects,
  ) async {
    final Map<FlutterProject, List<CleanableItem>> result = {};

    for (final project in projects) {
      if (project.selected) {
        final cleanableItems = project.cleanableItems
            .where((item) => item.selected)
            .toList();
        result[project] = cleanableItems;
      }
    }

    return result;
  }

  /// Cleans the selected projects and their cleanable items
  /// Returns a map of projects and their cleaned items
  Future<Map<FlutterProject, List<CleanableItem>>> cleanProjects(
    List<FlutterProject> projects, {
    bool createBackup = false,
    Function(double progress)? onProgress,
  }) async {
    final Map<FlutterProject, List<CleanableItem>> result = {};
    int processedProjects = 0;

    for (final project in projects) {
      if (project.selected) {
        final cleanableItems = project.cleanableItems
            .where((item) => item.selected)
            .toList();

        if (cleanableItems.isNotEmpty) {
          // Create backup if needed
          if (createBackup) {
            await _createBackup(project, cleanableItems);
          }

          // Clean items
          final cleanedItems = await _cleanItems(cleanableItems);
          result[project] = cleanedItems;
        }
      }

      // Update progress
      processedProjects++;
      if (onProgress != null) {
        onProgress(processedProjects / projects.length);
      }
    }

    return result;
  }

  /// Creates a backup of the cleanable items
  Future<String?> _createBackup(
    FlutterProject project,
    List<CleanableItem> items,
  ) async {
    try {
      final backupDir = Directory(
        p.join(project.path, 'flutter_cleaner_backups'),
      );
      if (!await backupDir.exists()) {
        await backupDir.create();
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupPath = p.join(backupDir.path, 'backup_$timestamp.zip');
      final archive = Archive();

      for (final item in items) {
        final entity = FileSystemEntity.typeSync(item.path);

        if (entity == FileSystemEntityType.directory) {
          final dir = Directory(item.path);
          await for (final file in dir.list(
            recursive: true,
            followLinks: false,
          )) {
            if (file is File) {
              final relativePath = p.relative(file.path, from: project.path);
              final data = await file.readAsBytes();
              final archiveFile = ArchiveFile(relativePath, data.length, data);
              archive.addFile(archiveFile);
            }
          }
        } else if (entity == FileSystemEntityType.file) {
          final file = File(item.path);
          final relativePath = p.relative(file.path, from: project.path);
          final data = await file.readAsBytes();
          final archiveFile = ArchiveFile(relativePath, data.length, data);
          archive.addFile(archiveFile);
        }
      }

      // Write the zip file
      final zipData = ZipEncoder().encode(archive);
      if (zipData != null) {
        final zipFile = File(backupPath);
        await zipFile.writeAsBytes(zipData);
        return backupPath;
      }
    } catch (e) {
      print('Error creating backup: $e');
    }

    return null;
  }

  /// Cleans the specified items
  /// Returns a list of successfully cleaned items
  Future<List<CleanableItem>> _cleanItems(List<CleanableItem> items) async {
    final List<CleanableItem> cleanedItems = [];

    for (final item in items) {
      try {
        final entity = FileSystemEntity.typeSync(item.path);

        if (entity == FileSystemEntityType.directory) {
          final dir = Directory(item.path);
          if (await dir.exists()) {
            await dir.delete(recursive: true);
            cleanedItems.add(item);
          }
        } else if (entity == FileSystemEntityType.file) {
          final file = File(item.path);
          if (await file.exists()) {
            await file.delete();
            cleanedItems.add(item);
          }
        }
      } catch (e) {
        print('Error cleaning ${item.path}: $e');
      }
    }

    return cleanedItems;
  }
}
