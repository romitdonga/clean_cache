// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_space_saver/main.dart';
import 'package:flutter_space_saver/providers/projects_provider.dart';
import 'package:flutter_space_saver/screens/home_screen.dart';
import 'package:flutter_space_saver/constants/app_constants.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MyApp());

    // Verify that the app title is displayed
    expect(find.text(AppConstants.appName), findsOneWidget);

    // Verify that the initial state shows the directory selection prompt
    expect(
      find.text('Select a directory to scan for Flutter projects.'),
      findsOneWidget,
    );

    // Verify that the Browse button is present
    expect(find.text('Browse'), findsOneWidget);
  });

  testWidgets('HomeScreen UI elements test', (WidgetTester tester) async {
    // Create a test provider
    final provider = ProjectsProvider();

    // Build the HomeScreen with the test provider
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<ProjectsProvider>.value(
          value: provider,
          child: const HomeScreen(),
        ),
      ),
    );

    // Check for directory selector
    expect(find.text('Select Directory'), findsOneWidget);
    expect(find.text('No directory selected'), findsOneWidget);

    // Check for action buttons
    expect(find.text('Preview Cleanup'), findsOneWidget);
    expect(find.text('Clean Now'), findsOneWidget);

    // Check for backup checkbox
    expect(find.text('Create backup before cleaning'), findsOneWidget);

    // Buttons should be disabled initially
    final previewButtonFinder = find.widgetWithText(
      ElevatedButton,
      'Preview Cleanup',
    );
    expect(previewButtonFinder, findsOneWidget);
    expect(tester.widget<ElevatedButton>(previewButtonFinder).enabled, isFalse);

    final cleanButtonFinder = find.widgetWithText(ElevatedButton, 'Clean Now');
    expect(cleanButtonFinder, findsOneWidget);
    expect(tester.widget<ElevatedButton>(cleanButtonFinder).enabled, isFalse);
  });
}
