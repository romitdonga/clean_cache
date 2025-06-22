import 'package:flutter_space_saver/models/flutter_project.dart';

class MockDataFactory {
  static FlutterProject createMockProject({
    required String name,
    required String path,
    bool selected = true,
    int totalSize = 0,
    List<CleanableItem>? cleanableItems,
  }) {
    final items =
        cleanableItems ??
        [
          CleanableItem(
            name: 'build',
            path: '$path/build',
            size: 100000000, // 100 MB
            selected: true,
          ),
          CleanableItem(
            name: '.dart_tool',
            path: '$path/.dart_tool',
            size: 50000000, // 50 MB
            selected: true,
          ),
          CleanableItem(
            name: '.idea',
            path: '$path/.idea',
            size: 5000000, // 5 MB
            selected: false,
          ),
          CleanableItem(
            name: '.vscode',
            path: '$path/.vscode',
            size: 1000000, // 1 MB
            selected: false,
          ),
          CleanableItem(
            name: '.packages',
            path: '$path/.packages',
            size: 500, // 500 bytes
            selected: true,
          ),
        ];

    final calculatedTotalSize = items.fold(0, (sum, item) => sum + item.size);

    return FlutterProject(
      name: name,
      path: path,
      cleanableItems: items,
      selected: selected,
      totalSize: totalSize > 0 ? totalSize : calculatedTotalSize,
    );
  }

  static List<FlutterProject> createMockProjects() {
    return [
      createMockProject(name: 'Project1', path: '/path/to/project1'),
      createMockProject(
        name: 'Project2',
        path: '/path/to/project2',
        selected: false,
      ),
      createMockProject(
        name: 'Project3',
        path: '/path/to/project3',
        cleanableItems: [
          CleanableItem(
            name: 'build',
            path: '/path/to/project3/build',
            size: 200000000, // 200 MB
            selected: true,
          ),
          CleanableItem(
            name: '.gradle',
            path: '/path/to/project3/.gradle',
            size: 30000000, // 30 MB
            selected: true,
          ),
        ],
      ),
    ];
  }

  static Map<String, List<FlutterProject>> createMockProjectsMap() {
    return {
      '/path/to/flutter/projects': createMockProjects(),
      '/empty/directory': [],
      '/path/with/single/project': [
        createMockProject(
          name: 'SingleProject',
          path: '/path/with/single/project/SingleProject',
        ),
      ],
    };
  }
}
