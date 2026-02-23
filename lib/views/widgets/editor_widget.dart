import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:highlight/languages/all.dart';
import 'package:provider/provider.dart';
import '../../models/file_item.dart';
import '../../controllers/editor_controller.dart';
import '../../controllers/settings_controller.dart';

class EditorWidget extends StatefulWidget {
  final FileItem file;
  const EditorWidget({super.key, required this.file});

  @override
  State<EditorWidget> createState() => _EditorWidgetState();
}

class _EditorWidgetState extends State<EditorWidget> {
  late CodeController _codeController;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(EditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.file.id != widget.file.id) {
      _codeController.dispose();
      _initController();
    }
  }

  void _initController() {
    _codeController = CodeController(
      text: widget.file.content,
      language: allLanguages[widget.file.language] ?? allLanguages['plaintext'],
    );

    _codeController.addListener(() {
      context.read<EditorController>().updateContent(_codeController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          child: CodeTheme(
            data: CodeThemeData(
              styles: isDark ? monokaiSublimeTheme : githubTheme,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: CodeField(
                  controller: _codeController,
                  textStyle: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: settings.fontSize,
                  ),
                  gutterStyle: const GutterStyle(width: 45, margin: 10),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
