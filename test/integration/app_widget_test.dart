import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_space_saver/screens/home_screen.dart';
import 'package:flutter_space_saver/providers/projects_provider.dart';
import '../mocks/mock_services.dart';
import '../mocks/mock_data.dart';

void main() {
  group('App Widget Integration Tests', () {
    testWidgets('Basic app workflow test', (WidgetTester tester) async {
      // Create mock services
      final mockScannerService = MockScannerService(
        mockProjects: MockDataFactory.createMockProjectsMap(),
      );
      final mockCleanerService = MockCleanerService();

      // Create a provider for testing
      final provider = ProjectsProvider.withServices(
        scannerService: mockScannerService,
        cleanerService: mockCleanerService,
      );

      // Build our app with mock services
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProjectsProvider>.value(
            value: provider,
            child: const HomeScreen(),
          ),
        ),
      );

      // Wait for the app to stabilize
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('Flutter Space Saver'), findsOneWidget);
      expect(
        find.text('Select a directory to scan for Flutter projects.'),
        findsOneWidget,
      );

      // Simulate selecting a directory
      await provider.scanDirectory('/path/to/flutter/projects');
      await tester.pumpAndSettle();

      // Verify projects are displayed
      expect(find.text('Found 3 Flutter projects'), findsOneWidget);

      // Verify backup option is initially false
      expect(provider.createBackup, isFalse);

      // Toggle backup option directly through the provider
      provider.toggleBackup(true);
      await tester.pumpAndSettle();

      // Verify backup option is toggled
      expect(provider.createBackup, isTrue);
    });

    testWidgets('Clean process test', (WidgetTester tester) async {
      // Create mock services
      final mockScannerService = MockScannerService(
        mockProjects: MockDataFactory.createMockProjectsMap(),
      );
      final mockCleanerService = MockCleanerService();

      // Create a provider for testing
      final provider = ProjectsProvider.withServices(
        scannerService: mockScannerService,
        cleanerService: mockCleanerService,
      );

      // Simulate selecting a directory
      await provider.scanDirectory('/path/to/flutter/projects');

      // Build our app with mock services and pre-loaded data
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProjectsProvider>.value(
            value: provider,
            child: const HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify projects are displayed
      expect(find.text('Found 3 Flutter projects'), findsOneWidget);

      // Perform dry run by calling the provider directly
      await provider.performDryRun();
      await tester.pumpAndSettle();

      // Verify the dry run result is stored
      expect(provider.dryRunResult, isNotNull);
      expect(provider.cleanStatus, equals(CleanStatus.completed));
    });
  });
}
