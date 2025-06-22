import 'package:flutter/foundation.dart';
import 'package:filesize/filesize.dart';
import '../models/flutter_project.dart';
import '../services/scanner_service.dart';
import '../services/cleaner_service.dart';

enum ScanStatus { idle, scanning, completed, error }

enum CleanStatus { idle, dryRun, cleaning, completed, error }

class ProjectsProvider with ChangeNotifier {
  final ScannerService _scannerService;
  final CleanerService _cleanerService;

  List<FlutterProject> _projects = [];
  String? _selectedDirectory;
  ScanStatus _scanStatus = ScanStatus.idle;
  CleanStatus _cleanStatus = CleanStatus.idle;
  String? _error;
  double _progress = 0.0;
  Map<FlutterProject, List<CleanableItem>>? _dryRunResult;
  Map<FlutterProject, List<CleanableItem>>? _cleanResult;
  bool _createBackup = false;

  // Default constructor
  ProjectsProvider()
    : _scannerService = ScannerService(),
      _cleanerService = CleanerService();

  // Constructor for testing
  ProjectsProvider.withServices({
    required ScannerService scannerService,
    required CleanerService cleanerService,
  }) : _scannerService = scannerService,
       _cleanerService = cleanerService;

  // Getters
  List<FlutterProject> get projects => _projects;
  String? get selectedDirectory => _selectedDirectory;
  ScanStatus get scanStatus => _scanStatus;
  CleanStatus get cleanStatus => _cleanStatus;
  String? get error => _error;
  double get progress => _progress;
  Map<FlutterProject, List<CleanableItem>>? get dryRunResult => _dryRunResult;
  Map<FlutterProject, List<CleanableItem>>? get cleanResult => _cleanResult;
  bool get createBackup => _createBackup;

  // Calculate total cleanable size
  String get totalCleanableSize {
    final totalBytes = _projects
        .where((project) => project.selected)
        .fold(
          0,
          (sum, project) =>
              sum +
              project.cleanableItems
                  .where((item) => item.selected)
                  .fold(0, (itemSum, item) => itemSum + item.size),
        );

    return filesize(totalBytes);
  }

  // Set selected directory and scan for Flutter projects
  Future<void> scanDirectory(String directoryPath) async {
    _selectedDirectory = directoryPath;
    _scanStatus = ScanStatus.scanning;
    _error = null;
    _progress = 0.0;
    notifyListeners();

    try {
      _projects = await _scannerService.scanDirectory(directoryPath);
      _scanStatus = ScanStatus.completed;
    } catch (e) {
      _error = e.toString();
      _scanStatus = ScanStatus.error;
    }

    notifyListeners();
  }

  // Toggle project selection
  void toggleProjectSelection(FlutterProject project, bool selected) {
    final index = _projects.indexWhere((p) => p.path == project.path);
    if (index != -1) {
      _projects[index].selected = selected;
      notifyListeners();
    }
  }

  // Toggle cleanable item selection
  void toggleCleanableItemSelection(
    FlutterProject project,
    CleanableItem item,
    bool selected,
  ) {
    final projectIndex = _projects.indexWhere((p) => p.path == project.path);
    if (projectIndex != -1) {
      final itemIndex = _projects[projectIndex].cleanableItems.indexWhere(
        (i) => i.path == item.path,
      );
      if (itemIndex != -1) {
        _projects[projectIndex].cleanableItems[itemIndex].selected = selected;
        notifyListeners();
      }
    }
  }

  // Toggle backup creation
  void toggleBackup(bool value) {
    _createBackup = value;
    notifyListeners();
  }

  // Perform dry run
  Future<void> performDryRun() async {
    _cleanStatus = CleanStatus.dryRun;
    _error = null;
    _progress = 0.0;
    notifyListeners();

    try {
      _dryRunResult = await _cleanerService.dryRun(_projects);
      _cleanStatus = CleanStatus.completed;
    } catch (e) {
      _error = e.toString();
      _cleanStatus = CleanStatus.error;
    }

    notifyListeners();
  }

  // Clean projects
  Future<void> cleanProjects() async {
    _cleanStatus = CleanStatus.cleaning;
    _error = null;
    _progress = 0.0;
    notifyListeners();

    try {
      _cleanResult = await _cleanerService.cleanProjects(
        _projects,
        createBackup: _createBackup,
        onProgress: (progress) {
          _progress = progress;
          notifyListeners();
        },
      );
      _cleanStatus = CleanStatus.completed;

      // Rescan directory to update project sizes
      if (_selectedDirectory != null) {
        await scanDirectory(_selectedDirectory!);
      }
    } catch (e) {
      _error = e.toString();
      _cleanStatus = CleanStatus.error;
    }

    notifyListeners();
  }

  // Reset state
  void reset() {
    _projects = [];
    _selectedDirectory = null;
    _scanStatus = ScanStatus.idle;
    _cleanStatus = CleanStatus.idle;
    _error = null;
    _progress = 0.0;
    _dryRunResult = null;
    _cleanResult = null;
    _createBackup = false;
    notifyListeners();
  }
}
