import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../controllers/editor_controller.dart';
import '../../models/project.dart';
import '../widgets/editor_widget.dart';
import '../widgets/file_explorer_drawer.dart';
import '../widgets/tab_bar_widget.dart';
import 'preview_screen.dart';
import 'build_status_screen.dart';
import 'settings_screen.dart';
import '../../controllers/project_controller.dart';

class EditorScreen extends StatefulWidget {
  final Project project;
  const EditorScreen({super.key, required this.project});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  @override
  Widget build(BuildContext context) {
    final editorController = context.watch<EditorController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            tooltip: 'Live Preview',
            onPressed:
                editorController.activeFile != null
                    ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => PreviewScreen(
                                file: editorController.activeFile!,
                              ),
                        ),
                      );
                    }
                    : null,
          ),
          IconButton(
            icon: const Icon(Icons.build),
            tooltip: 'Build APK',
            onPressed: () async {
              final projectController = context.read<ProjectController>();
              final navigator = Navigator.of(context);

              final String? selectedPath = await FilePicker.platform
                  .getDirectoryPath(dialogTitle: 'Select APK Save Location');

              if (selectedPath == null) return;

              final files = await projectController.getFiles(
                widget.project.id!,
              );

              if (!mounted) return;

              navigator.push(
                MaterialPageRoute(
                  builder:
                      (context) => BuildStatusScreen(
                        project: widget.project,
                        files: files,
                        savePath: selectedPath,
                      ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsView()),
              );
            },
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: TabBarWidget(),
        ),
      ),
      drawer: FileExplorerDrawer(project: widget.project),
      body:
          editorController.activeFile == null
              ? _buildEmptyState()
              : EditorWidget(file: editorController.activeFile!),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.code, size: 80, color: Colors.grey[700]),
          const SizedBox(height: 16),
          const Text(
            'Open a file from the drawer',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
