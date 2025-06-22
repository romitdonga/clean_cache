import 'package:flutter_space_saver/models/flutter_project.dart';
import 'package:flutter_space_saver/services/scanner_service.dart';
import 'package:flutter_space_saver/services/cleaner_service.dart';

class MockScannerService extends ScannerService {
  final Map<String, List<FlutterProject>> mockProjects;

  MockScannerService({required this.mockProjects});

  @override
  Future<List<FlutterProject>> scanDirectory(
    String directoryPath, {
    bool recursive = true,
  }) async {
    // Return mock projects for the given directory
    return Future.value(mockProjects[directoryPath] ?? []);
  }
}

class MockCleanerService extends CleanerService {
  final List<String> deletedPaths = [];
  final List<String> backedUpPaths = [];

  @override
  Future<Map<FlutterProject, List<CleanableItem>>> cleanProjects(
    List<FlutterProject> projects, {
    bool createBackup = false,
    Function(double progress)? onProgress,
  }) async {
    final result = <FlutterProject, List<CleanableItem>>{};

    int processedProjects = 0;
    for (final project in projects) {
      if (project.selected) {
        final cleanableItems = project.cleanableItems
            .where((item) => item.selected)
            .toList();

        if (cleanableItems.isNotEmpty) {
          // Simulate backup
          if (createBackup) {
            for (final item in cleanableItems) {
              backedUpPaths.add(item.path);
            }
          }

          // Simulate cleaning
          for (final item in cleanableItems) {
            deletedPaths.add(item.path);
          }

          result[project] = cleanableItems;
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

  void reset() {
    deletedPaths.clear();
    backedUpPaths.clear();
  }
}
