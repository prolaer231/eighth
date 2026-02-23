import 'dart:async';
import 'dart:convert';
import 'package:archive/archive.dart';

import '../models/project.dart';
import '../models/file_item.dart';

enum BuildStatus {
  idle,
  loading,
  bundling,
  uploading,
  processing,
  success,
  error,
}

class BuildUpdate {
  final BuildStatus status;
  final String message;
  final double progress;
  final String? apkUrl;

  BuildUpdate({
    required this.status,
    required this.message,
    required this.progress,
    this.apkUrl,
  });
}

class ApkBuilderService {
  static final ApkBuilderService _instance = ApkBuilderService._internal();
  factory ApkBuilderService() => _instance;
  ApkBuilderService._internal();

  final StreamController<BuildUpdate> _statusController =
      StreamController<BuildUpdate>.broadcast();
  Stream<BuildUpdate> get statusStream => _statusController.stream;

  Future<void> buildApk(
    Project project,
    List<FileItem> files, {
    String? customPath,
  }) async {
    try {
      // 1. Bundling Phase
      _emit(BuildStatus.bundling, 'Bundling project files...', 0.1);
      Archive archive = Archive();
      for (var file in files) {
        final List<int> content = utf8.encode(file.content);
        archive.addFile(
          ArchiveFile('www/${file.name}', content.length, content),
        );
      }
      final List<int> zipData = ZipEncoder().encode(archive)!;
      // In a real app, this zipData would be uploaded
      final _ = zipData; // Silencing unused variable warning if any
      await Future.delayed(const Duration(seconds: 1));

      // 2. Uploading Phase
      _emit(BuildStatus.uploading, 'Uploading to Build Server...', 0.3);
      // In a real app, you would use:
      // var request = http.MultipartRequest('POST', Uri.parse('BUILD_API_URL'));
      // request.files.add(http.MultipartFile.fromBytes('project', zipData));
      // var response = await request.send();
      await Future.delayed(const Duration(seconds: 2));

      // 3. Server Processing Phase
      _emit(
        BuildStatus.processing,
        'Cloud Server: Compiling resources...',
        0.5,
      );
      await Future.delayed(const Duration(seconds: 2));
      _emit(BuildStatus.processing, 'Cloud Server: Generating DEX...', 0.7);
      await Future.delayed(const Duration(seconds: 2));
      _emit(BuildStatus.processing, 'Cloud Server: Signing APK...', 0.9);
      await Future.delayed(const Duration(seconds: 1));

      // 4. Success Phase
      final mockAppUrl =
          'https://build-server.example.com/outputs/${project.id}_v1.apk';

      _emit(
        BuildStatus.success,
        'Cloud Build Successful!',
        1.0,
        apkUrl: mockAppUrl,
      );
    } catch (e) {
      _emit(BuildStatus.error, 'Cloud Build failed: $e', 0.0);
    }
  }

  void _emit(
    BuildStatus status,
    String message,
    double progress, {
    String? apkUrl,
  }) {
    _statusController.add(
      BuildUpdate(
        status: status,
        message: message,
        progress: progress,
        apkUrl: apkUrl,
      ),
    );
  }
}

// Simple internal helper for character encoding
const Utf8Codec utf8 = Utf8Codec();
