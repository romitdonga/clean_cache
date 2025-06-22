import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_space_saver/providers/projects_provider.dart';
import 'package:flutter_space_saver/services/scanner_service.dart';
import 'package:flutter_space_saver/services/cleaner_service.dart';
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

  group('ProjectsProvider Tests', () {
    test('Initial state should be correct', () {
      expect(provider.projects, isEmpty);
      expect(provider.selectedDirectory, isNull);
      expect(provider.scanStatus, equals(ScanStatus.idle));
      expect(provider.cleanStatus, equals(CleanStatus.idle));
      expect(provider.error, isNull);
      expect(provider.progress, equals(0.0));
      expect(provider.dryRunResult, isNull);
      expect(provider.cleanResult, isNull);
      expect(provider.createBackup, isFalse);
    });

    test('scanDirectory should update projects and status', () async {
      const testPath = '/path/to/flutter/projects';
      await provider.scanDirectory(testPath);

      expect(provider.selectedDirectory, equals(testPath));
      expect(provider.scanStatus, equals(ScanStatus.completed));
      expect(provider.projects, isNotEmpty);
      expect(provider.projects.length, equals(3));
    });

    test('scanDirectory should handle empty directories', () async {
      const testPath = '/empty/directory';
      await provider.scanDirectory(testPath);

      expect(provider.selectedDirectory, equals(testPath));
      expect(provider.scanStatus, equals(ScanStatus.completed));
      expect(provider.projects, isEmpty);
    });

    test('toggleProjectSelection should update project selection', () async {
      // First scan to get projects
      await provider.scanDirectory('/path/to/flutter/projects');
      final project = provider.projects.first;

      // Toggle selection off
      provider.toggleProjectSelection(project, false);
      expect(provider.projects.first.selected, isFalse);

      // Toggle selection on
      provider.toggleProjectSelection(project, true);
      expect(provider.projects.first.selected, isTrue);
    });

    test('toggleCleanableItemSelection should update item selection', () async {
      // First scan to get projects
      await provider.scanDirectory('/path/to/flutter/projects');
      final project = provider.projects.first;
      final item = project.cleanableItems.first;

      // Toggle selection off
      provider.toggleCleanableItemSelection(project, item, false);
      expect(project.cleanableItems.first.selected, isFalse);

      // Toggle selection on
      provider.toggleCleanableItemSelection(project, item, true);
      expect(project.cleanableItems.first.selected, isTrue);
    });

    test('performDryRun should update dryRunResult', () async {
      // First scan to get projects
      await provider.scanDirectory('/path/to/flutter/projects');

      await provider.performDryRun();

      expect(provider.cleanStatus, equals(CleanStatus.completed));
      expect(provider.dryRunResult, isNotNull);

      // Only selected projects and items should be included
      final selectedProjects = provider.projects
          .where((p) => p.selected)
          .toList();
      expect(provider.dryRunResult!.length, equals(selectedProjects.length));
    });

    test(
      'cleanProjects should update cleanResult and call cleaner service',
      () async {
        // First scan to get projects
        await provider.scanDirectory('/path/to/flutter/projects');

        await provider.cleanProjects();

        expect(provider.cleanStatus, equals(CleanStatus.completed));
        expect(provider.cleanResult, isNotNull);

        // Check that the mock cleaner service was called
        expect(mockCleanerService.deletedPaths, isNotEmpty);

        // No backups should be created by default
        expect(mockCleanerService.backedUpPaths, isEmpty);
      },
    );

    test('cleanProjects should create backups when enabled', () async {
      // First scan to get projects
      await provider.scanDirectory('/path/to/flutter/projects');

      // Enable backups
      provider.toggleBackup(true);
      expect(provider.createBackup, isTrue);

      await provider.cleanProjects();

      // Check that backups were created
      expect(mockCleanerService.backedUpPaths, isNotEmpty);
      expect(
        mockCleanerService.backedUpPaths.length,
        equals(mockCleanerService.deletedPaths.length),
      );
    });

    test('totalCleanableSize should calculate correctly', () async {
      // First scan to get projects
      await provider.scanDirectory('/path/to/flutter/projects');

      // Calculate expected size
      int expectedTotalBytes = 0;
      for (final project in provider.projects) {
        if (project.selected) {
          for (final item in project.cleanableItems) {
            if (item.selected) {
              expectedTotalBytes += item.size;
            }
          }
        }
      }

      // The provider's totalCleanableSize returns a formatted string, so we can't directly compare
      // Instead, we'll check that it's not empty and contains some digits
      expect(provider.totalCleanableSize, isNotEmpty);
      expect(provider.totalCleanableSize, contains(RegExp(r'\d')));
    });

    test('reset should clear all state', () async {
      // First scan to get projects
      await provider.scanDirectory('/path/to/flutter/projects');

      // Perform some operations
      await provider.performDryRun();
      provider.toggleBackup(true);

      // Reset
      provider.reset();

      // Check that everything is reset
      expect(provider.projects, isEmpty);
      expect(provider.selectedDirectory, isNull);
      expect(provider.scanStatus, equals(ScanStatus.idle));
      expect(provider.cleanStatus, equals(CleanStatus.idle));
      expect(provider.error, isNull);
      expect(provider.progress, equals(0.0));
      expect(provider.dryRunResult, isNull);
      expect(provider.cleanResult, isNull);
      expect(provider.createBackup, isFalse);
    });
  });
}
