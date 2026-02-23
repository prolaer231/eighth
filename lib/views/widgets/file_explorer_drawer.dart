import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/project_controller.dart';
import '../../controllers/editor_controller.dart';
import '../../models/project.dart';
import '../../models/file_item.dart';

class FileExplorerDrawer extends StatelessWidget {
  final Project project;
  const FileExplorerDrawer({super.key, required this.project});

  String _getLanguageFromExtension(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'html':
        return 'html';
      case 'css':
        return 'css';
      case 'js':
        return 'javascript';
      case 'json':
        return 'json';
      case 'md':
        return 'markdown';
      case 'xml':
        return 'xml';
      case 'yaml':
      case 'yml':
        return 'yaml';
      case 'sql':
        return 'sql';
      default:
        return 'plaintext';
    }
  }

  void _showCreateFileDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('New File'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'filename.ext'),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (controller.text.isNotEmpty) {
                    final lang = _getLanguageFromExtension(controller.text);
                    final projectController = context.read<ProjectController>();
                    final file = await projectController.createFile(
                      project.id!,
                      controller.text,
                      lang,
                    );
                    if (context.mounted) {
                      context.read<EditorController>().openFile(file);
                      Navigator.pop(context);
                    }
                  }
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_open, size: 48, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    project.name,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_comment_outlined),
            title: const Text('New File'),
            onTap: () => _showCreateFileDialog(context),
          ),
          const Divider(),
          Expanded(
            child: Consumer<ProjectController>(
              builder: (context, projectController, child) {
                return FutureBuilder<List<FileItem>>(
                  future: projectController.getFiles(project.id!),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final files = snapshot.data!;
                    return ListView.builder(
                      itemCount: files.length,
                      itemBuilder: (context, index) {
                        final file = files[index];
                        return ListTile(
                          leading: Icon(
                            _getFileIcon(file.language),
                            color: _getFileColor(file.language),
                          ),
                          title: Text(file.name),
                          onTap: () {
                            context.read<EditorController>().openFile(file);
                            Navigator.pop(context);
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            onPressed: () => _confirmDeleteFile(context, file),
                          ),
                        );
                      },
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

  void _confirmDeleteFile(BuildContext context, FileItem file) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete File'),
            content: Text('Are you sure you want to delete "${file.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final projectController = context.read<ProjectController>();
                  final navigator = Navigator.of(context);
                  await projectController.deleteFile(file.id!);
                  if (context.mounted) navigator.pop();
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  IconData _getFileIcon(String lang) {
    switch (lang) {
      case 'html':
        return Icons.html;
      case 'css':
        return Icons.css;
      case 'javascript':
        return Icons.javascript;
      case 'markdown':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String lang) {
    switch (lang) {
      case 'html':
        return Colors.orange;
      case 'css':
        return Colors.blue;
      case 'javascript':
        return Colors.yellow[700]!;
      default:
        return Colors.grey;
    }
  }
}
