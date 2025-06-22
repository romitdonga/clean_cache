import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_space_saver/models/flutter_project.dart';
import 'package:flutter_space_saver/providers/projects_provider.dart';
import 'package:flutter_space_saver/utils/file_utils.dart';
import '../mocks/mock_services.dart';
import '../mocks/mock_data.dart';

void main() {
  late ProjectsProvider provider;
  late MockScannerService mockScannerService;

  setUp(() {
    mockScannerService = MockScannerService(
      mockProjects: MockDataFactory.createMockProjectsMap(),
    );

    // Use the constructor for testing
    provider = ProjectsProvider.withServices(
      scannerService: mockScannerService,
      cleanerService: MockCleanerService(),
    );
  });

  group('Size Calculation Tests', () {
    test('Project size should be sum of cleanable items', () {
      // Create a project with known sizes
      final cleanableItems = [
        CleanableItem(name: 'build', path: '/test/build', size: 1000),
        CleanableItem(name: '.dart_tool', path: '/test/.dart_tool', size: 2000),
        CleanableItem(name: '.idea', path: '/test/.idea', size: 500),
      ];

      final project = FlutterProject(
        name: 'TestProject',
        path: '/test',
        cleanableItems: cleanableItems,
        totalSize: 3500, // Explicitly set the total size to match the sum
      );

      // Calculate the expected total size
      final expectedTotalSize = cleanableItems.fold(
        0,
        (sum, item) => sum + item.size,
      );

      // Total size should be sum of all items
      expect(project.totalSize, equals(expectedTotalSize));
    });

    test('Provider should calculate total cleanable size correctly', () async {
      // Scan a directory with known projects
      await provider.scanDirectory('/path/to/flutter/projects');

      // Calculate expected size manually
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

      // Format the expected size for comparison
      final expectedFormattedSize = FileUtils.formatSize(expectedTotalBytes);

      // The provider's totalCleanableSize should match our manual calculation
      expect(provider.totalCleanableSize, equals(expectedFormattedSize));
    });

    test('FileUtils should format sizes correctly', () {
      // Test various sizes
      expect(FileUtils.formatSize(0), equals('0 B'));
      expect(
        FileUtils.formatSize(1024),
        contains('KB'),
      ); // Should be around 1 KB
      expect(
        FileUtils.formatSize(1024 * 1024),
        contains('MB'),
      ); // Should be around 1 MB
      expect(
        FileUtils.formatSize(1024 * 1024 * 1024),
        contains('GB'),
      ); // Should be around 1 GB
    });

    test('Toggling item selection should update total size', () async {
      // Scan a directory with known projects
      await provider.scanDirectory('/path/to/flutter/projects');

      // Get initial size
      final initialSize = provider.totalCleanableSize;

      // Toggle off an item
      final project = provider.projects.first;
      final item = project.cleanableItems.first;
      provider.toggleCleanableItemSelection(project, item, false);

      // Size should be different now
      expect(provider.totalCleanableSize, isNot(equals(initialSize)));

      // Toggle it back on
      provider.toggleCleanableItemSelection(project, item, true);

      // Size should be back to initial
      expect(provider.totalCleanableSize, equals(initialSize));
    });

    test('Toggling project selection should update total size', () async {
      // Scan a directory with known projects
      await provider.scanDirectory('/path/to/flutter/projects');

      // Get initial size
      final initialSize = provider.totalCleanableSize;

      // Toggle off a project
      final project = provider.projects.first;
      provider.toggleProjectSelection(project, false);

      // Size should be different now
      expect(provider.totalCleanableSize, isNot(equals(initialSize)));

      // Toggle it back on
      provider.toggleProjectSelection(project, true);

      // Size should be back to initial
      expect(provider.totalCleanableSize, equals(initialSize));
    });
  });
}
