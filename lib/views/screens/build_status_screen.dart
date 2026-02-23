import 'package:flutter/material.dart';

import '../../services/apk_builder_service.dart';
import '../../models/project.dart';
import '../../models/file_item.dart';

class BuildStatusScreen extends StatefulWidget {
  final Project project;
  final List<FileItem> files;
  final String? savePath;

  const BuildStatusScreen({
    super.key,
    required this.project,
    required this.files,
    this.savePath,
  });

  @override
  State<BuildStatusScreen> createState() => _BuildStatusScreenState();
}

class _BuildStatusScreenState extends State<BuildStatusScreen> {
  final ApkBuilderService _builderService = ApkBuilderService();
  final List<String> _logs = [];
  double _progress = 0.0;
  BuildStatus _currentStatus = BuildStatus.idle;
  String? _finalApkUrl;

  @override
  void initState() {
    super.initState();
    _startBuild();
  }

  void _startBuild() {
    _builderService.statusStream.listen((update) {
      if (mounted) {
        setState(() {
          _currentStatus = update.status;
          _progress = update.progress;
          _logs.add(
            '[${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}] ${update.message}',
          );
          if (update.status == BuildStatus.success) {
            _finalApkUrl = update.apkUrl;
          }
        });
      }
    });

    _builderService.buildApk(
      widget.project,
      widget.files,
      customPath: widget.savePath,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('Offline APK Builder'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 32),
            _buildProgressBar(),
            const SizedBox(height: 32),
            const Text(
              'Build Logs',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Divider(color: Colors.green),
            Expanded(child: _buildLogsView()),
            if (_currentStatus == BuildStatus.success) _buildSuccessAction(),
            if (_currentStatus == BuildStatus.error) _buildErrorAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    String title = 'Building...';
    IconData icon = Icons.handyman;
    Color color = Colors.blue;

    if (_currentStatus == BuildStatus.success) {
      title = 'Build Complete!';
      icon = Icons.check_circle;
      color = Colors.green;
    } else if (_currentStatus == BuildStatus.error) {
      title = 'Build Failed';
      icon = Icons.error;
      color = Colors.red;
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(width: 16),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _progress,
          backgroundColor: Colors.grey[900],
          valueColor: AlwaysStoppedAnimation<Color>(
            _currentStatus == BuildStatus.error ? Colors.red : Colors.green,
          ),
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            Text(
              '${(_progress * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogsView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[900]!),
      ),
      child: ListView.builder(
        itemCount: _logs.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              _logs[index],
              style: const TextStyle(
                color: Color(0xFFD4D4D4),
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuccessAction() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      width: double.infinity,
      child: Column(
        children: [
          const Text(
            'The professional APK is ready for download!',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.link, color: Colors.blue, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: SelectableText(
                    _finalApkUrl ?? 'Unknown URL',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.done),
            label: const Text('Back to Editor'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorAction() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.refresh),
        label: const Text('Retry Build'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          setState(() {
            _logs.clear();
            _progress = 0.0;
          });
          _startBuild();
        },
      ),
    );
  }
}
