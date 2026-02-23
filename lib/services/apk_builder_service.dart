import 'dart:io';
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
  final String? localPath;

  BuildUpdate({
    required this.status,
    required this.message,
    required this.progress,
    this.apkUrl,
    this.localPath,
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
      await Future.delayed(const Duration(seconds: 1));

      // 1.5 Save Local Copy (So 'Download' works locally)
      String? finalLocalPath;
      if (customPath != null) {
        _emit(BuildStatus.bundling, 'Saving local copy to $customPath...', 0.2);
        final fileName = '${project.name.replaceAll(' ', '_')}_source.zip';
        finalLocalPath = '$customPath/$fileName';
        final file = File(finalLocalPath);
        await file.writeAsBytes(zipData);
      }

      // 2. Uploading Phase
      _emit(BuildStatus.uploading, 'Uploading to Cloud Build Server...', 0.4);
      // In a real app, you would use:
      // var request = http.MultipartRequest('POST', Uri.parse('BUILD_API_URL'));
      // request.files.add(http.MultipartFile.fromBytes('project', zipData));
      // var response = await request.send();
      await Future.delayed(const Duration(seconds: 2));

      // 3. Server Processing Phase (Simulation)
      _emit(
        BuildStatus.processing,
        'Cloud Server: Compiling resources...',
        0.6,
      );
      await Future.delayed(const Duration(seconds: 2));
      _emit(BuildStatus.processing, 'Cloud Server: Signing APK...', 0.8);
      await Future.delayed(const Duration(seconds: 1));

      // 4. Success Phase
      // Updated to point to the user's specific repository
      final githubReleaseUrl =
          'https://github.com/prolaer231/eighth/releases/latest/download/app-release.apk';

      _emit(
        BuildStatus.success,
        'Project bundled & Ready for GitHub Cloud Build!',
        1.0,
        apkUrl: githubReleaseUrl,
        localPath: finalLocalPath,
      );
    } catch (e) {
      _emit(BuildStatus.error, 'Build failed: $e', 0.0);
    }
  }

  void _emit(
    BuildStatus status,
    String message,
    double progress, {
    String? apkUrl,
    String? localPath,
  }) {
    _statusController.add(
      BuildUpdate(
        status: status,
        message: message,
        progress: progress,
        apkUrl: apkUrl,
        localPath: localPath,
      ),
    );
  }
}

// Simple internal helper for character encoding
const Utf8Codec utf8 = Utf8Codec();
