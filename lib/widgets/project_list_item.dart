import 'package:flutter/material.dart';
import '../models/flutter_project.dart';
import '../utils/file_utils.dart';
import '../constants/app_constants.dart';

class ProjectListItem extends StatelessWidget {
  final FlutterProject project;
  final Function(bool) onProjectSelectionChanged;
  final Function(CleanableItem, bool) onItemSelectionChanged;

  const ProjectListItem({
    super.key,
    required this.project,
    required this.onProjectSelectionChanged,
    required this.onItemSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: ExpansionTile(
        title: Row(
          children: [
            Checkbox(
              value: project.selected,
              onChanged: (value) {
                if (value != null) {
                  onProjectSelectionChanged(value);
                }
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    project.path,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              FileUtils.formatSize(project.totalSize),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        children: [
          if (project.cleanableItems.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppConstants.smallPadding),
              child: Text('No cleanable items found.'),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: AppConstants.smallPadding,
              ),
              child: Column(
                children: project.cleanableItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppConstants.smallPadding,
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: item.selected,
                          onChanged: project.selected
                              ? (value) {
                                  if (value != null) {
                                    onItemSelectionChanged(item, value);
                                  }
                                }
                              : null,
                        ),
                        Expanded(child: Text(item.name)),
                        Text(FileUtils.formatSize(item.size)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
