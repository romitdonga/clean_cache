# Flutter Space Saver

A GUI-based, cross-platform desktop app to scan, analyze, and clean Flutter projects, freeing up disk space with minimal user effort.

## Features

- **Folder Scanner**: Recursively scans directories for Flutter projects
- **Space Estimator**: Calculates and displays the size of cleanable directories
- **Selective Cleaning**: Choose which projects and items to clean
- **Dry Run Mode**: Preview what would be deleted without making changes
- **Safety Mechanisms**: Confirmation prompts and optional backups
- **Cross-Platform**: Works on Windows, macOS, and Linux

## Cleanable Items

- `build/` (compiled outputs)
- `.dart_tool/` (Dart analysis and build cache)
- `.idea/` (IntelliJ/Android Studio configs)
- `.vscode/` (VS Code configs)
- `.gradle/` (Gradle cache for Android builds)
- Ephemeral files (e.g., `.packages`, `.flutter-plugins`)

## Getting Started

### Prerequisites

- Flutter SDK (with desktop support enabled)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/flutter_space_saver.git
   ```

2. Navigate to the project directory:
   ```bash
   cd flutter_space_saver
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run -d windows  # or macos, linux
   ```

## Building for Distribution

### Windows
```bash
flutter build windows
```

### macOS
```bash
flutter build macos
```

### Linux
```bash
flutter build linux
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
