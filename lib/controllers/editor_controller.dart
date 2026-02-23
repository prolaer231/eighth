import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/file_item.dart';
import '../services/database_service.dart';

class EditorController extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  final List<FileItem> _openedFiles = [];
  int _activeTabIndex = -1;
  Timer? _autoSaveTimer;

  List<FileItem> get openedFiles => _openedFiles;
  int get activeTabIndex => _activeTabIndex;
  FileItem? get activeFile =>
      _activeTabIndex != -1 ? _openedFiles[_activeTabIndex] : null;

  void openFile(FileItem file) {
    final index = _openedFiles.indexWhere((f) => f.id == file.id);
    if (index != -1) {
      _activeTabIndex = index;
    } else {
      _openedFiles.add(file);
      _activeTabIndex = _openedFiles.length - 1;
    }
    notifyListeners();
  }

  void closeFile(int index) {
    _openedFiles.removeAt(index);
    if (_activeTabIndex >= _openedFiles.length) {
      _activeTabIndex = _openedFiles.length - 1;
    }
    notifyListeners();
  }

  void setActiveTab(int index) {
    _activeTabIndex = index;
    notifyListeners();
  }

  void updateContent(String content) {
    if (activeFile != null) {
      _openedFiles[_activeTabIndex] = activeFile!.copyWith(
        content: content,
        lastModified: DateTime.now(),
      );
      _startAutoSave();
    }
  }

  void _startAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), () async {
      if (activeFile != null) {
        await _dbService.updateFile(activeFile!);
      }
    });
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }
}
