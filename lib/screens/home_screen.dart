import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/projects_provider.dart';
import '../models/flutter_project.dart';
import '../widgets/project_list_item.dart';
import '../utils/file_utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings screen
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDirectorySelector(context),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildProjectList(context),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectorySelector(BuildContext context) {
    final provider = Provider.of<ProjectsProvider>(context);
    final selectedDirectory = provider.selectedDirectory;
    final scanStatus = provider.scanStatus;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Directory',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDirectory ?? 'No directory selected',
                    style: TextStyle(
                      color: selectedDirectory == null ? Colors.grey : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppConstants.smallPadding),
                ElevatedButton.icon(
                  onPressed: scanStatus == ScanStatus.scanning
                      ? null
                      : () => _selectDirectory(context),
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Browse'),
                ),
              ],
            ),
            if (scanStatus == ScanStatus.scanning)
              const Padding(
                padding: EdgeInsets.only(top: AppConstants.smallPadding),
                child: LinearProgressIndicator(),
              ),
            if (provider.error != null)
              Padding(
                padding: const EdgeInsets.only(top: AppConstants.smallPadding),
                child: Text(
                  provider.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectList(BuildContext context) {
    final provider = Provider.of<ProjectsProvider>(context);
    final projects = provider.projects;
    final scanStatus = provider.scanStatus;

    if (scanStatus == ScanStatus.scanning) {
      return const Expanded(
        child: Center(child: Text('Scanning for Flutter projects...')),
      );
    }

    if (scanStatus == ScanStatus.completed && projects.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text('No Flutter projects found in the selected directory.'),
        ),
      );
    }

    if (scanStatus == ScanStatus.idle) {
      return const Expanded(
        child: Center(
          child: Text('Select a directory to scan for Flutter projects.'),
        ),
      );
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  'Found ${projects.length} Flutter ${projects.length == 1 ? 'project' : 'projects'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: Text(
                  'Total cleanable size: ${provider.totalCleanableSize}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Expanded(
            child: ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                return ProjectListItem(
                  project: projects[index],
                  onProjectSelectionChanged: (selected) {
                    provider.toggleProjectSelection(projects[index], selected);
                  },
                  onItemSelectionChanged: (item, selected) {
                    provider.toggleCleanableItemSelection(
                      projects[index],
                      item,
                      selected,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final provider = Provider.of<ProjectsProvider>(context);
    final scanStatus = provider.scanStatus;
    final cleanStatus = provider.cleanStatus;
    final projects = provider.projects;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Checkbox(
                value: provider.createBackup,
                onChanged: (value) {
                  if (value != null) {
                    provider.toggleBackup(value);
                  }
                },
              ),
              const Flexible(child: Text('Create backup before cleaning')),
            ],
          ),
        ),
        Row(
          children: [
            ElevatedButton(
              onPressed:
                  scanStatus != ScanStatus.completed ||
                      projects.isEmpty ||
                      cleanStatus == CleanStatus.cleaning
                  ? null
                  : () => _performDryRun(context),
              child: const Text('Preview Cleanup'),
            ),
            const SizedBox(width: AppConstants.smallPadding),
            ElevatedButton(
              onPressed:
                  scanStatus != ScanStatus.completed ||
                      projects.isEmpty ||
                      cleanStatus == CleanStatus.cleaning
                  ? null
                  : () => _cleanProjects(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clean Now'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDirectory(BuildContext context) async {
    final provider = Provider.of<ProjectsProvider>(context, listen: false);

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      await provider.scanDirectory(selectedDirectory);
    }
  }

  void _performDryRun(BuildContext context) async {
    final provider = Provider.of<ProjectsProvider>(context, listen: false);
    await provider.performDryRun();

    if (provider.cleanStatus == CleanStatus.completed) {
      _showDryRunDialog(context);
    }
  }

  void _cleanProjects(BuildContext context) async {
    final provider = Provider.of<ProjectsProvider>(context, listen: false);

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Cleanup'),
        content: Text(
          'Are you sure you want to clean the selected projects? '
          'This will free up ${provider.totalCleanableSize} of space.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clean'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.cleanProjects();

      if (provider.cleanStatus == CleanStatus.completed) {
        _showCleanupResultDialog(context);
      }
    }
  }

  void _showDryRunDialog(BuildContext context) {
    final provider = Provider.of<ProjectsProvider>(context, listen: false);
    final dryRunResult = provider.dryRunResult;

    if (dryRunResult == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cleanup Preview'),
        content: SizedBox(
          width: 600,
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The following items will be cleaned, freeing up ${provider.totalCleanableSize} of space:',
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Expanded(
                child: ListView(
                  children: dryRunResult.entries.map((entry) {
                    final project = entry.key;
                    final items = entry.value;

                    return Card(
                      margin: const EdgeInsets.only(
                        bottom: AppConstants.smallPadding,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(
                          AppConstants.smallPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(),
                            ...items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppConstants.smallPadding / 2,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(item.name),
                                    Text(FileUtils.formatSize(item.size)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _cleanProjects(context);
            },
            child: const Text('Clean Now'),
          ),
        ],
      ),
    );
  }

  void _showCleanupResultDialog(BuildContext context) {
    final provider = Provider.of<ProjectsProvider>(context, listen: false);
    final cleanResult = provider.cleanResult;

    if (cleanResult == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cleanup Completed'),
        content: Text(
          'Successfully cleaned up ${provider.totalCleanableSize} of space.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
