import 'package:flutter/foundation.dart';
import '../models/project.dart';
import '../models/file_item.dart';
import '../services/database_service.dart';

class ProjectController extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<Project> _projects = [];
  bool _isLoading = false;

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;

  Future<void> loadProjects() async {
    _isLoading = true;
    notifyListeners();
    _projects = await _dbService.getAllProjects();
    _isLoading = false;
    notifyListeners();
  }

  Future<Project> createProject(String name) async {
    final project = Project(name: name, createdAt: DateTime.now());
    final id = await _dbService.insertProject(project);
    final newProject = Project(
      id: id,
      name: name,
      createdAt: project.createdAt,
    );
    _projects.insert(0, newProject);
    notifyListeners();
    return newProject;
  }

  Future<void> deleteProject(int id) async {
    await _dbService.deleteProject(id);
    _projects.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Future<List<FileItem>> getFiles(int projectId) async {
    return await _dbService.getFilesByProject(projectId);
  }

  Future<FileItem> createFile(
    int projectId,
    String name,
    String language,
  ) async {
    final file = FileItem(
      projectId: projectId,
      name: name,
      content: '',
      language: language,
      lastModified: DateTime.now(),
    );
    final id = await _dbService.insertFile(file);
    return file.copyWith(id: id);
  }

  Future<void> deleteFile(int id) async {
    await _dbService.deleteFile(id);
    notifyListeners();
  }
}
