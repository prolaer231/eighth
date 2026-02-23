import 'package:flutter_js/flutter_js.dart';
import './database_service.dart';

class ExecutionResult {
  final String stdout;
  final String stderr;
  final int exitCode;

  ExecutionResult({
    required this.stdout,
    required this.stderr,
    required this.exitCode,
  });
}

class ExecutionService {
  static final ExecutionService _instance = ExecutionService._internal();
  factory ExecutionService() => _instance;

  final JavascriptRuntime _jsRuntime = getJavascriptRuntime();
  String _jsOutput = '';

  ExecutionService._internal() {
    _jsRuntime.onMessage('print', (dynamic args) {
      _jsOutput += '${args.toString()}\n';
    });
    // Add console.log bridge using sendMessage
    _jsRuntime.evaluate(
      'var console = { log: function(msg) { sendMessage("print", JSON.stringify(msg)); } };',
    );
  }

  Future<ExecutionResult> runCode(
    String content,
    String language,
    String fileName,
  ) async {
    final lang = language.toLowerCase();

    // Internal Interpreters First
    if (lang == 'javascript' || lang == 'js') {
      return _runJS(content);
    } else if (lang == 'sql') {
      return _runSQL(content);
    }

    try {
      return ExecutionResult(
        stdout: '',
        stderr:
            'Execution and internal interpreter not supported for: $language.\n\nNote: This app supports HTML, CSS, JavaScript, SQL, and Markdown execution.',
        exitCode: -1,
      );
    } catch (e) {
      return ExecutionResult(stdout: '', stderr: 'Error: $e', exitCode: -1);
    }
  }

  Future<ExecutionResult> _runJS(String code) async {
    _jsOutput = ''; // Reset output for this run
    try {
      final result = _jsRuntime.evaluate(code);
      String combinedOutput = _jsOutput;
      if (result.stringResult != 'undefined' && result.stringResult != 'null') {
        combinedOutput += '\nResult: ${result.stringResult}';
      }
      return ExecutionResult(
        stdout: combinedOutput.trim(),
        stderr: '',
        exitCode: 0,
      );
    } catch (e) {
      return ExecutionResult(
        stdout: _jsOutput,
        stderr: 'JS Error: $e',
        exitCode: 1,
      );
    }
  }

  Future<ExecutionResult> _runSQL(String query) async {
    try {
      final db = await DatabaseService().database;
      final result = await db.rawQuery(query);
      return ExecutionResult(
        stdout: result.toString(),
        stderr: '',
        exitCode: 0,
      );
    } catch (e) {
      return ExecutionResult(stdout: '', stderr: 'SQL Error: $e', exitCode: 1);
    }
  }
}
