import 'dart:io';
import 'package:path/path.dart' as p;
import '../models/flutter_project.dart';

class ScannerService {
  /// Scans a directory for Flutter projects
  /// Returns a list of Flutter projects found
  Future<List<FlutterProject>> scanDirectory(
    String directoryPath, {
    bool recursive = true,
  }) async {
    final List<FlutterProject> projects = [];
    final directory = Directory(directoryPath);

    if (!await directory.exists()) {
      throw Exception('Directory does not exist: $directoryPath');
    }

    try {
      if (await _isFlutterProject(directoryPath)) {
        final project = await FlutterProject.fromDirectory(directoryPath);
        if (project != null) {
          projects.add(project);
        }
      } else if (recursive) {
        // If not a Flutter project and recursive is true, scan subdirectories
        await for (final entity in directory.list(followLinks: false)) {
          if (entity is Directory) {
            final subProjects = await scanDirectory(
              entity.path,
              recursive: false,
            );
            projects.addAll(subProjects);
          }
        }
      }
    } catch (e) {
      print('Error scanning directory $directoryPath: $e');
    }

    return projects;
  }

  /// Checks if a directory is a Flutter project
  /// A Flutter project has a pubspec.yaml file
  Future<bool> _isFlutterProject(String directoryPath) async {
    final pubspecFile = File(p.join(directoryPath, 'pubspec.yaml'));
    return await pubspecFile.exists();
  }

  /// Calculates the total size of cleanable items in a list of projects
  int calculateTotalCleanableSize(List<FlutterProject> projects) {
    return projects.fold(0, (sum, project) => sum + project.totalSize);
  }
}
