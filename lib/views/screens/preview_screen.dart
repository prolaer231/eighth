import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart' as wf;
import 'package:webview_windows/webview_windows.dart' as ww;
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../models/file_item.dart';
import '../../services/execution_service.dart';

class PreviewScreen extends StatefulWidget {
  final FileItem file;
  const PreviewScreen({super.key, required this.file});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  // Web Controllers
  late final wf.WebViewController _mobileController;
  final ww.WebviewController _windowsController = ww.WebviewController();

  bool _isWindowsReady = false;
  bool _isWebError = false;

  // Execution State
  final ExecutionService _executionService = ExecutionService();
  String _consoleOutput = '';
  bool _isExecuting = false;

  @override
  void initState() {
    super.initState();
    _initPreview();
  }

  Future<void> _initPreview() async {
    final lang = widget.file.language.toLowerCase();
    if (_isExecutable(lang)) {
      await _runCode();
    } else if (_isWebFile(lang)) {
      await _setupWebPreview();
    }
  }

  Future<void> _setupWebPreview() async {
    if (Platform.isWindows) {
      try {
        await _windowsController.initialize();
        await _windowsController.loadStringContent(_prepareContent());
        if (mounted) {
          setState(() => _isWindowsReady = true);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isWebError = true);
        }
      }
    } else {
      _mobileController =
          wf.WebViewController()
            ..setJavaScriptMode(wf.JavaScriptMode.unrestricted)
            ..loadHtmlString(_prepareContent());
    }
  }

  Future<void> _runCode() async {
    setState(() {
      _isExecuting = true;
      _consoleOutput =
          'Running ${widget.file.name} (${widget.file.language})...\n'
          '------------------------------------------------\n';
    });

    final result = await _executionService.runCode(
      widget.file.content,
      widget.file.language,
      widget.file.name,
    );

    if (mounted) {
      setState(() {
        _isExecuting = false;
        _consoleOutput += result.stdout;
        if (result.stderr.isNotEmpty) {
          _consoleOutput += '\n--- ERRORS ---\n${result.stderr}';
        }
        _consoleOutput +=
            '\n\nProcess finished with exit code ${result.exitCode}';
      });
    }
  }

  String _prepareContent() {
    final content = widget.file.content;
    final lang = widget.file.language.toLowerCase();
    if (lang == 'css') {
      return '<html><head><style>$content</style></head><body><div style="padding:20px;">CSS Preview: Style applied.</div></body></html>';
    }
    return content;
  }

  bool _isWebFile(String lang) => ['html', 'css'].contains(lang.toLowerCase());
  bool _isExecutable(String lang) =>
      ['sql', 'javascript', 'js'].contains(lang.toLowerCase());

  @override
  Widget build(BuildContext context) {
    final lang = widget.file.language.toLowerCase();
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview: ${widget.file.name}'),
        actions:
            _isExecutable(lang)
                ? [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _runCode,
                  ),
                ]
                : null,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final lang = widget.file.language.toLowerCase();
    if (lang == 'markdown' || lang == 'md') {
      return Markdown(data: widget.file.content);
    } else if (_isExecutable(lang)) {
      return _buildConsole();
    } else if (_isWebFile(lang)) {
      return _buildWebPreview();
    } else {
      return _buildRawView();
    }
  }

  Widget _buildWebPreview() {
    if (Platform.isWindows) {
      if (_isWebError) {
        return const Center(child: Text('WebView initialization failed.'));
      }
      if (!_isWindowsReady) {
        return const Center(child: CircularProgressIndicator());
      }
      return ww.Webview(_windowsController);
    }
    return wf.WebViewWidget(controller: _mobileController);
  }

  Widget _buildConsole() {
    final lang = widget.file.language.toUpperCase();
    return Container(
      color: const Color(0xFF0F0F0F),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[900],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.terminal, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'Console Output',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    lang,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isExecuting)
            const LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 2,
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: SelectableText(
                  _consoleOutput,
                  style: const TextStyle(
                    color: Color(0xFFD4D4D4),
                    fontFamily: 'monospace',
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRawView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        widget.file.content,
        style: const TextStyle(fontFamily: 'monospace'),
      ),
    );
  }

  @override
  void dispose() {
    if (Platform.isWindows) _windowsController.dispose();
    super.dispose();
  }
}
