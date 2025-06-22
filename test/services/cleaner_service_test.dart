import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_space_saver/services/cleaner_service.dart';
import 'package:flutter_space_saver/models/flutter_project.dart';
import '../mocks/mock_data.dart';

void main() {
  late CleanerService cleanerService;
  late List<FlutterProject> mockProjects;

  setUp(() {
    cleanerService = CleanerService();
    mockProjects = MockDataFactory.createMockProjects();
  });

  group('CleanerService Tests', () {
    test('dryRun should return map of selected projects and items', () async {
      final result = await cleanerService.dryRun(mockProjects);

      // Should include only selected projects
      expect(result.length, equals(2)); // Project1 and Project3 are selected

      // Check that the map contains the correct projects
      expect(result.keys.map((p) => p.name).contains('Project1'), isTrue);
      expect(result.keys.map((p) => p.name).contains('Project3'), isTrue);

      // Check that Project2 is not included (not selected)
      expect(result.keys.map((p) => p.name).contains('Project2'), isFalse);

      // Check that the map contains the correct items for each project
      for (final entry in result.entries) {
        final project = entry.key;
        final items = entry.value;

        // Only selected items should be included
        expect(items.every((item) => item.selected), isTrue);

        // The number of items should match the number of selected items in the project
        final expectedItemCount = project.cleanableItems
            .where((item) => item.selected)
            .length;
        expect(items.length, equals(expectedItemCount));
      }
    });

    test(
      'cleanProjects should call progress callback with correct values',
      () async {
        double? lastProgress;

        await cleanerService.cleanProjects(
          mockProjects,
          onProgress: (progress) {
            // Progress should be between 0 and 1
            expect(progress >= 0 && progress <= 1, isTrue);
            lastProgress = progress;
          },
        );

        // After completion, progress should be 1.0 (100%)
        expect(lastProgress, equals(1.0));
      },
    );
  });
}
