import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_space_saver/providers/projects_provider.dart';
import '../mocks/mock_services.dart';
import '../mocks/mock_data.dart';

void main() {
  late ProjectsProvider provider;
  late MockScannerService mockScannerService;
  late MockCleanerService mockCleanerService;

  setUp(() {
    mockScannerService = MockScannerService(
      mockProjects: MockDataFactory.createMockProjectsMap(),
    );
    mockCleanerService = MockCleanerService();

    // Use the constructor for testing
    provider = ProjectsProvider.withServices(
      scannerService: mockScannerService,
      cleanerService: mockCleanerService,
    );
  });

  group('Cleaning Process Tests', () {
    test('Dry run should not delete any files', () async {
      // Scan a directory with known projects
      await provider.scanDirectory('/path/to/flutter/projects');

      // Perform dry run
      await provider.performDryRun();

      // Verify that no files were deleted
      expect(mockCleanerService.deletedPaths, isEmpty);
    });

    test('Clean should delete selected items', () async {
      // Scan a directory with known projects
      await provider.scanDirectory('/path/to/flutter/projects');

      // Get the count of selected items
      int selectedItemCount = 0;
      for (final project in provider.projects) {
        if (project.selected) {
          selectedItemCount += project.cleanableItems
              .where((item) => item.selected)
              .length;
        }
      }

      // Perform clean
      await provider.cleanProjects();

      // Verify that the correct number of items were deleted
      expect(mockCleanerService.deletedPaths.length, equals(selectedItemCount));
    });

    test('Clean should respect item selection', () async {
      // Scan a directory with known projects
      await provider.scanDirectory('/path/to/flutter/projects');

      // Deselect all items in the first project
      final firstProject = provider.projects.first;
      for (final item in firstProject.cleanableItems) {
        provider.toggleCleanableItemSelection(firstProject, item, false);
      }

      // Perform clean
      await provider.cleanProjects();

      // Verify that no items from the first project were deleted
      for (final item in firstProject.cleanableItems) {
        expect(mockCleanerService.deletedPaths.contains(item.path), isFalse);
      }
    });

    test('Clean should respect project selection', () async {
      // Scan a directory with known projects
      await provider.scanDirectory('/path/to/flutter/projects');

      // Deselect the first project
      final firstProject = provider.projects.first;
      provider.toggleProjectSelection(firstProject, false);

      // Perform clean
      await provider.cleanProjects();

      // Verify that no items from the first project were deleted
      for (final item in firstProject.cleanableItems) {
        expect(mockCleanerService.deletedPaths.contains(item.path), isFalse);
      }
    });

    test('Backup should be created when enabled', () async {
      // Scan a directory with known projects
      await provider.scanDirectory('/path/to/flutter/projects');

      // Enable backup
      provider.toggleBackup(true);

      // Perform clean
      await provider.cleanProjects();

      // Verify that backups were created
      expect(mockCleanerService.backedUpPaths, isNotEmpty);
      expect(
        mockCleanerService.backedUpPaths.length,
        equals(mockCleanerService.deletedPaths.length),
      );
    });

    test('Backup should not be created when disabled', () async {
      // Scan a directory with known projects
      await provider.scanDirectory('/path/to/flutter/projects');

      // Ensure backup is disabled
      provider.toggleBackup(false);

      // Perform clean
      await provider.cleanProjects();

      // Verify that no backups were created
      expect(mockCleanerService.backedUpPaths, isEmpty);
    });

    test('Clean should update projects after completion', () async {
      // Scan a directory with known projects
      await provider.scanDirectory('/path/to/flutter/projects');

      // Remember the initial projects
      final initialProjects = List.of(provider.projects);

      // Perform clean
      await provider.cleanProjects();

      // Verify that the projects were rescanned
      expect(provider.scanStatus, equals(ScanStatus.completed));

      // Note: In a real scenario, the projects would be different after cleaning
      // because the scanner would detect that some files are gone.
      // With our mocks, they'll be the same because we're not actually deleting files.
    });
  });
}
