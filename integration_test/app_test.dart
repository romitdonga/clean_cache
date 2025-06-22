import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_space_saver/main.dart';
import 'package:flutter_space_saver/providers/projects_provider.dart';
import 'package:flutter_space_saver/constants/app_constants.dart';
import '../test/mocks/mock_services.dart';
import '../test/mocks/mock_data.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end app tests', () {
    testWidgets('Full app workflow test', (WidgetTester tester) async {
      // Create mock services
      final mockScannerService = MockScannerService(
        mockProjects: MockDataFactory.createMockProjectsMap(),
      );
      final mockCleanerService = MockCleanerService();

      // Build our app with mock services
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProjectsProvider>(
            create: (context) => ProjectsProvider.withServices(
              scannerService: mockScannerService,
              cleanerService: mockCleanerService,
            ),
            child: const MyApp(),
          ),
        ),
      );

      // Wait for the app to stabilize
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text(AppConstants.appName), findsOneWidget);
      expect(
        find.text('Select a directory to scan for Flutter projects.'),
        findsOneWidget,
      );

      // Get the provider
      final ProjectsProvider provider = Provider.of<ProjectsProvider>(
        tester.element(find.byType(MaterialApp)),
        listen: false,
      );

      // Simulate selecting a directory
      await provider.scanDirectory('/path/to/flutter/projects');
      await tester.pumpAndSettle();

      // Verify projects are displayed
      expect(find.text('Found 3 Flutter projects'), findsOneWidget);

      // Check for project names
      expect(find.text('Project1'), findsOneWidget);
      expect(find.text('Project2'), findsOneWidget);
      expect(find.text('Project3'), findsOneWidget);

      // Expand a project to see its cleanable items
      await tester.tap(find.text('Project1'));
      await tester.pumpAndSettle();

      // Check for cleanable items
      expect(find.text('build'), findsOneWidget);
      expect(find.text('.dart_tool'), findsOneWidget);

      // Toggle a project selection
      final project2CheckboxFinder = find
          .descendant(
            of: find.widgetWithText(Card, 'Project2'),
            matching: find.byType(Checkbox),
          )
          .first;
      await tester.tap(project2CheckboxFinder);
      await tester.pumpAndSettle();

      // Toggle backup option
      final backupCheckboxFinder = find
          .descendant(
            of: find.text('Create backup before cleaning'),
            matching: find.byType(Checkbox),
          )
          .first;
      await tester.tap(backupCheckboxFinder);
      await tester.pumpAndSettle();

      // Perform dry run
      await tester.tap(find.text('Preview Cleanup'));
      await tester.pumpAndSettle();

      // Verify dry run dialog is shown
      expect(find.text('Cleanup Preview'), findsOneWidget);

      // Close the dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Perform cleanup
      await tester.tap(find.text('Clean Now'));
      await tester.pumpAndSettle();

      // Verify confirmation dialog is shown
      expect(find.text('Confirm Cleanup'), findsOneWidget);

      // Confirm cleanup
      await tester.tap(find.text('Clean'));
      await tester.pumpAndSettle();

      // Verify cleanup was performed
      expect(mockCleanerService.deletedPaths, isNotEmpty);
      expect(mockCleanerService.backedUpPaths, isNotEmpty);

      // Verify cleanup result dialog is shown
      expect(find.text('Cleanup Completed'), findsOneWidget);
    });
  });
}
