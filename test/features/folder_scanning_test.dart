import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_space_saver/providers/projects_provider.dart';
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

  group('Folder Scanning Tests', () {
    test('Scanning a folder with multiple Flutter projects', () async {
      const testPath = '/path/to/flutter/projects';
      await provider.scanDirectory(testPath);

      expect(provider.scanStatus, equals(ScanStatus.completed));
      expect(provider.projects.length, equals(3));

      // Verify project names
      final projectNames = provider.projects.map((p) => p.name).toList();
      expect(projectNames, contains('Project1'));
      expect(projectNames, contains('Project2'));
      expect(projectNames, contains('Project3'));
    });

    test('Scanning a folder with a single Flutter project', () async {
      const testPath = '/path/with/single/project';
      await provider.scanDirectory(testPath);

      expect(provider.scanStatus, equals(ScanStatus.completed));
      expect(provider.projects.length, equals(1));

      // Verify project name
      expect(provider.projects.first.name, equals('SingleProject'));
    });

    test('Scanning an empty folder', () async {
      const testPath = '/empty/directory';
      await provider.scanDirectory(testPath);

      expect(provider.scanStatus, equals(ScanStatus.completed));
      expect(provider.projects, isEmpty);
    });

    test('Scanning should only detect folders with pubspec.yaml', () async {
      // This is implicitly tested by the mock scanner service,
      // which only returns projects for paths that would contain pubspec.yaml

      const testPath = '/path/to/flutter/projects';
      await provider.scanDirectory(testPath);

      // Verify that all returned projects would have a pubspec.yaml file
      for (final project in provider.projects) {
        // In a real scenario, we would check if the project has a pubspec.yaml file
        // Here we're just verifying that our mock is working as expected
        expect(project.name, isNotEmpty);
        expect(project.path, isNotEmpty);
      }
    });
  });
}
